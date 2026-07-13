import 'package:flutter/material.dart';

void main() {
  runApp(const AusmalinoApp());
}

class AusmalinoApp extends StatelessWidget {
  const AusmalinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Ausmalino',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Ausmalino'))),
    );
  }
}
