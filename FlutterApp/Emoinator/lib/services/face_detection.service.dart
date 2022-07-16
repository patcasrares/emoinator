import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:emoinator/c_interop/log_function.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:emoinator/c_interop/detect_faces.dart';

class FaceDetectionService {
  final String classifierAsset;

  FaceDetectionService({required this.classifierAsset});

  Future<void> init() async =>
      rootBundle.loadString(classifierAsset).then((classifierContent) async {
        // write the classifier to local storage, where it's accessible from C
        final directory = await getExternalStorageDirectory();
        final classifierStoragePath = directory!.path + "/" + classifierAsset;
        var file = File(classifierStoragePath);
        if (!await file.exists()) {
          file = await file.create(recursive: true);
        }
        await file.writeAsString(classifierContent);

        var utf8 = classifierStoragePath.toNativeUtf8();
        initDetection(loggerPointer, utf8);
        calloc.free(utf8);
      });

  Future<List<ui.Rect>> detect(Image image) async {

    final length = image.data.length;

    Pointer<Uint32> imageParameter = malloc<Uint32>(length);
    imageParameter.asTypedList(length).setRange(0, length, image.data);

    Pointer<Uint32> noFacesParameter = malloc<Uint32>(1);

    Pointer<Uint32> rects = detectFaces(
        imageParameter, image.width, image.height, noFacesParameter);

    int noFaces = noFacesParameter.value;
    var rectsList = rects.asTypedList(noFaces * 4);
    var result = <ui.Rect>[];

    for (int i = 0; i < noFaces; ++i) {
      var x = rectsList[i * 4].toDouble();
      var y = rectsList[i * 4 + 1].toDouble();
      var w = rectsList[i * 4 + 2].toDouble();
      var h = rectsList[i * 4 + 3].toDouble();
      result.add(ui.Rect.fromLTWH(x, y, w, h));
    }

    malloc.free(imageParameter);
    malloc.free(noFacesParameter);
    free(rects);

    return result;
  }

}
