import 'package:emoinator/config/app.config.dart';
import 'package:emoinator/config/inject.config.dart';
import 'package:emoinator/config/provider.config.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  const app = AppConfig(
    child: ProviderConfig(
      child: App(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection(app);
  runApp(app);
}
