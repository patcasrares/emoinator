import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/providers/audio_provider.dart';
import 'package:emoinator/providers/face_bounds.provider.dart';
import 'package:emoinator/providers/low_res_image.provider.dart';
import 'package:emoinator/services/face_emotion_service.tflite.dart';
import 'package:emoinator/widgets/live_preview.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  static const String route = '/welcome';
  final String username;

  WelcomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final emotionServiceFuture = inject.getAsync<FaceEmotionService>();

  @override
  Widget build(BuildContext context) {
    final lowResImageProvider =
        Provider.of<LowResImageProvider>(context, listen: false);
    final faceBoundsProvider = Provider.of<FaceBoundsProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    audioProvider.currentUsername = widget.username;

    FaceEmotions? emotions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salut!'),
      ),
      body: FutureBuilder(
        future: emotionServiceFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              if (lowResImageProvider.image != null &&
                  faceBoundsProvider.bounds.isNotEmpty) {
                emotions = (snapshot.data as FaceEmotionService).detectEmotion(
                    lowResImageProvider.image!,
                    faceBoundsProvider.bounds.first,
                    widget.username);
              }
              final videoEmotion = emotions?.getOrderedEmotions()[0][0];
              final audioEmotion = audioProvider.emotion;

              final displayedEmotions = [videoEmotion, audioEmotion]
                  .where((element) => element != null)
                  .toList();

              return Stack(
                children: [
                  LivePreview(),
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        if (displayedEmotions.isNotEmpty)
                          Text(
                            displayedEmotions[0]!,
                            style: TextStyle(
                              fontWeight: displayedEmotions.length > 1
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        if (displayedEmotions.length > 1)
                          Text(
                            displayedEmotions[1]!,
                          )
                      ],
                    ),
                  )
                ],
              );
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
