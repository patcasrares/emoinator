import 'dart:developer';

import 'package:emoinator/config/app.config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  final BuildContext context;
  final bool printLogs;

  AppProvider(this.context, this.printLogs);

  void notify(String message,
      {NotificationType? notificationType}) {
    if (AppConfig.once(context).logProviders && printLogs) {
      var logMessage = message;
      switch (notificationType) {
        case NotificationType.Cancel:
          logMessage += ' - Cancel';
          break;
        case NotificationType.Start:
          logMessage += ' - Start';
          break;
        case NotificationType.Success:
          logMessage += ' - Success';
          break;
        case NotificationType.Failure:
          logMessage += ' - Failure';
          break;
        default:
          break;
      }
      log(
        logMessage,
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
    notifyListeners();
  }
}

enum NotificationType {
  Cancel,
  Start,
  Success,
  Failure,
}
