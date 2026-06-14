import 'kayit.dart';
import 'kategori.dart';

/// Not modeli — Kayit soyut sınıfından türetilir (Ders-7-8 kalıtım: extends/super).
/// Nesne Tabanlı Programlama: composition (Kategori getter) + inheritance (Kayit).
class Not extends Kayit {
  final String baslik;
  final String icerik;
  final int kategoriId;   // FOREIGN KEY → kategoriler.kategori_id
  final int kullaniciId;  // FOREIGN KEY → kullanicilar.kullanici_id
  final bool favori;      // Yıldızla işaretlenen notlar
  final int oncelik;      // 0=Düşük · 1=Orta · 2=Yüksek

  const Not({
    int? notId,
    required this.baslik,
    required this.icerik,
    required this.kategoriId,
    required this.kullaniciId,
    required super.olusturmaTarihi,
    this.favori = false,
    this.oncelik = 1,
  }) : super(id: notId);

  int? get notId => id;

  // Kategoriyi DB'den yüklenen listeden çöz — statik listeye bağımlılık yok.
  Kategori kategoriIle(List<Kategori> liste) =>
      Kategori.idileBul(kategoriId, liste);

  // SELECT sonucundaki satırı (Map) Not nesnesine çevirir — factory constructor.
  factory Not.fromMap(Map<String, dynamic> m) => Not(
        notId: m['not_id'] as int?,
        baslik: m['baslik'] as String,
        icerik: m['icerik'] as String,
        kategoriId: m['kategori_id'] as int,
        kullaniciId: m['kullanici_id'] as int,
        olusturmaTarihi: m['olusturma_tarihi'] as String,
        favori: (m['favori'] as int? ?? 0) == 1,
        oncelik: m['oncelik'] as int? ?? 1,
      );

  // INSERT / UPDATE için nesneyi Map'e çevirir.
  Map<String, dynamic> toMap() => {
        if (notId != null) 'not_id': notId,
        'baslik': baslik,
        'icerik': icerik,
        'kategori_id': kategoriId,
        'kullanici_id': kullaniciId,
        'olusturma_tarihi': olusturmaTarihi,
        'favori': favori ? 1 : 0,
        'oncelik': oncelik,
      };

  // Bir alanı değiştirip yeni kopya üret (immutable güncelleme).
  Not kopyala({
    String? baslik,
    String? icerik,
    int? kategoriId,
    bool? favori,
    int? oncelik,
  }) =>
      Not(
        notId: notId,
        baslik: baslik ?? this.baslik,
        icerik: icerik ?? this.icerik,
        kategoriId: kategoriId ?? this.kategoriId,
        kullaniciId: kullaniciId,
        olusturmaTarihi: olusturmaTarihi,
        favori: favori ?? this.favori,
        oncelik: oncelik ?? this.oncelik,
      );
}
