import 'package:flutter/material.dart';

/// Kategori modeli — kategoriler tablosunun bir satırını temsil eder.
class Kategori {
  final int kategoriId;
  final String kategoriAd;
  final Color renk;

  const Kategori(this.kategoriId, this.kategoriAd, this.renk);

  factory Kategori.fromMap(Map<String, dynamic> m) => Kategori(
        m['kategori_id'] as int,
        m['kategori_ad'] as String,
        Color(m['renk'] as int),
      );

  Map<String, dynamic> toMap() => {
        'kategori_id': kategoriId,
        'kategori_ad': kategoriAd,
        'renk': renk.toARGB32(),
      };

  // Verilen listeden id'ye göre kategori bul — DB listesiyle çalışır.
  static Kategori idileBul(int id, List<Kategori> liste) {
    if (liste.isEmpty) return Kategori(id, '—', const Color(0xFF9B8B86));
    return liste.firstWhere(
      (k) => k.kategoriId == id,
      orElse: () => liste.first,
    );
  }

  // Yalnızca db_helper'daki ilk seed için kullanılır.
  static const List<Kategori> hepsi = [
    Kategori(1, 'Kişisel',   Color(0xFFC98A8E)),
    Kategori(2, 'İş',        Color(0xFF8FA2B0)),
    Kategori(3, 'Fikirler',  Color(0xFFD2A266)),
    Kategori(4, 'Alışveriş', Color(0xFF9DB18C)),
    Kategori(5, 'Çalışma',   Color(0xFFAE9AC0)),
  ];
}
