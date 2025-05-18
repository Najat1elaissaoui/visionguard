import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../agora_config.dart';

class CallViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  RtcEngine? _engine;
  RtcEngine? get getEngine => _engine;
  late final RealtimeChannel _callchanel;

  bool _isInCall = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isTorchOn = false;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isRemoteVideoReceived = false;
  bool _isListeningForCallEvents = false;

  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isTorchOn => _isTorchOn;
  bool get localUserJoined => _localUserJoined;
  int? get remoteUid => _remoteUid;
  bool get isRemoteVideoReceived => _isRemoteVideoReceived;

  final int _myUid = 1;

  CallViewModel() {
    _callchanel = supabase.channel('calls_channel');
    _initializeEngine();
    _setupChannelListeners();
  }

  Future<void> _setupChannelListeners() async {
    await _listenForCallEvents();
  }

  Future<void> startCall() async {
    _isInCall = true;
    notifyListeners();

    await _initializeEngine();

    await _engine!.joinChannel(
      token: AgoraConfig.token,
      channelId: AgoraConfig.channelName,
      uid: _myUid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      ),
    );

    await _sendCallSignal();
  }

  Future<void> endCall() async {
  print('📴 Fin d\'appel côté assistant');
  try {
    await _engine?.leaveChannel();
    _isInCall = false;
    _localUserJoined = false;
    _remoteUid = null;
    notifyListeners();

    // ✅ Envoi de l'événement 'call_end_assistant' via le canal Supabase
    await _callchanel.sendBroadcastMessage(
      event: 'call_end_assistant',
      payload: {
        "uid": _myUid,
        "status": "ended",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );

    print('📤 Message "call_end_assistant" envoyé avec succès');
  } catch (e) {
    print('❌ Erreur lors de endCall: $e');
  }
}


  Future<void> _sendCallSignal() async {
    try {
      _callchanel.sendBroadcastMessage(
        event: 'incoming_call',
        payload: {'from': 'assistant'},
      );
      print("📡 Sonnerie envoyée à l'utilisateur aveugle.");
    } catch (e) {
      print("❌ Erreur lors de l'envoi de l'appel : $e");
    }
  }

  Future<void> _initializeEngine() async {
    if (_engine != null) {
      await _engine!.release();
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: AgoraConfig.appId));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("✅ [LOCAL] Rejoint le canal - UID: ${connection.localUid}");
          _localUserJoined = true;
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("👤 [REMOTE] Utilisateur distant rejoint - UID: $remoteUid");
          _remoteUid = remoteUid;
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("❌ [REMOTE] Utilisateur distant parti - UID: $remoteUid, raison: $reason");
          if (_remoteUid == remoteUid) {
            _remoteUid = null;
            _isRemoteVideoReceived = false;
            if (_isInCall && reason == UserOfflineReasonType.userOfflineQuit) {
              print("📴 L'utilisateur distant a quitté, on termine l'appel");
              endCall();
            }
            notifyListeners();
          }
        },
        onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
          print("📹 [REMOTE] Première image reçue de $remoteUid");
          _isRemoteVideoReceived = true;
          notifyListeners();
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          print("📺 État vidéo $state pour UID $remoteUid, raison: $reason");
        },
        onError: (ErrorCodeType err, String msg) {
          print("⛔ Erreur Agora: $err - $msg");
        },
      ),
    );

    await _engine!.enableVideo();
    await _engine!.enableAudio();

    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 30,
        bitrate: 1200,
        orientationMode: OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference.maintainQuality,
      ),
    );

    print("✅ Agora initialisé et configuré");
  }

  Future<void> _listenForCallEvents() async {
    if (_isListeningForCallEvents) return;

    _isListeningForCallEvents = true;
    print("🔔 Abonnement aux événements Supabase");

    _callchanel.onBroadcast(
      event: '*',
      callback: (payload) {
        final eventType = payload['event'] as String?;
        final data = payload['payload'] as Map<String, dynamic>?;

        print("📩 Broadcast reçu: $eventType, data: $data");

        if (eventType == 'call_ended' || 
            (eventType == 'call_end' && data?['status'] == 'ended')) {
          if (_isInCall) {
            print("📴 Appel terminé côté distant, on raccroche ici aussi");
            endCall();
          }
        }

        if (eventType == 'call_rejected' ||
            (eventType == 'call_end' && data?['status'] == 'rejected')) {
          print("📴 Appel rejeté côté distant, on raccroche ici aussi");
          endCall();
        }
      },
    );

    _callchanel.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        print("✅ Abonné au canal realtime Supabase");
      } else if (error != null) {
        print("❌ Erreur de souscription : $error");
      }
    });
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _engine?.muteLocalAudioStream(_isMuted);
    notifyListeners();
  }

  void toggleCamera() {
    _isCameraOff = !_isCameraOff;
    _engine?.muteLocalVideoStream(_isCameraOff);
    notifyListeners();
  }

  void switchCamera() {
    _engine?.switchCamera();
  }

  void toggleTorch() {
    _isTorchOn = !_isTorchOn;
    _engine?.setCameraTorchOn(_isTorchOn);
    notifyListeners();
  }

  @override
  void dispose() {
    print("🧹 Nettoyage Agora et canal");
    _callchanel.unsubscribe();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
} 


