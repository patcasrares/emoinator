import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmotionService {
  Interpreter? _interpreter;
  final String modelPath;

  FaceEmotionService({required this.modelPath});

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

  FaceEmotions detectEmotion(Image cameraImage, Rect face, String? username) {
    List input = _preprocess(grayscale(cameraImage), face);

    // model format
    input = input.reshape([1, 48, 48, 1]);
    List output = List.generate(1, (index) => List.filled(7, 0));

    // run model
    _interpreter!.run(input, output);
    output = output.reshape([7]);

    var emotions = FaceEmotions(List.from(output));

    if (username != null) {
      var json = emotions.toJson();
      json['timestamp'] = DateTime.now();
      json['username'] = username;
      FirebaseFirestore.instance
        .collection('faceEmotionsData')
        .add(json);
    }

    return emotions;
  }

  Float32List _preprocess(Image image, Rect box) {
    Image croppedImage = copyCrop(
      image,
      box.left.toInt(),
      box.top.toInt(),
      box.width.toInt(),
      box.height.toInt(),
    );
    Image img = copyResizeCropSquare(croppedImage, 48);
    // transforms the cropped face to array data
    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  Float32List _imageToByteListFloat32(Image image) {
    /// input size = 48
    var convertedBytes = Float32List(48 * 48);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 48; i++) {
      for (var j = 0; j < 48; j++) {
        var pixel = image.getPixel(j, i);

        /// mean: 128
        /// std: 128
        buffer[pixelIndex++] = getRed(pixel) - 128 / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

}

class FaceEmotions {
  final List _emotions;

  double get angry => _emotions[0] * 100;
  double get disgust => _emotions[1] * 100;
  double get fear => _emotions[2] * 100;
  double get happy => _emotions[3] * 100;
  double get neutral => _emotions[4] * 100;
  double get sad => _emotions[5] * 100;
  double get surprised => _emotions[6] * 100;

  FaceEmotions(List emotions):
      _emotions = emotions;

  @override
  String toString() {
    return 'FaceEmotions{angry: $angry, disgust: $disgust, fear: $fear, happy: $happy, neutral: $neutral, sad: $sad, surprised: $surprised}';
  }

  List<List<String>> getOrderedEmotions() {
    var out = [
      ['angry', angry],
      ['disgust', disgust],
      ['fear', fear],
      ['happy', happy],
      ['neutral', neutral],
      ['sad', sad],
      ['surprised', surprised]
    ]..sort((a, b) => ((b[1] as double) - (a[1] as double)).toInt());
    return out.map((e) => <String>[e[0].toString(), e[1].toString()]).toList();
  }

  Map<String, dynamic> toJson() => {
    'angry': angry,
    'disgust': disgust,
    'fear': fear,
    'happy': happy,
    'neutral': neutral,
    'sad': sad,
    'surprised': surprised
  };
}
