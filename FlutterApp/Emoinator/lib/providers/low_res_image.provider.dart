import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/providers/camera.provider.dart';
import 'package:emoinator/services/image_conversion_service.dart';
import 'package:image/image.dart' as img_lib;
import 'package:camera/camera.dart';
import 'package:emoinator/core/app_provider.dart';
import 'package:flutter/material.dart';

class LowResImageProvider extends AppProvider with WidgetsBindingObserver {
  // RGB, low-resolution image from the camera
  img_lib.Image? get image => _image;

  // whether or not the camera is capturing low res images at the moment
  bool get capturingLowRes => _capturing;

  final ImageConversionService _conversionService =
      inject.get<ImageConversionService>();
  img_lib.Image? _image;
  bool _capturing = false;

  late CameraProvider _cameraProvider;

  LowResImageProvider(BuildContext context, CameraProvider cameraProvider)
      : super(context, AppConfig.once(context).logLowResCapture) {
    _cameraProvider = cameraProvider;
  }

  // this provider depends on the CameraProvider; this is used in order to
  // refresh when the camera provider changes, but keep state
  resetCameraProvider(CameraProvider cameraProvider) {
    _cameraProvider = cameraProvider;
  }

  Future<void> startCapturing() async {
    if (_capturing) {
      return;
    }
    if (!_cameraProvider.controllerInitialized.isCompleted) {
      await _cameraProvider.controllerInitialized.future;
    }

    return _cameraProvider.controller
        ?.startImageStream(_onImageReceived)
        .then((_) => _capturing = true);
  }

  Future<void> stopCapturing() async {
    if (!_capturing) {
      return;
    }
    await _cameraProvider.controller!
        .stopImageStream()
        .then((_) => _capturing = false);
  }

  Future<void> _onImageReceived(CameraImage image) async {
    _image = _conversionService.yuvToRgb(image);
    notify('image',
        notificationType: NotificationType.Success);
  }

  @override
  Future<void> dispose() async {
    if (_capturing) {
      await stopCapturing();
    }
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      if (_capturing) {
        await stopCapturing();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_cameraProvider.controllerInitialized.isCompleted) {
        await _cameraProvider.controllerInitialized.future;
      }
      if (_capturing) {
        _cameraProvider.controller!.startImageStream(_onImageReceived);
      }
    }
  }
}
