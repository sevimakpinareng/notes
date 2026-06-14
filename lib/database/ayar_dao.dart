import '../models/ayar.dart';
import 'db_helper.dart';

/// AyarDao — ayarlar tablosuna erişen Data Access Object.
class AyarDao {
  // SELECT FROM ayarlar WHERE kullanici_id = ?.
  Future<Ayar> getir(int kullaniciId) async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query(
      'ayarlar',
      where: 'kullanici_id = ?',
      whereArgs: [kullaniciId],
    );
    if (satirlar.isEmpty) return Ayar(kullaniciId: kullaniciId);
    return Ayar.fromMap(satirlar.first);
  }

  // UPDATE ayarlar.
  Future<int> guncelle(Ayar ayar) async {
    final db = await DbHelper.instance.veritabani;
    return db.update(
      'ayarlar',
      ayar.toMap(),
      where: 'kullanici_id = ?',
      whereArgs: [ayar.kullaniciId],
    );
  }
}
