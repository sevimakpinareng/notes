import 'package:flutter/material.dart';
import '../models/kategori.dart';
import 'db_helper.dart';

/// KategoriDao — kategoriler tablosuna erişen Data Access Object.
class KategoriDao {
  // SELECT * FROM kategoriler ORDER BY kategori_id.
  Future<List<Kategori>> hepsiniGetir() async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query('kategoriler', orderBy: 'kategori_id');
    return satirlar.map((m) => Kategori.fromMap(m)).toList();
  }

  // INSERT INTO kategoriler — id: mevcut max+1.
  Future<Kategori> ekle(String ad, Color renk) async {
    final db = await DbHelper.instance.veritabani;
    final sonuc = await db.rawQuery(
      'SELECT MAX(kategori_id) AS maks FROM kategoriler',
    );
    final yeniId = ((sonuc.first['maks'] as int?) ?? 0) + 1;
    final kategori = Kategori(yeniId, ad, renk);
    await db.insert('kategoriler', kategori.toMap());
    return kategori;
  }

  // UPDATE kategoriler.
  Future<int> guncelle(Kategori kategori) async {
    final db = await DbHelper.instance.veritabani;
    return db.update(
      'kategoriler',
      kategori.toMap(),
      where: 'kategori_id = ?',
      whereArgs: [kategori.kategoriId],
    );
  }

  // DELETE kategoriler — FK kontrolü: kullanımda olan silinemez.
  Future<int> sil(int kategoriId) async {
    final db = await DbHelper.instance.veritabani;
    return db.delete(
      'kategoriler',
      where: 'kategori_id = ?',
      whereArgs: [kategoriId],
    );
  }

  // Bu kategoride not var mı? — SELECT COUNT(*).
  Future<bool> kategoriKullaniliyorMu(int kategoriId) async {
    final db = await DbHelper.instance.veritabani;
    final sonuc = await db.rawQuery(
      'SELECT COUNT(*) AS sayi FROM notlar WHERE kategori_id = ?',
      [kategoriId],
    );
    return ((sonuc.first['sayi'] as int?) ?? 0) > 0;
  }
}
