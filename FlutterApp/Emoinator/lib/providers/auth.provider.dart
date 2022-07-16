import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/services/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/core/app_provider.dart';

class AuthProvider extends AppProvider {
  final AuthService _service = inject.get<AuthService>();

  bool _loggedIn = false;
  bool _loading = false;
  String? _username;
  Exception? _error;

  AuthProvider(BuildContext context)
      : super(context, AppConfig.once(context).logAuth);

  bool get loggedIn => _loggedIn;

  bool get loading => _loading;

  String? get username => _username;

  Exception? get error => _error;

  Future<void> login(List faceEncoding) async {
    _error = null;
    _loading = true;
    notify('login');

    return await _service.login(faceEncoding).then((username) {
      _loggedIn = true;
      _username = username;
      notify('login', notificationType: NotificationType.Success);
    }).catchError((err) {
      _error = err;
      notify('login', notificationType: NotificationType.Failure);
    }).whenComplete(() {
      _loading = false;
    });
  }

  Future<void> register(String username, List faceEncoding) async {
    _error = null;
    _loading = true;
    notify('register');

    return await _service.register(username, faceEncoding).then((_) {
      notify('register', notificationType: NotificationType.Success);
    }).catchError((err) {
      _error = err;
      notify('register', notificationType: NotificationType.Failure);
    }).whenComplete(() {
      _loading = false;
    });
  }
}
