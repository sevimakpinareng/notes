import 'package:flutter/material.dart';
import '../database/not_dao.dart';
import '../models/kategori.dart';
import '../models/not.dart';
import '../theme/renkler.dart';

/// Yeni Not / Notu Düzenle ekranı.
/// [mevcut] null ise yeni kayıt (INSERT), doluysa düzenleme (UPDATE).
class NotDuzenleEkrani extends StatefulWidget {
  final Not? mevcut;
  final int kullaniciId;
  final List<Kategori> kategoriler; // DB'den yüklenen liste
  const NotDuzenleEkrani({
    super.key,
    this.mevcut,
    required this.kullaniciId,
    required this.kategoriler,
  });

  @override
  State<NotDuzenleEkrani> createState() => _NotDuzenleEkraniState();
}

class _NotDuzenleEkraniState extends State<NotDuzenleEkrani> {
  final NotDao _dao = NotDao();
  late final TextEditingController _baslikCtrl;
  late final TextEditingController _icerikCtrl;

  int _kategoriId = 1;
  int _oncelik = 1;
  bool _onayGoster = false;

  bool get _duzenleme => widget.mevcut != null;

  @override
  void initState() {
    super.initState();
    _baslikCtrl = TextEditingController(text: widget.mevcut?.baslik ?? '');
    _icerikCtrl = TextEditingController(text: widget.mevcut?.icerik ?? '');
    // Kategori id: eğer mevcut notun kategorisi listede varsa onu seç, yoksa ilk kategori
    final ilkId =
        widget.kategoriler.isNotEmpty ? widget.kategoriler.first.kategoriId : 1;
    _kategoriId = widget.mevcut?.kategoriId ?? ilkId;
    _oncelik = widget.mevcut?.oncelik ?? 1;
    _icerikCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _baslikCtrl.dispose();
    _icerikCtrl.dispose();
    super.dispose();
  }

  bool get _gecerli =>
      _baslikCtrl.text.trim().isNotEmpty ||
      _icerikCtrl.text.trim().isNotEmpty;

  Future<void> _kaydet() async {
    if (!_gecerli) return;
    final baslik = _baslikCtrl.text.trim().isEmpty
        ? 'Başlıksız not'
        : _baslikCtrl.text.trim();
    final icerik = _icerikCtrl.text.trim();

    try {
      if (_duzenleme) {
        await _dao.guncelle(
          widget.mevcut!.kopyala(
            baslik: baslik,
            icerik: icerik,
            kategoriId: _kategoriId,
            oncelik: _oncelik,
          ),
        );
      } else {
        await _dao.ekle(Not(
          baslik: baslik,
          icerik: icerik,
          kategoriId: _kategoriId,
          kullaniciId: widget.kullaniciId,
          olusturmaTarihi: DateTime.now().toIso8601String(),
          oncelik: _oncelik,
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _hataGoster('Not kaydedilemedi. Lütfen tekrar dene.');
    }
  }

  Future<void> _sil() async {
    try {
      if (widget.mevcut?.notId != null) {
        await _dao.sil(widget.mevcut!.notId!);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _onayGoster = false);
      _hataGoster('Not silinemedi. Lütfen tekrar dene.');
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _duzenleme ? 'Notu Düzenle' : 'Yeni Not',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Renkler.metin,
              ),
            ),
            const Text(
              'Düşüncelerini burada sakla',
              style: TextStyle(fontSize: 12.5, color: Renkler.metin2),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: yatay),
            child: GestureDetector(
              onTap: _kaydet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _gecerli ? Renkler.vurgu : Renkler.seftali,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kaydet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _gecerli ? Colors.white : Renkler.metin2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _icerikBolumu(yatay),
          if (_onayGoster) _onayKatmani(),
        ],
      ),
    );
  }

