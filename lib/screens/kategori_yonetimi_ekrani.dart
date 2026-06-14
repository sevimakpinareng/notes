import 'package:flutter/material.dart';
import '../database/kategori_dao.dart';
import '../models/kategori.dart';
import '../theme/renkler.dart';

/// Kategori yönetimi ekranı — Ekle / Düzenle / Sil.
/// showDialog yerine Stack-overlay modal yaklaşımı (silme onayıyla tutarlı).
class KategoriYonetimiEkrani extends StatefulWidget {
  const KategoriYonetimiEkrani({super.key});

  @override
  State<KategoriYonetimiEkrani> createState() => _KategoriYonetimiEkraniState();
}

class _KategoriYonetimiEkraniState extends State<KategoriYonetimiEkrani> {
  final KategoriDao _dao = KategoriDao();
  List<Kategori> _kategoriler = [];
  bool _yukleniyor = true;

  // Stack overlay modal durumu
  bool _modalAcik = false;
  Kategori? _modalKategori; // null → yeni, dolu → düzenleme
  final TextEditingController _modalCtrl = TextEditingController();
  Color _modalRenk = const Color(0xFFC98A8E);

  static const List<Color> _renkSecenekleri = [
    Color(0xFFC98A8E),
    Color(0xFF8FA2B0),
    Color(0xFFD2A266),
    Color(0xFF9DB18C),
    Color(0xFFAE9AC0),
    Color(0xFFE8A87C),
    Color(0xFF7BAFC0),
    Color(0xFFBF8FB0),
  ];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _modalCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    try {
      final liste = await _dao.hepsiniGetir();
      if (!mounted) return;
      setState(() {
        _kategoriler = liste;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _yukleniyor = false);
    }
  }

  // Yeni kategori modalını aç.
  void _yeniGoster() {
    _modalCtrl.text = '';
    setState(() {
      _modalKategori = null;
      _modalRenk = _renkSecenekleri[0];
      _modalAcik = true;
    });
  }

  // Düzenleme modalını aç.
  void _duzenleGoster(Kategori k) {
    _modalCtrl.text = k.kategoriAd;
    setState(() {
      _modalKategori = k;
      _modalRenk = k.renk;
      _modalAcik = true;
    });
  }

  // Modalı kapat.
  void _modalKapat() => setState(() => _modalAcik = false);

  // INSERT (yeni) veya UPDATE (düzenleme).
  Future<void> _kaydet() async {
    final ad = _modalCtrl.text.trim();
    if (ad.isEmpty) return;
    _modalKapat();
    try {
      if (_modalKategori == null) {
        await _dao.ekle(ad, _modalRenk);
      } else {
        await _dao.guncelle(
          Kategori(_modalKategori!.kategoriId, ad, _modalRenk),
        );
      }
      if (!mounted) return;
      _yukle();
    } catch (e) {
      if (!mounted) return;
      _hataGoster(
        _modalKategori == null
            ? 'Kategori eklenemedi.'
            : 'Kategori güncellenemedi.',
      );
    }
  }

  // FK kontrolü ile sil.
  Future<void> _sil(Kategori kategori) async {
    try {
      final kullaniliyor =
          await _dao.kategoriKullaniliyorMu(kategori.kategoriId);
      if (!mounted) return;
      if (kullaniliyor) {
        _hataGoster(
            '"${kategori.kategoriAd}" kategorisinde not var; önce notları sil veya taşı.');
        return;
      }
      await _dao.sil(kategori.kategoriId);
      if (!mounted) return;
      _yukle();
    } catch (e) {
      if (!mounted) return;
      _hataGoster('Kategori silinemedi.');
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Renkler.vurgu,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
          'Kategoriler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Renkler.metin,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: yatay),
            child: GestureDetector(
              onTap: _yeniGoster,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Renkler.birincil,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Ekle',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _liste(yatay),
          // Düzenle / Ekle modal — Stack + Positioned.fill (showDialog yerine).
          if (_modalAcik) _modalKatmani(),
        ],
      ),
    );
  }

  Widget _liste(double yatay) {
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(yatay, 12, yatay, 40),
      itemCount: _kategoriler.length,
      itemBuilder: (_, i) {
        final k = _kategoriler[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Renkler.yuzey,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Renkler.yumusakGolge,
            border: Border.all(
              color: Renkler.metin.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: k.renk,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  k.kategoriAd,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Renkler.metin,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _duzenleGoster(k),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Renkler.metin2,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _sil(k),
                icon: Icon(
                  Icons.delete_outline,
                  color: Renkler.vurgu.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Modal overlay — Stack + Positioned.fill, showDialog kullanılmaz.
  Widget _modalKatmani() {
    final bool yeniMod = _modalKategori == null;
    return Positioned.fill(
      child: GestureDetector(
        onTap: _modalKapat,
        child: Container(
          color: const Color(0x66382926),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Renkler.yuzey,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: Renkler.yumusakGolge,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      yeniMod ? 'Yeni Kategori' : 'Kategoriyi Düzenle',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Renkler.metin,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Kategori adı girişi — TextField.
                    Container(
                      decoration: BoxDecoration(
                        color: Renkler.zemin,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Renkler.metin.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _modalCtrl,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Kategori adı',
                          hintStyle: TextStyle(color: Renkler.metin2),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Renkler.metin,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Renk Seç',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Renkler.metin2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Renk paleti — GestureDetector + Container (setState ile seçim).
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _renkSecenekleri.map((renk) {
                        final secili =
                            renk.toARGB32() == _modalRenk.toARGB32();
                        return GestureDetector(
                          onTap: () => setState(() => _modalRenk = renk),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: renk,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secili
                                    ? Renkler.metin
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: secili
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _modalButon(
                            'Vazgeç',
                            Renkler.seftali,
                            Renkler.metin,
                            _modalKapat,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _modalButon(
                            yeniMod ? 'Ekle' : 'Kaydet',
                            Renkler.vurgu,
                            Colors.white,
                            _kaydet,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalButon(
    String yazi,
    Color arka,
    Color metin,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: arka,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          yazi,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: metin,
          ),
        ),
      ),
    );
  }
}
