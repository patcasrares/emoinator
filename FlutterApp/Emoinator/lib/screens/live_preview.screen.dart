import 'package:emoinator/widgets/live_preview.widget.dart';
import 'package:flutter/material.dart';

class LivePreviewScreen extends StatelessWidget {
  static const String route = '/preview';

  const LivePreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: Center(
        child: LivePreview(),
      )
    );
  }
}
