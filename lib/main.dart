import 'package:flutter/material.dart';
import 'screens/acilis_ekrani.dart';
import 'theme/renkler.dart';

void main() {
  runApp(const NotlarimApp());
}

/// Uygulama kökü. Material 3 (useMaterial3: true) + krem/pudra pembesi tema.
class NotlarimApp extends StatelessWidget {
  const NotlarimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Renkler.zemin,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Renkler.birincil,
          primary: Renkler.birincil,
          surface: Renkler.yuzey,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AcilisEkrani(),
    );
  }
}
