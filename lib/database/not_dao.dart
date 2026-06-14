import '../models/kategori.dart';
import '../models/not.dart';
import 'db_helper.dart';

/// NotDao — notlar tablosuna erişen Data Access Object.
/// Tüm metotlar kullaniciId ile filtrelenir (çok kullanıcı desteği).
class NotDao {
  // ── EKLE: INSERT INTO ──────────────────────────────────────────────────────
  Future<int> ekle(Not not) async {
    final db = await DbHelper.instance.veritabani;
    return db.insert('notlar', not.toMap());
  }

  // ── LİSTELE: SELECT * WHERE kullanici_id = ? ──────────────────────────────
  Future<List<Not>> hepsiniGetir(
    int kullaniciId, {
    String orderBy = 'favori DESC, olusturma_tarihi DESC',
  }) async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query(
      'notlar',
      where: 'kullanici_id = ?',
      whereArgs: [kullaniciId],
      orderBy: orderBy,
    );
    return satirlar.map((m) => Not.fromMap(m)).toList();
  }

  // ── KATEGORİYE GÖRE: SELECT * WHERE kullanici_id = ? AND kategori_id = ? ─
  Future<List<Not>> kategoriyeGoreGetir(
    int kullaniciId,
    int kategoriId, {
    String orderBy = 'favori DESC, olusturma_tarihi DESC',
  }) async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query(
      'notlar',
      where: 'kullanici_id = ? AND kategori_id = ?',
      whereArgs: [kullaniciId, kategoriId],
      orderBy: orderBy,
    );
    return satirlar.map((m) => Not.fromMap(m)).toList();
  }

  // ── FAVORİLER: SELECT * WHERE kullanici_id = ? AND favori = 1 ─────────────
  Future<List<Not>> favorileriGetir(
    int kullaniciId, {
    String orderBy = 'olusturma_tarihi DESC',
  }) async {
    final db = await DbHelper.instance.veritabani;
    final satirlar = await db.query(
      'notlar',
      where: 'kullanici_id = ? AND favori = 1',
      whereArgs: [kullaniciId],
      orderBy: orderBy,
    );
    return satirlar.map((m) => Not.fromMap(m)).toList();
  }

  // ── GÜNCELLE: UPDATE ───────────────────────────────────────────────────────
  Future<int> guncelle(Not not) async {
    final db = await DbHelper.instance.veritabani;
    return db.update(
      'notlar',
      not.toMap(),
      where: 'not_id = ?',
      whereArgs: [not.notId],
    );
  }

  // ── FAVORİ DEĞİŞTİR: UPDATE favori ────────────────────────────────────────
  Future<int> favoriDegistir(Not not) => guncelle(not);

  // ── SİL: DELETE ───────────────────────────────────────────────────────────
  Future<int> sil(int notId) async {
    final db = await DbHelper.instance.veritabani;
    return db.delete('notlar', where: 'not_id = ?', whereArgs: [notId]);
  }

  // ── ARAMA: LIKE WHERE kullanici_id = ? AND (baslik LIKE ? OR icerik LIKE ?)
  Future<List<Not>> ara(
    int kullaniciId,
    String anahtar, {
    String orderBy = 'favori DESC, olusturma_tarihi DESC',
  }) async {
    final db = await DbHelper.instance.veritabani;
    final desen = '%$anahtar%';
    final satirlar = await db.query(
      'notlar',
      where: 'kullanici_id = ? AND (baslik LIKE ? OR icerik LIKE ?)',
      whereArgs: [kullaniciId, desen, desen],
      orderBy: orderBy,
    );
    return satirlar.map((m) => Not.fromMap(m)).toList();
  }

  // ── TOPLAM NOT SAYISI: COUNT(*) WHERE kullanici_id = ? ────────────────────
  Future<int> toplamNotSayisi(int kullaniciId) async {
    final db = await DbHelper.instance.veritabani;
    final sonuc = await db.rawQuery(
      'SELECT COUNT(*) AS toplam FROM notlar WHERE kullanici_id = ?',
      [kullaniciId],
    );
    return (sonuc.first['toplam'] as int?) ?? 0;
  }

  // ── KATEGORİ SAYILARI: for döngüsüyle her kategori için COUNT ─────────────
  // [kategoriler] DB'den yüklenen liste — statik listeye bağımlılık yok.
  Future<Map<int, int>> kategoriSayilari(
    int kullaniciId,
    List<Kategori> kategoriler,
  ) async {
    final db = await DbHelper.instance.veritabani;
    final sayilar = <int, int>{};
    for (final k in kategoriler) {
      final sonuc = await db.rawQuery(
        'SELECT COUNT(*) AS sayi FROM notlar WHERE kullanici_id = ? AND kategori_id = ?',
        [kullaniciId, k.kategoriId],
      );
      sayilar[k.kategoriId] = (sonuc.first['sayi'] as int?) ?? 0;
    }
    return sayilar;
  }
}
