/// Ayar modeli — ayarlar tablosunun bir satırını temsil eder.
/// Her kullanıcıya ait uygulama tercihleri burada saklanır.
class Ayar {
  final int kullaniciId;     // PRIMARY KEY (FK → kullanicilar)
  final bool favoriUstte;    // Favoriler listede üstte gösterilsin mi
  final int varsayilanSiralama; // 0=enYeni, 1=enEski, 2=baslikAZ, 3=oncelik

  const Ayar({
    required this.kullaniciId,
    this.favoriUstte = true,
    this.varsayilanSiralama = 0,
  });

  factory Ayar.fromMap(Map<String, dynamic> m) => Ayar(
        kullaniciId: m['kullanici_id'] as int,
        favoriUstte: (m['favori_ustte'] as int?) == 1,
        varsayilanSiralama: m['varsayilan_siralama'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'kullanici_id': kullaniciId,
        'favori_ustte': favoriUstte ? 1 : 0,
        'varsayilan_siralama': varsayilanSiralama,
      };

  Ayar kopyala({bool? favoriUstte, int? varsayilanSiralama}) => Ayar(
        kullaniciId: kullaniciId,
        favoriUstte: favoriUstte ?? this.favoriUstte,
        varsayilanSiralama: varsayilanSiralama ?? this.varsayilanSiralama,
      );
}
