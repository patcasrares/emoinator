import 'dart:async';
import 'package:camera/camera.dart';
import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/core/app_provider.dart';
import 'package:flutter/material.dart';

class CameraProvider extends AppProvider with WidgetsBindingObserver {
  // camera controller, to be used by children for various tasks
  // (e.g. CameraPreview)
  CameraController? get controller =>
      _controller == null || !_controller!.value.isInitialized
          ? null
          : _controller;

  Completer<void> get controllerInitialized => _controllerInitialized;
  Completer<void> _controllerInitialized = Completer();

  CameraController? _controller;
  late final CameraDescription? _selectedCamera;

  CameraProvider(BuildContext context)
      : super(context, AppConfig.once(context).logCamera) {
    availableCameras().then((cameras) {
      CameraDescription? camera;
      try {
        camera = cameras
            .firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      } on StateError {
        notify("Cannot find a suitable camera!",
            notificationType: NotificationType.Failure);
      }
      return camera;
    }).then((camera) async {
      _selectedCamera = camera;
      if (camera == null) {
        return;
      }
      _controller =
          CameraController(camera, ResolutionPreset.low, enableAudio: false);
      await _controller!.initialize();
      _controllerInitialized.complete();
      notify('Camera controller created and initialized',
          notificationType: NotificationType.Success);
    });
  }

  @override
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller?.dispose();
      _controllerInitialized = Completer();
    }
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
      _controllerInitialized = Completer();
    } else if (state == AppLifecycleState.resumed) {
      _controller = CameraController(_selectedCamera!, ResolutionPreset.low,
          enableAudio: false);
      _controllerInitialized.complete(_controller!.initialize());
    }
  }
}
