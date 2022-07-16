library inject_config;

import 'package:emoinator/config/dio.config.dart';
import 'package:emoinator/services/auth.service.dart';
import 'package:emoinator/services/face_detection.service.dart';
import 'package:emoinator/services/face_emotion_service.tflite.dart';
import 'package:emoinator/services/face_encoding_service.dart';
import 'package:emoinator/services/image_conversion_service.dart';
import 'package:emoinator/services/sound_emotion.service.dart';
import 'package:get_it/get_it.dart';
import 'package:emoinator/config/app.config.dart';

GetIt inject = GetIt.instance;

void setupDependencyInjection(AppConfig configuredApp) async {
  inject.registerLazySingleton(() => dioInstance(configuredApp));

  inject.registerLazySingleton<ImageConversionService>(
      () => ImageConversionService(),
      dispose: (service) => service.dispose());

  inject.registerLazySingletonAsync<FaceDetectionService>(
    () async {
      var service = FaceDetectionService(
        classifierAsset: configuredApp.classifierAsset,
      );
      await service.init();
      return service;
    },
  );

  inject.registerLazySingletonAsync<FaceEncodingService>(
    () async {
      var service = FaceEncodingService(
        modelPath: configuredApp.faceEncodingModelAsset,
      );
      await service.loadModel();
      return service;
    },
  );

  inject.registerLazySingletonAsync<FaceEmotionService>(
    () async {
      var service = FaceEmotionService(
        modelPath: configuredApp.faceEmotionModelAsset,
      );
      await service.loadModel();
      return service;
    },
  );

  inject.registerLazySingleton<SoundEmotionService>(
    () => SoundEmotionService(configuredApp.serverUrl),
  );

  inject.registerLazySingleton<AuthService>(() => AuthService());
}
