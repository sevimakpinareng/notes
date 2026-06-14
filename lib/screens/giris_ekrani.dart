import 'package:flutter/material.dart';
import '../database/kullanici_dao.dart';
import '../theme/renkler.dart';
import 'kayit_ekrani.dart';
import 'notlar_ekrani.dart';

/// Giriş ekranı — Form + TextFormField ile kullanıcı doğrulama.
/// VERİTABANI KAYIT KONTROL: girisDogrula (SELECT WHERE kullanici_adi = ? AND sifre = ?).
class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _kullaniciAdiCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  final KullaniciDao _dao = KullaniciDao();

  bool _yukleniyor = false;
  bool _sifreGizli = true;

  @override
  void dispose() {
    _kullaniciAdiCtrl.dispose();
    _sifreCtrl.dispose();
    super.dispose();
  }

  // VERİTABANI KAYIT KONTROL — girisDogrula çağrısı (SELECT WHERE ... AND ...).
  // Not: şifre düz metin; eğitim amaçlı basit doğrulama.
  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _yukleniyor = true);

    try {
      final kullanici = await _dao.girisDogrula(
        _kullaniciAdiCtrl.text.trim(),
        _sifreCtrl.text,
      );
      if (!mounted) return;

      if (kullanici == null) {
        setState(() => _yukleniyor = false);
        _hataGoster('Kullanıcı adı veya şifre hatalı.');
        return;
      }

      // Başarılı giriş — Kullanici nesnesi constructor ile NotlarEkrani'na taşınır.
      // Sayfalar arası veri transferi (Ders materyali).
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => NotlarEkrani(kullanici: kullanici)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
      _hataGoster('Giriş yapılamadı. Tekrar dene.');
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Renkler.vurgu,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final en = MediaQuery.of(context).size.width;
    final yatay = en * 0.07;

    return Scaffold(
      backgroundColor: Renkler.zemin,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: yatay, vertical: 32),
          children: <Widget>[
            const SizedBox(height: 24),
            // ── Logo ──────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Renkler.birincil,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: Renkler.pembeGolge,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 46,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Hoş Geldin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Renkler.metin,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Devam etmek için giriş yap',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Renkler.metin2),
            ),
            const SizedBox(height: 8),
            // Demo hesap bilgisi
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Renkler.seftali,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Demo: kullanıcı adı "demo" · şifre "demo123"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Renkler.metin2),
              ),
            ),
            const SizedBox(height: 32),
            // ── Form — Form + TextFormField (Ders materyali widget'ları) ─
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _alanKutusu(
                    ctrl: _kullaniciAdiCtrl,
                    ikon: Icons.person_outline_rounded,
                    ipucu: 'Kullanıcı adı',
                    dogrulama: (v) => (v == null || v.trim().isEmpty)
                        ? 'Kullanıcı adı boş olamaz'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _alanKutusu(
                    ctrl: _sifreCtrl,
                    ikon: Icons.lock_outline_rounded,
                    ipucu: 'Şifre',
                    gizli: _sifreGizli,
                    sonEk: IconButton(
                      icon: Icon(
                        _sifreGizli
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Renkler.metin2,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _sifreGizli = !_sifreGizli),
                    ),
                    dogrulama: (v) =>
                        (v == null || v.isEmpty) ? 'Şifre boş olamaz' : null,
                  ),
                  const SizedBox(height: 24),
                  // Giriş Yap butonu — ElevatedButton (Ders materyali).
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _yukleniyor ? null : _girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Renkler.birincil,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _yukleniyor
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Kayıt ol bağlantısı ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Hesabın yok mu?',
                  style: TextStyle(fontSize: 15, color: Renkler.metin2),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KayitEkrani()),
                  ),
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      fontSize: 15,
                      color: Renkler.vurgu,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _alanKutusu({
    required TextEditingController ctrl,
    required IconData ikon,
    required String ipucu,
    bool gizli = false,
    Widget? sonEk,
    String? Function(String?)? dogrulama,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Renkler.yumusakGolge,
      ),
      child: TextFormField(
        controller: ctrl,
        obscureText: gizli,
        validator: dogrulama,
        decoration: InputDecoration(
          prefixIcon: Icon(ikon, color: Renkler.metin2, size: 22),
          suffixIcon: sonEk,
          hintText: ipucu,
          hintStyle: const TextStyle(color: Renkler.metin2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC98A8E), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC98A8E), width: 1.5),
          ),
          filled: true,
          fillColor: Renkler.yuzey,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 15, color: Renkler.metin),
      ),
    );
  }
}
