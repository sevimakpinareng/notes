import 'package:flutter/material.dart';
import '../database/kullanici_dao.dart';
import '../models/kullanici.dart';
import '../theme/renkler.dart';
import 'notlar_ekrani.dart';

/// Kayıt ekranı — yeni kullanıcı oluşturma.
/// Form + TextFormField — boş alan ve şifre eşleşme doğrulaması.
class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _kullaniciAdiCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  final _sifreTekrarCtrl = TextEditingController();
  final KullaniciDao _dao = KullaniciDao();

  bool _yukleniyor = false;
  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;

  @override
  void dispose() {
    _kullaniciAdiCtrl.dispose();
    _sifreCtrl.dispose();
    _sifreTekrarCtrl.dispose();
    super.dispose();
  }

  // INSERT INTO kullanicilar — kullaniciAdiVarMi ile önce tekrar kontrolü.
  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _yukleniyor = true);

    try {
      final adVar =
          await _dao.kullaniciAdiVarMi(_kullaniciAdiCtrl.text.trim());
      if (!mounted) return;

      if (adVar) {
        setState(() => _yukleniyor = false);
        _hataGoster('Bu kullanıcı adı zaten alınmış.');
        return;
      }

      final Kullanici? kullanici = await _dao.kayitOl(
        _kullaniciAdiCtrl.text.trim(),
        _sifreCtrl.text,
      );
      if (!mounted) return;
      if (kullanici == null) {
        setState(() => _yukleniyor = false);
        _hataGoster('Kayıt oluşturulamadı. Tekrar dene.');
        return;
      }

      // Başarılı kayıt — NotlarEkrani'na constructor ile kullanici taşınır.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => NotlarEkrani(kullanici: kullanici)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
      _hataGoster('Kayıt oluşturulamadı. Tekrar dene.');
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
          'Hesap Oluştur',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Renkler.metin,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: yatay, vertical: 16),
          children: <Widget>[
            const SizedBox(height: 8),
            // ── Form ─────────────────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _etiket('Kullanıcı Adı'),
                  const SizedBox(height: 8),
                  _alanKutusu(
                    ctrl: _kullaniciAdiCtrl,
                    ikon: Icons.person_outline_rounded,
                    ipucu: 'Kullanıcı adı seç',
                    dogrulama: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Kullanıcı adı boş olamaz';
                      }
                      if (v.trim().length < 3) {
                        return 'En az 3 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _etiket('Şifre'),
                  const SizedBox(height: 8),
                  _alanKutusu(
                    ctrl: _sifreCtrl,
                    ikon: Icons.lock_outline_rounded,
                    ipucu: 'Şifre belirle',
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
                    dogrulama: (v) {
                      if (v == null || v.isEmpty) return 'Şifre boş olamaz';
                      if (v.length < 6) return 'En az 6 karakter olmalı';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _etiket('Şifre Tekrar'),
                  const SizedBox(height: 8),
                  _alanKutusu(
                    ctrl: _sifreTekrarCtrl,
                    ikon: Icons.lock_outline_rounded,
                    ipucu: 'Şifreyi tekrar gir',
                    gizli: _sifreTekrarGizli,
                    sonEk: IconButton(
                      icon: Icon(
                        _sifreTekrarGizli
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Renkler.metin2,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
                    ),
                    dogrulama: (v) {
                      if (v == null || v.isEmpty) return 'Şifre boş olamaz';
                      if (v != _sifreCtrl.text) return 'Şifreler eşleşmiyor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _yukleniyor ? null : _kayitOl,
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
                              'Kayıt Ol',
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
          ],
        ),
      ),
    );
  }

  Widget _etiket(String yazi) => Text(
        yazi,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Renkler.metin2,
          letterSpacing: 0.3,
        ),
      );

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
