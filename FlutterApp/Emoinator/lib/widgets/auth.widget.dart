import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/providers/auth.provider.dart';
import 'package:emoinator/providers/face_bounds.provider.dart';
import 'package:emoinator/providers/low_res_image.provider.dart';
import 'package:emoinator/screens/welcome_screen.dart';
import 'package:emoinator/services/face_encoding_service.dart';
import 'package:emoinator/utils/validators.utils.dart';
import 'package:emoinator/widgets/live_preview.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWidget extends StatefulWidget {
  final _faceEncodingService = inject.getAsync<FaceEncodingService>();

  AuthWidget({Key? key}) : super(key: key);

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final _registerFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final lowResImageProvider =
        Provider.of<LowResImageProvider>(context, listen: false);
    final faceBoundsProvider = Provider.of<FaceBoundsProvider>(context);

    var facesDetected = lowResImageProvider.image != null &&
        faceBoundsProvider.bounds.isNotEmpty;

    return FutureBuilder(
      future: widget._faceEncodingService,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
          child: Stack(
            children: [
              LivePreview(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: !facesDetected
                        ? null
                        : () async {
                            var img = lowResImageProvider.image!;
                            var bound = faceBoundsProvider.bounds[0];
                            var encoding =
                                (snapshot.data as FaceEncodingService)
                                    .encode(img, bound);
                            _login(authProvider, encoding);
                          },
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: !facesDetected
                        ? null
                        : () async {
                            var img = lowResImageProvider.image!;
                            var bound = faceBoundsProvider.bounds[0];
                            var encoding =
                                (snapshot.data as FaceEncodingService)
                                    .encode(img, bound);
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Cont nou"),
                                  content: Form(
                                    key: _registerFormKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          autocorrect: false,
                                          controller: _usernameController,
                                          validator: (value) =>
                                              UtilValidators.guard(value)
                                                  .required(
                                                      'Scrie-ți numele aici')
                                                  .message,
                                          decoration: const InputDecoration(
                                              label: Text('Nume')),
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Anulează')),
                                    TextButton(
                                        onPressed: () {
                                          if ((_registerFormKey.currentState
                                                      ?.validate() ??
                                                  false) &&
                                              !authProvider.loading) {
                                            _register(authProvider, encoding);
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Înregistrează-te'))
                                  ],
                                );
                              },
                            );
                          },
                    child: const Text('Register'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _login(AuthProvider authProvider, List encoding) {
    authProvider.login(encoding).whenComplete(
      () {
        if (authProvider.loggedIn) {
          Navigator.pushNamed(
            context,
            WelcomeScreen.route,
            arguments: authProvider.username ?? 'UNKNOWN',
          );
        } else if (authProvider.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(_textSnackbar(authProvider.error.toString()));
        }
      },
    );
  }

  void _register(AuthProvider authProvider, List encoding) {
    authProvider.register(_usernameController.text, encoding).whenComplete(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          _textSnackbar(
              authProvider.error?.toString() ?? 'Înregistrare reușită!'),
        );
      },
    );
  }

  SnackBar _textSnackbar(String error) => SnackBar(content: Text(error));
}
