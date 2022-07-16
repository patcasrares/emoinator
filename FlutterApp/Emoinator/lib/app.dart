import 'package:emoinator/screens/auth_screen.dart';
import 'package:emoinator/screens/live_preview.screen.dart';
import 'package:emoinator/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _firebaseInit = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _firebaseInit,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong: ' + snapshot.error.toString(),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Emoinator',
            routes: {
              AuthScreen.route: (context) => const AuthScreen(),
              LivePreviewScreen.route: (context) => const LivePreviewScreen()
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case WelcomeScreen.route:
                  return MaterialPageRoute(
                      builder: (context) =>
                          WelcomeScreen(username: settings.arguments as String));
              }
            },
            initialRoute: AuthScreen.route,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
