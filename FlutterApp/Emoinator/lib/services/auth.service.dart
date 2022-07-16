import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoinator/core/exceptions/auth.exception.dart';

/// Allows registration and identification based on face encoding
/// For now, on login, the closest face is selected;
/// without the user entering their name on login, errors may occur.
/// TODO decide if we should ask for the username on login
class AuthService {
  void _checkFaceEncoding(List encoding) {
    if (encoding.length != 192) {
      throw AuthException('Nu am reușit să-ți scanăm fața; încearcă din nou');
    }
  }

  Future<void> register(String username, List faceEncoding) async {
    _checkFaceEncoding(faceEncoding);
    try {
      if ((await FirebaseFirestore.instance
                  .collection('Users')
                  .where('username', isEqualTo: username)
                  .get())
              .size >
          0) {
        throw AuthException('Contul există deja!');
      }
      await FirebaseFirestore.instance
          .collection('Users')
          .add({'username': username, 'encoding': faceEncoding});
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  double dist(List encoding1, List encoding2) {
    double dist = 0;
    for (int i = 0; i < min(encoding1.length, encoding2.length); i++) {
      dist += pow((encoding1[i] - encoding2[i]), 2);
    }
    return dist;
  }

  Future<String> login(List faceEncoding) async {
    _checkFaceEncoding(faceEncoding);
    try {
      var userCollection =
          await FirebaseFirestore.instance.collection('Users').get();

      String? closestUser;
      double? minDist;

      for (var doc in userCollection.docs) {
        List encoding = doc.get('encoding');
        if (encoding.length != 192) {
          continue;
        }

        var distance = dist(faceEncoding, encoding);

        if (minDist == null || distance < minDist) {
          closestUser = doc.get('username');
          minDist = distance;
        }
      }

      if (closestUser == null) {
        throw AuthException('Încearcă să te înregistrezi întâi');
      }

      return closestUser;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
