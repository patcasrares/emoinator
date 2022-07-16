import 'package:emoinator/widgets/auth.widget.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  static const String route = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('☺'),
      ),
      body: AuthWidget(),
    );
  }
}
