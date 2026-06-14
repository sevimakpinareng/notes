import '../models/kullanici.dart';
import 'db_helper.dart';

/// KullaniciDao — kullanicilar tablosuna erişen Data Access Object.
/// VERİTABANI KAYIT KONTROL konusu (Ders-9).
class KullaniciDao {
  // SELECT WHERE kullanici_adi = ? AND sifre = ?
  // Not: şifre düz metin tutuluyor; eğitim amaçlı basit doğrulama.
  Future<Kullanici?> girisDogrula(String kullaniciAdi, String sifre) async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query(
      'kullanicilar',
      where: 'kullanici_adi = ? AND sifre = ?',
      whereArgs: [kullaniciAdi, sifre],
    );
    if (satirlar.isEmpty) return null;
    return Kullanici.fromMap(satirlar.first);
  }

  // Kullanıcı adının daha önce alınıp alınmadığını kontrol et — SELECT.
  Future<bool> kullaniciAdiVarMi(String kullaniciAdi) async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query(
      'kullanicilar',
      where: 'kullanici_adi = ?',
      whereArgs: [kullaniciAdi],
    );
    return satirlar.isNotEmpty;
  }

  // Yeni kullanıcı kaydı — INSERT INTO kullanicilar + INSERT INTO ayarlar.
  Future<Kullanici?> kayitOl(String kullaniciAdi, String sifre) async {
    final db = await DbHelper.instance.veritabani;
    final id = await db.insert('kullanicilar', {
      'kullanici_adi': kullaniciAdi,
      'sifre': sifre,
    });
    // Kayıt sonrası varsayılan ayar satırı oluştur.
    await db.insert('ayarlar', {'kullanici_id': id, 'favori_ustte': 1});
    return Kullanici(kullaniciId: id, kullaniciAdi: kullaniciAdi, sifre: sifre);
  }
}
