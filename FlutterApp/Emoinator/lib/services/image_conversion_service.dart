import 'dart:ffi';
import 'package:camera/camera.dart';
import 'package:emoinator/c_interop/yuv420_to_rgb.dart';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart';

class ImageConversionService {
  ImageConversionService();

  final List<Pointer<Uint8>> _planeBuffers = [];
  final List<int> _planeSizes = [];

  Pointer<Uint32>? _imageBuffer;
  int? _imageWidth, _imageHeight;

  Image yuvToRgb(CameraImage image) {
    _ensureBuffersReady(image);

    for (int i = 0; i < 3; ++i) {
      _planeBuffers[i]
          .asTypedList(image.planes[i].bytes.length)
          .setRange(0, image.planes[i].bytes.length, image.planes[i].bytes);
    }

    // Get the pointer of the data returned from the function to a List
    yuvToRGB(
        _imageBuffer!,
        _planeBuffers[0],
        _planeBuffers[1],
        _planeBuffers[2],
        image.planes[1].bytesPerRow,
        image.planes[1].bytesPerPixel!,
        image.width,
        image.height);

    // Generate image from the converted data
    List<int> imgData = _imageBuffer!.asTypedList(image.width * image.height);
    return Image.fromBytes(image.height, image.width, imgData);
  }

  _ensureBuffersReady(CameraImage image) {
    if (_planeBuffers.length != 3) {
      _planeBuffers.clear();
    }

    if (_planeSizes.length == 3) {
      bool sizesChanged =
          _imageWidth != image.width || _imageHeight != image.height;
      if (!sizesChanged) {
        for (int i = 0; i < 3; ++i) {
          if (_planeSizes[i] != image.planes[i].bytes.length) {
            sizesChanged = true;
            break;
          }
        }
      }
      if (sizesChanged) {
        _free();
      }
    }

    if (_planeBuffers.isEmpty) {
      image.planes.map((plane) => plane.bytes.length).forEach((size) {
        _planeBuffers.add(malloc<Uint8>(size));
        _planeSizes.add(size);
      });
    }

    _imageBuffer ??= malloc<Uint32>(image.width * image.height);
  }

  void _free() {
    for (var element in _planeBuffers) {
      malloc.free(element);
    }
    _planeBuffers.clear();
    if (_imageBuffer != null) {
      malloc.free(_imageBuffer!);
      _imageBuffer = null;
    }
  }

  void dispose() => _free();
}
