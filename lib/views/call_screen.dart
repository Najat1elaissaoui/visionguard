import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../viewmodels/call_viewmodel.dart';
import '../agora_config.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CallViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Appel en cours"),
          ),
          body: Stack(
            children: [
              // Main video display area
              Center(
                child: viewModel.remoteUid != null
                    ? AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: viewModel.getEngine!,
                          canvas: VideoCanvas(uid: viewModel.remoteUid),
                          connection: RtcConnection(channelId: AgoraConfig.channelName),
                        ),
                      )
                    : (viewModel.localUserJoined && viewModel.isInCall
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: viewModel.getEngine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : Center(
                            child: viewModel.isInCall
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 20),
                                     
                                    ],
                                  )
                                : Text(
                                    "Appuyez sur le bouton pour démarrer l'appel",
                                    style: TextStyle(fontSize: 20),
                                  ),
                          )),
              ),

              // Local user's video preview (PIP style) - shown only when remote user is connected
              if (viewModel.isInCall && viewModel.localUserJoined && viewModel.remoteUid != null)
                Positioned(
                  right: 20,
                  bottom: 120,
                  child: Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: viewModel.getEngine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                ),

              // Control panel
              if (viewModel.isInCall)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(viewModel.isMuted ? Icons.mic_off : Icons.mic),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.toggleMute,
                        ),
                        IconButton(
                          icon: Icon(viewModel.isCameraOff ? Icons.videocam_off : Icons.videocam),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.toggleCamera,
                        ),
                        IconButton(
                          icon: Icon(Icons.call_end),
                          color: Colors.red,
                          iconSize: 40,
                          onPressed: viewModel.toggleCall,
                        ),
                        IconButton(
                          icon: Icon(Icons.flip_camera_ios),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.switchCamera,
                        ),
                        IconButton(
                          icon: Icon(viewModel.isTorchOn ? Icons.flash_on : Icons.flash_off),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.toggleTorch,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: !viewModel.isInCall
              ? FloatingActionButton.extended(
                  onPressed: viewModel.toggleCall,
                  label: Text("Démarrer l'appel"),
                  icon: Icon(Icons.call),
                )
              : null,
        );
      },
    );
  }
}