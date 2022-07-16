import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final bool logProviders;
  final bool logAudio;
  final bool logCamera;
  final bool logDetection;
  final bool logLowResCapture;
  final bool logAuth;
  final bool logServices;
  
  final String classifierAsset;
  final String faceEncodingModelAsset;
  final String faceEmotionModelAsset;
  final String serverUrl;


  const AppConfig({
    Key? key,
    required Widget child,
  })  : logProviders = true, // provider logs master switch
        logAudio = true, // audio provider logs
        logCamera = true, // camera provider logs
        logLowResCapture = false, // camera stream logs
        logDetection = false, // face bounds provider logs
        logAuth = false, // auth provider logs
        logServices = true,
        classifierAsset = 'assets/haarcascade_frontalface_default.xml',
        faceEncodingModelAsset = 'mobile_facenet.tflite',
        faceEmotionModelAsset = 'face_emotion_model.tflite',
        serverUrl = "http://192.168.43.132:8080", // TODO server address here
        super(key: key, child: child);

  // gets the value and listens to further changes;
  // see doc of dependOnInheritedWidgetOfExactType
  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  // gets the value once and does not listen for changes
  static AppConfig once(BuildContext context) {
    return context.findAncestorWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
