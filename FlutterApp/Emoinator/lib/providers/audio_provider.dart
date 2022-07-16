import 'dart:typed_data';

import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/core/app_provider.dart';
import 'package:emoinator/services/sound_emotion.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mic_stream/mic_stream.dart';

class AudioProvider extends AppProvider {
  final double windowDuration;

  final audioEmotionService = inject.get<SoundEmotionService>();

  Uint8List? get currentData {
    final backup = _lastWindow;
    _lastWindow = null;
    return backup;
  }

  String? _currentUsername;

  set currentUsername(String value) => _currentUsername = value;

  String? _emotion;

  String? get emotion => _emotion;

  Uint8List? _lastWindow;
  final List<int> _currentAudio = [];
  double _currentDuration = 0;

  AudioProvider(BuildContext context)
      : windowDuration = 4,
        super(context, AppConfig.once(context).logAudio) {
    MicStream.microphone(
            audioFormat: AudioFormat.ENCODING_PCM_16BIT,
            audioSource: AudioSource.MIC,
            channelConfig: ChannelConfig.CHANNEL_IN_MONO,
            sampleRate: 44100)
        .then(
      (stream) async {
        stream!.listen(
          (audio) async {
            var duration = audio.length / 2.0 / 44100;
            _currentAudio.addAll(audio);
            _currentDuration += duration;
            if (_currentDuration >= windowDuration) {
              _lastWindow = Uint8List.fromList(_currentAudio);
              _currentAudio.clear();
              _currentDuration = 0;
              _emotion = await audioEmotionService.detectEmotion(
                _lastWindow!,
                _currentUsername,
              );
              notify('Audio finished',
                  notificationType: NotificationType.Success);
            }
          },
        );
      },
    );
  }
}
