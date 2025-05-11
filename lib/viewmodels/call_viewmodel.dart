import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../agora_config.dart';

class CallViewModel extends ChangeNotifier {
  RtcEngine? _engine;
  RtcEngine? get getEngine => _engine;

  bool _isInCall = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isTorchOn = false;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isRemoteVideoReceived = false;

  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isTorchOn => _isTorchOn;
  bool get localUserJoined => _localUserJoined;
  int? get remoteUid => _remoteUid;
  bool get isRemoteVideoReceived => _isRemoteVideoReceived;

  // UID statique pour l'assistant
  final int _myUid = 1;

  Future<void> toggleCall() async {
    if (!_isInCall) {
      // Vérifier et demander les permissions
      await [Permission.camera, Permission.microphone].request();

      if (await Permission.camera.isGranted && await Permission.microphone.isGranted) {
        try {
          print("🚀 Initialisation de l'appel...");
          await _initializeEngine();
          
          // Mettre à jour l'UI pour montrer que nous rejoignons
          _isInCall = true;
          notifyListeners();
          
          // Démarrer la prévisualisation locale
          await _engine!.startPreview();
          print("📽️ Prévisualisation locale démarrée");
          
          // Se joindre au canal
          print("🔄 Tentative de rejoindre le canal: ${AgoraConfig.channelName} avec UID: $_myUid");
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
          
          // L'utilisateur local (assistant) est maintenant considéré comme rejoint
          // même si la callback n'a pas encore été déclenchée
          _localUserJoined = true;
          notifyListeners();
          
          print("✅ Demande de rejoindre le canal envoyée");
        } catch (e) {
          print("⛔ Erreur lors de l'initialisation de l'appel: $e");
          _isInCall = false;
          _localUserJoined = false;
          notifyListeners();
        }
      } else {
        print("⚠️ Permissions refusées");
      }
    } else {
      // Quitter l'appel
      print("🔴 Quitter l'appel...");
      await _engine?.leaveChannel();
      _isInCall = false;
      _localUserJoined = false;
      _remoteUid = null;
      _isRemoteVideoReceived = false;
      notifyListeners();
      print("🔴 Appel terminé");
    }
  }

  Future<void> _initializeEngine() async {
    if (_engine != null) {
      await _engine!.release();
    }
    
    print("======== INITIALISATION AGORA ========");
    print("App ID: ${AgoraConfig.appId}");
    print("Channel: ${AgoraConfig.channelName}");
    print("Local UID: $_myUid");
    
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("✅ [LOCAL] Rejoindre le canal réussi - UID: ${connection.localUid}");
          _localUserJoined = true;
          notifyListeners();
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          print("⚠️ [CONNECTION] État de connexion: $state, raison: $reason");
          
          // Gestion automatique des reconnexions
          if (state == ConnectionStateType.connectionStateDisconnected ||
              state == ConnectionStateType.connectionStateFailed) {
            if (_isInCall) {
              print("🔄 Tentative de reconnexion automatique...");
              // Attendre 2 secondes avant de tenter une reconnexion
              Future.delayed(Duration(seconds: 2), () {
                if (_isInCall) {
                  _engine!.joinChannel(
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
                }
              });
            }
          }
        },
        onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
          print("📹 [REMOTE] Première image vidéo reçue de UID: $remoteUid, dimensions: $width x $height");
          _isRemoteVideoReceived = true;
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
            notifyListeners();
          }
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          print("📺 [REMOTE] État vidéo - UID: $remoteUid, état: $state, raison: $reason");
          
          if (state == RemoteVideoState.remoteVideoStateDecoding) {
            print("📺 [REMOTE] Vidéo distante en cours de lecture");
            _isRemoteVideoReceived = true;
            notifyListeners();
          } else if (state == RemoteVideoState.remoteVideoStateStopped) {
            print("📺 [REMOTE] Vidéo distante arrêtée");
            _isRemoteVideoReceived = false;
            notifyListeners();
          }
        },
        onRemoteAudioStateChanged: (RtcConnection connection, int remoteUid, RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
          print("🔊 [REMOTE] État audio - UID: $remoteUid, état: $state, raison: $reason");
        },
        onError: (ErrorCodeType err, String msg) {
          print("⛔ [ERROR] Erreur Agora: $err, $msg");
          
          // Gestion des erreurs critiques
          if (err == ErrorCodeType.errTokenExpired) {
            print("⛔ [ERROR] Problème de token, reconnexion requise");
            // Ici, vous pourriez implémenter une logique pour obtenir un nouveau token
          }
        },
      ),
    );

    await _engine!.enableVideo();
    await _engine!.enableAudio();
    
    // Configure video encoder avec paramètres optimisés
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 30,
        bitrate: 1200,
        orientationMode: OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference.maintainQuality,
      ),
    );
    
    print("✅ Configuration vidéo et audio appliquée");
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
    print("🧹 Nettoyage des ressources Agora");
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}