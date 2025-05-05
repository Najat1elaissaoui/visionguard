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

  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isTorchOn => _isTorchOn;
  bool get localUserJoined => _localUserJoined;
  int? get remoteUid => _remoteUid;

  Future<void> toggleCall() async {
    if (!_isInCall) {
      await [Permission.camera, Permission.microphone].request();

      if (await Permission.camera.isGranted && await Permission.microphone.isGranted) {
        try {
          await _initializeEngine();
          
          // Set local user joined to true immediately after initialization
          // This allows seeing the local preview right away
          _localUserJoined = true;
          _isInCall = true;
          notifyListeners();
          
          // Join channel after UI update
          await _engine!.joinChannel(
            token: AgoraConfig.token,
            channelId: AgoraConfig.channelName,
            uid: 0,
            options: const ChannelMediaOptions(
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
              channelProfile: ChannelProfileType.channelProfileCommunication,
            ),
          );
        } catch (e) {
          print("Error initializing call: $e");
          _isInCall = false;
          _localUserJoined = false;
          notifyListeners();
        }
      } else {
        print("Permissions refusées");
      }
    } else {
      await _engine?.leaveChannel();
      _isInCall = false;
      _localUserJoined = false;
      _remoteUid = null;
      notifyListeners();
    }
  }

  Future<void> _initializeEngine() async {
    if (_engine != null) {
      await _engine!.release();
    }
    
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
      // Suppression de la ligne qui cause l'erreur
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user joined: ${connection.localUid}");
          // We've already set localUserJoined=true earlier for immediate preview
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user joined: $remoteUid");
          _remoteUid = remoteUid;
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user left: $remoteUid, reason: $reason");
          _remoteUid = null;
          notifyListeners();
        },
        onError: (ErrorCodeType err, String msg) {
          print("Error: $err, $msg");
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          print("Connection state changed: $state, reason: $reason");
        },
      ),
    );

    await _engine!.enableVideo();
    await _engine!.enableAudio();
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    
    // Configure video encoder
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 800,
      ),
    );
    
    // Start preview after all settings are applied
    await _engine!.startPreview();
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
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}