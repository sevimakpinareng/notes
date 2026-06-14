import 'package:flutter/material.dart';
import '../database/ayar_dao.dart';
import '../models/ayar.dart';
import '../models/kullanici.dart';
import '../theme/renkler.dart';
import 'giris_ekrani.dart';
import 'kategori_yonetimi_ekrani.dart';

/// Ayarlar ekranı — kullanıcı tercihlerini yönetir.
/// Switch widget'ı (Ders materyali) + çıkış butonu.
class AyarlarEkrani extends StatefulWidget {
  final Kullanici kullanici;
  const AyarlarEkrani({super.key, required this.kullanici});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  final AyarDao _dao = AyarDao();
  Ayar? _ayar;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final ayar = await _dao.getir(widget.kullanici.kullaniciId!);
      if (!mounted) return;
      setState(() {
        _ayar = ayar;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
    }
  }

  // Switch değişince DB güncelle.
  Future<void> _favoriUstteDegistir(bool deger) async {
    if (_ayar == null) return;
    final yeni = _ayar!.kopyala(favoriUstte: deger);
    setState(() => _ayar = yeni);
    try {
      await _dao.guncelle(yeni);
    } catch (e) {
      if (!mounted) return;
      setState(() => _ayar = _ayar!.kopyala(favoriUstte: !deger));
    }
  }

  // Radio değişince DB güncelle — varsayilan_siralama UPDATE.
  Future<void> _siralaDegistir(int deger) async {
    if (_ayar == null) return;
    final yeni = _ayar!.kopyala(varsayilanSiralama: deger);
    setState(() => _ayar = yeni);
    try {
      await _dao.guncelle(yeni);
    } catch (e) {
      if (!mounted) return;
      setState(() => _ayar = _ayar!.kopyala(varsayilanSiralama: _ayar!.varsayilanSiralama));
    }
  }

  // Çıkış Yap — tüm sayfaları temizleyip GirisEkrani'na git.
  void _cikisYap() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const GirisEkrani()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final en = MediaQuery.of(context).size.width;
    final yatay = en * 0.05;

    return Scaffold(
      backgroundColor: Renkler.zemin,
      appBar: AppBar(
        backgroundColor: Renkler.zemin,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: yatay),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Renkler.yuzey,
                shape: BoxShape.circle,
                boxShadow: Renkler.yumusakGolge,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Renkler.metin,
              ),
            ),
          ),
        ),
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Renkler.metin,
          ),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(yatay, 16, yatay, 40),
              children: <Widget>[
                // ── Kullanıcı bilgisi ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _kutu(),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Renkler.birincil.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Renkler.vurgu,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.kullanici.kullaniciAdi,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Renkler.metin,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Oturum açık',
                            style: TextStyle(
                              fontSize: 13,
                              color: Renkler.metin2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bolumBaslik('GÖRÜNÜM'),
                const SizedBox(height: 10),
                // ── Favoriler en üstte Switch ────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: _kutu(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Favoriler en üstte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Renkler.metin,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Yıldızlı notlar listenin başında görünür',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Renkler.metin2,
                            ),
                          ),
                        ],
                      ),
                      // Switch — Ders materyalindeki etkileşimli widget.
                      Switch(
                        value: _ayar?.favoriUstte ?? true,
                        onChanged: _favoriUstteDegistir,
                        activeThumbColor: Renkler.vurgu,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bolumBaslik('VARSAYILAN SIRALAMA'),
                const SizedBox(height: 10),
                // Radio — Ders materyalindeki etkileşimli widget (Radio grubu).
                Container(
                  decoration: _kutu(),
                  child: Column(
                    children: <Widget>[
                      _siralamaRadio('En Yeni', 0),
                      _ayrac(),
                      _siralamaRadio('En Eski', 1),
                      _ayrac(),
                      _siralamaRadio('Başlık A–Z', 2),
                      _ayrac(),
                      _siralamaRadio('Önceliğe Göre', 3),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _bolumBaslik('YÖNETİM'),
                const SizedBox(height: 10),
                // ── Kategorileri Yönet ───────────────────────────────────
                _ayarSatiri(
                  ikon: Icons.label_outline_rounded,
                  yazi: 'Kategorileri Yönet',
                  aciklama: 'Kategorileri düzenle, ekle veya sil',
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const KategoriYonetimiEkrani(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // ── Çıkış Yap ────────────────────────────────────────────
                GestureDetector(
                  onTap: _cikisYap,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Renkler.vurgu.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: Renkler.vurgu,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Çıkış Yap',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Renkler.vurgu,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _ayarSatiri({
    required IconData ikon,
    required String yazi,
    required String aciklama,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: _kutu(),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Renkler.seftali,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(ikon, size: 20, color: Renkler.vurgu),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    yazi,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: Renkler.metin,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aciklama,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Renkler.metin2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Renkler.metin2,
            ),
          ],
        ),
      ),
    );
  }

  // Özel radio satırı — Container + BoxDecoration ile (izin verilen widget'lar).
  // Radio widget'ının görünümü elle çizilir; GestureDetector ile dokunma algılanır.
  Widget _siralamaRadio(String yazi, int deger) {
    final secili = (_ayar?.varsayilanSiralama ?? 0) == deger;
    return GestureDetector(
      onTap: () => _siralaDegistir(deger),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: <Widget>[
            // Daire gösterge — Container + BoxDecoration.circle.
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secili ? Renkler.vurgu : Colors.transparent,
                border: Border.all(
                  color: secili ? Renkler.vurgu : Renkler.metin2,
                  width: 2,
                ),
              ),
              child: secili
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Text(
              yazi,
              style: TextStyle(
                fontSize: 15,
                color: secili ? Renkler.vurgu : Renkler.metin,
                fontWeight:
                    secili ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ayrac() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        color: Renkler.metin.withValues(alpha: 0.06),
      );

  Widget _bolumBaslik(String baslik) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 4),
        child: Text(
          baslik,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Renkler.metin2,
          ),
        ),
      );

  BoxDecoration _kutu() => BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Renkler.yumusakGolge,
        border: Border.all(color: Renkler.metin.withValues(alpha: 0.06)),
      );
}
