import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/kategori.dart';

/// SQLite veri tabanı yardımcısı — singleton.
/// Ders-9: CREATE TABLE, PRIMARY KEY, FOREIGN KEY, onUpgrade.
/// v3 şeması: kullanicilar + kategoriler + notlar + ayarlar.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();
  static Database? _db;

  Future<Database> get veritabani async {
    _db ??= await _ac();
    return _db!;
  }

  Future<Database> _ac() async {
    final yol = join(await getDatabasesPath(), 'notlarim.db');

    return openDatabase(
      yol,
      version: 4,
      onConfigure: (db) async {
        // FOREIGN KEY kısıtlarını etkinleştir.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // ── kullanicilar tablosu ─────────────────────────────────────────
        await db.execute('''
          CREATE TABLE kullanicilar (
            kullanici_id  INTEGER PRIMARY KEY AUTOINCREMENT,
            kullanici_adi TEXT NOT NULL UNIQUE,
            sifre         TEXT NOT NULL
          )
        ''');

        // ── kategoriler tablosu (PRIMARY KEY) ────────────────────────────
        await db.execute('''
          CREATE TABLE kategoriler (
            kategori_id INTEGER PRIMARY KEY,
            kategori_ad TEXT    NOT NULL,
            renk        INTEGER NOT NULL
          )
        ''');

        // ── notlar tablosu (PRIMARY KEY + 2x FOREIGN KEY) ────────────────
        await db.execute('''
          CREATE TABLE notlar (
            not_id           INTEGER PRIMARY KEY AUTOINCREMENT,
            baslik           TEXT    NOT NULL,
            icerik           TEXT    NOT NULL,
            kategori_id      INTEGER NOT NULL,
            kullanici_id     INTEGER NOT NULL,
            favori           INTEGER NOT NULL DEFAULT 0,
            oncelik          INTEGER NOT NULL DEFAULT 1,
            olusturma_tarihi TEXT    NOT NULL,
            FOREIGN KEY (kategori_id)  REFERENCES kategoriler (kategori_id),
            FOREIGN KEY (kullanici_id) REFERENCES kullanicilar (kullanici_id)
          )
        ''');

        // ── ayarlar tablosu ──────────────────────────────────────────────
        await db.execute('''
          CREATE TABLE ayarlar (
            kullanici_id        INTEGER PRIMARY KEY,
            favori_ustte        INTEGER NOT NULL DEFAULT 1,
            varsayilan_siralama INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (kullanici_id) REFERENCES kullanicilar (kullanici_id)
          )
        ''');

        // Sabit kategorileri ilk kurulumda ekle — INSERT INTO.
        for (final k in Kategori.hepsi) {
          await db.insert('kategoriler', k.toMap());
        }

        // Demo kullanıcısı ve örnek notlar (ilk açılış deneyimi için).
        const demoSifre = 'demo123';
        final demoId = await db.insert('kullanicilar', {
          'kullanici_adi': 'demo',
          'sifre': demoSifre,
        });
        await db.insert('ayarlar', {
          'kullanici_id': demoId,
          'favori_ustte': 1,
          'varsayilan_siralama': 0,
        });

        final simdi = DateTime.now();
        // 9 not · 3 favori · kategori: Kişisel 2, İş 2, Fikirler 2, Alışveriş 1, Çalışma 2
        final ornekNotlar = <Map<String, dynamic>>[
          // ── 4 gün önce ───────────────────────────────────────────────────
          {
            'baslik': 'Veri yapıları tekrarı',
            'icerik':
                'Yığın (stack), kuyruk (queue) ve bağlı liste konularını gözden geçir. '
                'Sınav soruları genellikle zaman karmaşıklığı üzerinden geliyor.',
            'kategori_id': 5,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 2,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 4)).toIso8601String(),
          },
          // ── 3 gün önce ───────────────────────────────────────────────────
          {
            'baslik': 'Alışveriş listesi',
            'icerik':
                'Domates, peynir, ekmek, yoğurt, zeytin.\nHaftaya market; faturayı da ödemeyi unutma.',
            'kategori_id': 4,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 3, hours: 4)).toIso8601String(),
          },
          {
            'baslik': 'Podcast fikri',
            'icerik':
                'Yazılım geliştirme süreçlerini sade bir dille anlatan kısa bölümler. '
                'Her bölüm 10–15 dk, haftada bir yayın. İlk konu: "Neden Flutter?"',
            'kategori_id': 3,
            'kullanici_id': demoId,
            'favori': 1,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 3)).toIso8601String(),
          },
          // ── 2 gün önce ───────────────────────────────────────────────────
          {
            'baslik': 'Müşteri görüşmesi',
            'icerik':
                'Yeni özellik talepleri belirlendi. Öncelikli başlıklar: arama filtresi, '
                'dışa aktarma ve bildirim desteği. Teknik fizibilite raporu bu hafta hazır olmalı.',
            'kategori_id': 2,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 2,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 2, hours: 6)).toIso8601String(),
          },
          {
            'baslik': 'Kitap notları',
            'icerik':
                '"Atomik Alışkanlıklar" — küçük değişimlerin bileşik etkisi. '
                'Her gün %1 iyileşme, bir yılda 37 kata çıkıyor. Alışkanlık döngüsü: ipucu → istek → yanıt → ödül.',
            'kategori_id': 1,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 0,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 2)).toIso8601String(),
          },
          // ── Dün ──────────────────────────────────────────────────────────
          {
            'baslik': 'Flutter ders özeti',
            'icerik':
                'StatefulWidget yaşam döngüsü: initState → build → dispose. '
                'setState yalnızca durum değişince çağrılır.',
            'kategori_id': 5,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
          },
          {
            'baslik': 'Uygulama fikri',
            'icerik':
                'Sesli not alıp otomatik olarak kategorilere ayıran küçük bir asistan. '
                'Sade bir arayüz, hızlı kayıt.',
            'kategori_id': 3,
            'kullanici_id': demoId,
            'favori': 1,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
          },
          // ── Bugün ────────────────────────────────────────────────────────
          {
            'baslik': 'Haftalık toplantı notları',
            'icerik':
                'Q3 hedefleri gözden geçirildi; yeni müşteri sunumu cuma gününe alındı.\n\n'
                'Tasarım ekibiyle prototip üzerinden ilerlenecek, geri bildirimler pazartesi toplanacak.',
            'kategori_id': 2,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 2,
            'olusturma_tarihi':
                simdi.subtract(const Duration(hours: 4)).toIso8601String(),
          },
          {
            'baslik': 'Hafta sonu planı',
            'icerik':
                'Cumartesi sabahı sahilde uzun bir yürüyüş, ardından küçük kahvecide oturup '
                'kitap okumak. Akşam ailecek yemek.',
            'kategori_id': 1,
            'kullanici_id': demoId,
            'favori': 1,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(hours: 2)).toIso8601String(),
          },
        ];
        for (final n in ornekNotlar) {
          await db.insert('notlar', n);
        }
      },

      onUpgrade: (db, eskiVersiyon, yeniVersiyon) async {
        // Ders-9 DB sürüm yükseltme.
        // v3→v4: yalnızca yeni kolon eklenir (ALTER TABLE) — veri korunur.
        // v1/v2→v4: yapısal değişiklik çok fazla olduğu için tablolar yeniden
        //   oluşturulur ve demo verilerle seed'lenir (ders projesi toleransı).
        if (eskiVersiyon >= 3) {
          // Sadece eksik kolonu ekle.
          await db.execute(
            'ALTER TABLE ayarlar ADD COLUMN varsayilan_siralama INTEGER NOT NULL DEFAULT 0',
          );
          return;
        }

        // v1 veya v2'den geliyorsa DROP+CREATE yolu.
        await db.execute('DROP TABLE IF EXISTS notlar');
        await db.execute('DROP TABLE IF EXISTS ayarlar');
        await db.execute('DROP TABLE IF EXISTS kullanicilar');
        await db.execute('DROP TABLE IF EXISTS kategoriler');

        await db.execute('''
          CREATE TABLE kullanicilar (
            kullanici_id  INTEGER PRIMARY KEY AUTOINCREMENT,
            kullanici_adi TEXT NOT NULL UNIQUE,
            sifre         TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE kategoriler (
            kategori_id INTEGER PRIMARY KEY,
            kategori_ad TEXT    NOT NULL,
            renk        INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notlar (
            not_id           INTEGER PRIMARY KEY AUTOINCREMENT,
            baslik           TEXT    NOT NULL,
            icerik           TEXT    NOT NULL,
            kategori_id      INTEGER NOT NULL,
            kullanici_id     INTEGER NOT NULL,
            favori           INTEGER NOT NULL DEFAULT 0,
            oncelik          INTEGER NOT NULL DEFAULT 1,
            olusturma_tarihi TEXT    NOT NULL,
            FOREIGN KEY (kategori_id)  REFERENCES kategoriler (kategori_id),
            FOREIGN KEY (kullanici_id) REFERENCES kullanicilar (kullanici_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE ayarlar (
            kullanici_id        INTEGER PRIMARY KEY,
            favori_ustte        INTEGER NOT NULL DEFAULT 1,
            varsayilan_siralama INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (kullanici_id) REFERENCES kullanicilar (kullanici_id)
          )
        ''');

        for (final k in Kategori.hepsi) {
          await db.insert('kategoriler', k.toMap());
        }

        final demoId = await db.insert('kullanicilar', {
          'kullanici_adi': 'demo',
          'sifre': 'demo123',
        });
        await db.insert('ayarlar', {
          'kullanici_id': demoId,
          'favori_ustte': 1,
          'varsayilan_siralama': 0,
        });

        final simdi = DateTime.now();
        // onUpgrade seed — onCreate ile aynı 9 not.
        final upgradeNotlar = <Map<String, dynamic>>[
          {
            'baslik': 'Veri yapıları tekrarı',
            'icerik':
                'Yığın (stack), kuyruk (queue) ve bağlı liste konularını gözden geçir. '
                'Sınav soruları genellikle zaman karmaşıklığı üzerinden geliyor.',
            'kategori_id': 5,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 2,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 4)).toIso8601String(),
          },
          {
            'baslik': 'Alışveriş listesi',
            'icerik':
                'Domates, peynir, ekmek, yoğurt, zeytin.\nHaftaya market; faturayı da ödemeyi unutma.',
            'kategori_id': 4,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 3, hours: 4)).toIso8601String(),
          },
          {
            'baslik': 'Podcast fikri',
            'icerik':
                'Yazılım geliştirme süreçlerini sade bir dille anlatan kısa bölümler. '
                'Her bölüm 10–15 dk, haftada bir yayın. İlk konu: "Neden Flutter?"',
            'kategori_id': 3,
            'kullanici_id': demoId,
            'favori': 1,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 3)).toIso8601String(),
          },
          {
            'baslik': 'Müşteri görüşmesi',
            'icerik':
                'Yeni özellik talepleri belirlendi. Öncelikli başlıklar: arama filtresi, '
                'dışa aktarma ve bildirim desteği. Teknik fizibilite raporu bu hafta hazır olmalı.',
            'kategori_id': 2,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 2,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 2, hours: 6)).toIso8601String(),
          },
          {
            'baslik': 'Kitap notları',
            'icerik':
                '"Atomik Alışkanlıklar" — küçük değişimlerin bileşik etkisi. '
                'Her gün %1 iyileşme, bir yılda 37 kata çıkıyor. Alışkanlık döngüsü: ipucu → istek → yanıt → ödül.',
            'kategori_id': 1,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 0,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 2)).toIso8601String(),
          },
          {
            'baslik': 'Flutter ders özeti',
            'icerik':
                'StatefulWidget yaşam döngüsü: initState → build → dispose. '
                'setState yalnızca durum değişince çağrılır.',
            'kategori_id': 5,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
          },
          {
            'baslik': 'Uygulama fikri',
            'icerik':
                'Sesli not alıp otomatik olarak kategorilere ayıran küçük bir asistan. '
                'Sade bir arayüz, hızlı kayıt.',
            'kategori_id': 3,
            'kullanici_id': demoId,
            'favori': 1,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
          },
          {
            'baslik': 'Haftalık toplantı notları',
            'icerik':
                'Q3 hedefleri gözden geçirildi; yeni müşteri sunumu cuma gününe alındı.\n\n'
                'Tasarım ekibiyle prototip üzerinden ilerlenecek, geri bildirimler pazartesi toplanacak.',
            'kategori_id': 2,
            'kullanici_id': demoId,
            'favori': 0,
            'oncelik': 2,
            'olusturma_tarihi':
                simdi.subtract(const Duration(hours: 4)).toIso8601String(),
          },
          {
            'baslik': 'Hafta sonu planı',
            'icerik':
                'Cumartesi sabahı sahilde uzun bir yürüyüş, ardından küçük kahvecide oturup '
                'kitap okumak. Akşam ailecek yemek.',
            'kategori_id': 1,
            'kullanici_id': demoId,
            'favori': 1,
            'oncelik': 1,
            'olusturma_tarihi':
                simdi.subtract(const Duration(hours: 2)).toIso8601String(),
          },
        ];
        for (final n in upgradeNotlar) {
          await db.insert('notlar', n);
        }
      },
    );
  }
}
