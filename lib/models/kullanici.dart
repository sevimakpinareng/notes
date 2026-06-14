/// Kullanici modeli — kullanicilar tablosunun bir satırını temsil eder.
/// Nesne Tabanlı Programlama: factory constructor + toMap/fromMap.
class Kullanici {
  final int? kullaniciId; // PRIMARY KEY AUTOINCREMENT
  final String kullaniciAdi;
  final String sifre;

  const Kullanici({
    this.kullaniciId,
    required this.kullaniciAdi,
    required this.sifre,
  });

  // SELECT sonucundaki satırı nesneye çevirir — factory constructor.
  factory Kullanici.fromMap(Map<String, dynamic> m) => Kullanici(
        kullaniciId: m['kullanici_id'] as int?,
        kullaniciAdi: m['kullanici_adi'] as String,
        sifre: m['sifre'] as String,
      );

}
