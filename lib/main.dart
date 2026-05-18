import 'package:pulsecall/pages/homePage.dart';
import 'package:pulsecall/theme/app_theme.dart';
import 'package:pulsecall/utils/constants.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const CallPromptApp());
}

class CallPromptApp extends StatelessWidget {
  const CallPromptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appname,
      debugShowCheckedModeBanner: false,
      theme: PulseTheme.dark(),
      home: const HomePage(),
    );
  }
}
