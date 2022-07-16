import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:emoinator/config/inject.config.dart';

class SoundEmotionService {
  final _dio = inject.get<Dio>();

  final String baseUrl;

  SoundEmotionService(this.baseUrl);

  Dio initializeDio() {
    final dioOptions = _dio.options;
    dioOptions.baseUrl = baseUrl;
    _dio.options = dioOptions;
    return _dio;
  }

  Future<String?> detectEmotion(Uint8List audio, String? username) async {
    final formData = FormData();
    formData.files.add(
        MapEntry('sound', MultipartFile.fromBytes(audio, filename: 'sound')));
    return _dio
        .post<String>("$baseUrl/sound", data: formData)
        .then((value) async {
      if (username != null) {
        await FirebaseFirestore.instance.collection('soundEmotionData').add(
          {
            'username': username,
            'timestamp': DateTime.now(),
            'emotion': value.data,
          },
        );
      }
      return value.data;
    }).onError((error, stackTrace) => null);
  }
}
