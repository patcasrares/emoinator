import 'package:camera/camera.dart';
import 'package:emoinator/providers/camera.provider.dart';
import 'package:emoinator/providers/face_bounds.provider.dart';
import 'package:emoinator/providers/low_res_image.provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LivePreview extends StatefulWidget {
  LivePreview({Key? key}) : super(key: key);

  @override
  _LivePreviewState createState() => _LivePreviewState();
}

class _LivePreviewState extends State<LivePreview> {
  @override
  Widget build(BuildContext context) {
    // these providers listen to each other, so there's no point in listening to all of them
    final _cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final _lowResImageProvider =
        Provider.of<LowResImageProvider>(context, listen: false);
    final _faceBoundsProvider = Provider.of<FaceBoundsProvider>(context);

    return Center(
      child: FutureBuilder(
        future: _lowResImageProvider.capturingLowRes
            ? Future.value()
            : _lowResImageProvider.startCapturing(),
        builder: (context, snapshot) {
          if (_cameraProvider.controller == null) {
            return const CircularProgressIndicator();
          }
          return CustomPaint(
            foregroundPainter: BoundingBoxPainter(
              _faceBoundsProvider.bounds,
              _lowResImageProvider.image == null
                  ? const Size(0, 0)
                  : Size(
                      _lowResImageProvider.image!.width.toDouble(),
                      _lowResImageProvider.image!.height.toDouble(),
                    ),
            ),
            child: CameraPreview(
              _cameraProvider.controller!,
            ),
          );
        },
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  late final List<Rect> _bounds;
  late final Size _boundsResolution;

  List<Rect> get bounds => _bounds;

  Size get boundsResolution => _boundsResolution;

  BoundingBoxPainter(this._bounds, this._boundsResolution);

  @override
  void paint(Canvas canvas, Size size) {
    for (var faceBound in _bounds) {
      // convert rectangles that refer to the small image to the size of the camera preview
      var relative = RelativeRect.fromSize(faceBound, _boundsResolution);
      faceBound = relative.toRect(Rect.fromLTWH(0, 0, size.width, size.height));

      // mirror the rectangle, as the CameraPreview also mirrors the image
      faceBound = Rect.fromLTWH(
        size.width - faceBound.left - faceBound.width,
        faceBound.top,
        faceBound.width,
        faceBound.height,
      );

      canvas.drawRect(
        faceBound,
        Paint()
          ..color = Colors.green
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // var firstCheck = oldDelegate is! BoundingBoxPainter ||
    //     oldDelegate.boundsResolution != _boundsResolution ||
    //     oldDelegate.bounds.length != _bounds.length;
    return true;
  }
}
