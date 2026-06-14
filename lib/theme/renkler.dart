import 'package:flutter/material.dart';

/// Yumuşak krem & pudra pembesi palet sabitleri.
/// Tek merkezde tutularak tüm ekranlar aynı renkleri kullanır.
class Renkler {
  Renkler._(); // örneklenemez — yalnızca static erişim

  static const Color zemin    = Color(0xFFFBF6EF); // krem ana zemin
  static const Color yuzey    = Color(0xFFFFFDFA); // fildişi kart/yüzey
  static const Color birincil = Color(0xFFE8B4B8); // pudra pembesi (buton, FAB)
  static const Color vurgu    = Color(0xFFC98A8E); // gül kurusu (aktif durum)
  static const Color seftali  = Color(0xFFF3E0D5); // destek tonu
  static const Color metin    = Color(0xFF5B4A47); // koyu taupe (ana metin)
  static const Color metin2   = Color(0xFF9B8B86); // soluk taupe (ikincil metin)

  // Öncelik renkleri — not kartı ve detay ekranında kullanılır.
  static const Color oncelikDusuk  = Color(0xFF9DB18C); // Düşük — yeşilimsi
  static const Color oncelikOrta   = Color(0xFFD2A266); // Orta  — sarımsı
  static const Color oncelikYuksek = Color(0xFFC98A8E); // Yüksek — gül kurusu (= vurgu)

  // Tek, düşük opaklıklı yumuşak gölge — BoxDecoration ile derinlik.
  static List<BoxShadow> get yumusakGolge => const [
        BoxShadow(
          color: Color(0x14000000), // ~%8 siyah
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get pembeGolge => const [
        BoxShadow(
          color: Color(0x66C98A8E), // gül kurusu, hafif
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ];
}
