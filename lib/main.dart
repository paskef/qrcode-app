import 'package:flutter/material.dart';
import 'screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: QRCodeScannerScreen(),
  ));
}