  Widget _icerikBolumu(double yatay) {
    return ListView(
      padding: EdgeInsets.fromLTRB(yatay, 8, yatay, 28),
      children: <Widget>[
        // ── Kategori seçimi ──────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 4, 0, 11),
          child: Text(
            'KATEGORİ',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Renkler.metin2,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.kategoriler.map(_kategoriCipi).toList(),
        ),
        const SizedBox(height: 22),
        // ── Öncelik seçimi — DropdownButton ──────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 0, 0, 11),
          child: Text(
            'ÖNCELİK',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Renkler.metin2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: _alanKutusu(),
          child: DropdownButton<int>(
            value: _oncelik,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            onChanged: (v) => setState(() => _oncelik = v!),
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem(
                value: 0,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF8FA2B0),
                    ),
                    SizedBox(width: 10),
                    Text('Düşük'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 1,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.remove_rounded, size: 18, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Orta'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 2,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      size: 18,
                      color: Color(0xFFD4575A),
                    ),
                    SizedBox(width: 10),
                    Text('Yüksek'),
                  ],
                ),
              ),
            ],
            style: const TextStyle(fontSize: 15, color: Renkler.metin),
          ),
        ),
        const SizedBox(height: 20),
        // ── Başlık alanı ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: _alanKutusu(),
          child: Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Renkler.seftali,
                  borderRadius: BorderRadius.circular(9),
                ),
                child:
                    const Icon(Icons.title, size: 18, color: Renkler.vurgu),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _baslikCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Başlık',
                    hintStyle: TextStyle(color: Color(0xFFC3B4AE)),
                  ),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Renkler.metin,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // ── İçerik alanı + karakter sayacı ───────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: _alanKutusu(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                controller: _icerikCtrl,
                maxLines: null,
                minLines: 8,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Notunu buraya yaz...',
                  hintStyle: TextStyle(color: Color(0xFFC3B4AE)),
                ),
                style: const TextStyle(
                  fontSize: 15.5,
                  height: 1.6,
                  color: Renkler.metin,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_icerikCtrl.text.length} karakter',
                style:
                    const TextStyle(fontSize: 12.5, color: Renkler.metin2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _gecerli ? _kaydet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Renkler.birincil,
              disabledBackgroundColor: Renkler.seftali,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.save_outlined,
                  size: 20,
                  color: _gecerli ? Colors.white : Renkler.metin2,
                ),
                const SizedBox(width: 10),
                Text(
                  'Notu Kaydet',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: _gecerli ? Colors.white : Renkler.metin2,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_duzenleme) ...<Widget>[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _onayGoster = true),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Renkler.vurgu.withValues(alpha: 0.27),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.delete_outline, size: 19, color: Renkler.vurgu),
                  SizedBox(width: 8),
                  Text(
                    'Notu Sil',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Renkler.vurgu,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _kategoriCipi(Kategori k) {
    final secili = k.kategoriId == _kategoriId;
    return GestureDetector(
      onTap: () => setState(() => _kategoriId = k.kategoriId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: secili ? k.renk.withValues(alpha: 0.13) : Renkler.yuzey,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                secili ? k.renk : Renkler.metin.withValues(alpha: 0.06),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: k.renk, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              k.kategoriAd,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: secili ? k.renk : Renkler.metin2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _alanKutusu() => BoxDecoration(
        color: Renkler.yuzey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Renkler.yumusakGolge,
        border: Border.all(color: Renkler.metin.withValues(alpha: 0.06)),
      );

  // Silme onay katmanı — Stack + Positioned.fill.
  Widget _onayKatmani() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _onayGoster = false),
        child: Container(
          color: const Color(0x66382926),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(28),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Renkler.yuzey,
                borderRadius: BorderRadius.circular(24),
                boxShadow: Renkler.yumusakGolge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Renkler.vurgu.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 26,
                      color: Renkler.vurgu,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Notu sil?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Renkler.metin,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bu not kalıcı olarak silinecek.\nBu işlem geri alınamaz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: Renkler.metin2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _onayButon(
                          'Vazgeç',
                          Renkler.seftali,
                          Renkler.metin,
                          () => setState(() => _onayGoster = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _onayButon(
                          'Sil',
                          Renkler.vurgu,
                          Colors.white,
                          _sil,
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
    );
  }

  Widget _onayButon(
    String yazi,
    Color arka,
    Color metin,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: arka,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          yazi,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: metin,
          ),
        ),
      ),
    );
  }
}
