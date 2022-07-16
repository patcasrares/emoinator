import 'dart:async';
import 'dart:ui' as ui;
import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/core/app_provider.dart';
import 'package:emoinator/providers/low_res_image.provider.dart';
import 'package:emoinator/services/face_detection.service.dart';
import 'package:flutter/material.dart';

class FaceBoundsProvider extends AppProvider {
  final _service = inject.getAsync<FaceDetectionService>();

  final List<ui.Rect> _bounds = [];
  Completer<void> _currentDetection = Completer()..complete();
  late LowResImageProvider _imageProvider;

  List<ui.Rect> get bounds => _bounds;

  FaceBoundsProvider(BuildContext context, LowResImageProvider provider)
      : super(context, AppConfig.once(context).logDetection) {
    resetImageProvider(provider);
  }

  resetImageProvider(LowResImageProvider provider) {
    _imageProvider = provider;
    _service.then((service) => _acceptImage(service));
  }

  _acceptImage(FaceDetectionService service) async {
    // if we can start looking for faces in this image
    if (_imageProvider.image != null && _currentDetection.isCompleted) {
      _currentDetection = Completer();
      _currentDetection.complete(
        service.detect(_imageProvider.image!).then(
          (bounds) {
            _bounds
              ..clear()
              ..addAll(bounds);
            notify(
              'detection completed (faces: ${bounds.length})',
              notificationType: NotificationType.Success,
            );
          },
        ),
      );
    }
  }
}
