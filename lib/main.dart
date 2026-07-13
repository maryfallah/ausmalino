import 'package:ausmalino/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AusmalinoApp());
}

class AusmalinoApp extends StatelessWidget {
  const AusmalinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ausmalino',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Ausmalino'))),
    );
  }
}
