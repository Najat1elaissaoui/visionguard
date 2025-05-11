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
            title: const Text("Appel en cours"),
            backgroundColor: Colors.blueGrey.shade800,
            actions: [
              if (viewModel.isInCall)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      viewModel.remoteUid != null ? "Connecté" : "En attente...",
                      style: TextStyle(
                        color: viewModel.remoteUid != null ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              // Fond noir pour l'écran d'appel
              Container(color: Colors.black),
              
              // 1. Si pas en appel, afficher l'écran d'accueil
              if (!viewModel.isInCall)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.support_agent, size: 80, color: Colors.white54),
                      SizedBox(height: 20),
                      Text(
                        "Prêt à aider l'utilisateur",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      SizedBox(height: 30),
                      FloatingActionButton.extended(
                        onPressed: viewModel.toggleCall,
                        backgroundColor: Colors.green,
                        label: const Text("Démarrer l'appel"),
                        icon: const Icon(Icons.call),
                      ),
                    ],
                  ),
                ),

              // 2. Si en appel mais pas encore rejoint, afficher un indicateur de chargement
              if (viewModel.isInCall && !viewModel.localUserJoined)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "Initialisation de l'appel...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),

              // 3. Si en appel et rejoint localement, afficher les vidéos
              if (viewModel.isInCall && viewModel.localUserJoined)
                Stack(
                  children: [
                    // Vidéo distante (utilisateur aveugle)
                    if (viewModel.remoteUid != null)
                      Center(
                        child: AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: viewModel.getEngine!,
                            canvas: VideoCanvas(uid: viewModel.remoteUid),
                            connection: RtcConnection(channelId: AgoraConfig.channelName),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white54),
                            SizedBox(height: 20),
                            Text(
                              "En attente de l'utilisateur...",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                    // Vidéo locale (assistant)
                    Positioned(
                      right: 20,
                      bottom: 120,
                      child: Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: viewModel.getEngine!,
                              canvas: const VideoCanvas(uid: 0), // 0 pour la vue locale
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // 4. Contrôles pendant l'appel
              if (viewModel.isInCall && viewModel.localUserJoined)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(viewModel.isMuted ? Icons.mic_off : Icons.mic),
                          color: viewModel.isMuted ? Colors.red : Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.toggleMute,
                        ),
                        IconButton(
                          icon: Icon(viewModel.isCameraOff ? Icons.videocam_off : Icons.videocam),
                          color: viewModel.isCameraOff ? Colors.red : Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.toggleCamera,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.call_end),
                            color: Colors.white,
                            iconSize: 30,
                            onPressed: viewModel.toggleCall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flip_camera_ios),
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.switchCamera,
                        ),
                        IconButton(
                          icon: Icon(viewModel.isTorchOn ? Icons.flash_on : Icons.flash_off),
                          color: viewModel.isTorchOn ? Colors.amber : Colors.white,
                          iconSize: 30,
                          onPressed: viewModel.toggleTorch,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}