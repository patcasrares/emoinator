import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEncodingService {
  Interpreter? _interpreter;
  final String modelPath;

  FaceEncodingService({required this.modelPath});

  Future<void> loadModel() async {
    Delegate? delegate;
    if (Platform.isAndroid) {
      delegate = GpuDelegateV2(
        options: GpuDelegateOptionsV2(
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.minLatency,
        ),
      );
    } else if (Platform.isIOS) {
      delegate = GpuDelegate(
        options: GpuDelegateOptions(
          waitType: TFLGpuDelegateWaitType.active,
        ),
      );
    }
    var interpreterOptions = InterpreterOptions();
    interpreterOptions.addDelegate(delegate!);

    _interpreter = await Interpreter.fromAsset(
      modelPath,
      options: interpreterOptions,
    );
  }

  List encode(Image cameraImage, Rect face) {
    List input = _preprocess(cameraImage, face);

    // model format
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    // run model
    _interpreter!.run(input, output);
    output = output.reshape([192]);

    return List.from(output);
  }

  Float32List _preprocess(Image image, Rect box) {
    Image croppedImage = copyCrop(
      image,
      box.left.toInt(),
      box.top.toInt(),
      box.width.toInt(),
      box.height.toInt(),
    );
    Image img = copyResizeCropSquare(croppedImage, 112);

    // transforms the cropped face to array data
    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  Float32List _imageToByteListFloat32(Image image) {
    /// input size = 112
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);

        /// mean: 128
        /// std: 128
        buffer[pixelIndex++] = (getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

}
