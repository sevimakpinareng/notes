import 'package:flutter/material.dart';
import '../theme/renkler.dart';
import 'giris_ekrani.dart';

/// Açılış (splash) ekranı — 2 sn sonra otomatik olarak giriş ekranına geçer.
/// Future.delayed — Ders: asenkron programlama.
class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  @override
  void initState() {
    super.initState();
    _gir();
  }

  Future<void> _gir() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GirisEkrani()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Renkler.zemin,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Uygulama logosu — Container + BoxDecoration + boxShadow.
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Renkler.birincil,
                borderRadius: BorderRadius.circular(30),
                boxShadow: Renkler.pembeGolge,
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 58,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Renkler.metin,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Düşüncelerini kaydet',
              style: TextStyle(fontSize: 16, color: Renkler.metin2),
            ),
          ],
        ),
      ),
    );
  }
}
