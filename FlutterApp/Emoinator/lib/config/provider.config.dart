import 'package:emoinator/providers/audio_provider.dart';
import 'package:emoinator/providers/auth.provider.dart';
import 'package:emoinator/providers/camera.provider.dart';
import 'package:emoinator/providers/face_bounds.provider.dart';
import 'package:emoinator/providers/low_res_image.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderConfig extends StatelessWidget {
  final Widget child;

  const ProviderConfig({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CameraProvider>(
          create: (context) => CameraProvider(context),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context),
        ),
        ChangeNotifierProxyProvider<CameraProvider, LowResImageProvider>(
          create: (context) => LowResImageProvider(
            context,
            Provider.of<CameraProvider>(context, listen: false),
          ),
          update: (context, cameraProvider, lowResImageProvider) =>
              lowResImageProvider != null
                  ? (lowResImageProvider..resetCameraProvider(cameraProvider))
                  : LowResImageProvider(context, cameraProvider),
        ),
        ChangeNotifierProxyProvider<LowResImageProvider, FaceBoundsProvider>(
          create: (context) => FaceBoundsProvider(
            context,
            Provider.of<LowResImageProvider>(context, listen: false),
          ),
          update: (context, lowResImageProvider, faceBoundsProvider) =>
              faceBoundsProvider != null
                  ? (faceBoundsProvider
                    ..resetImageProvider(lowResImageProvider))
                  : FaceBoundsProvider(context, lowResImageProvider),
        ),
        ChangeNotifierProvider<AudioProvider>(
          create: (context) => AudioProvider(context),
        ),
      ],
      child: child,
    );
  }
}
