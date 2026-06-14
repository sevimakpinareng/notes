import 'package:flutter_test/flutter_test.dart';
import 'package:notes/main.dart';

void main() {
  testWidgets('AcilisEkrani uygulama adını gösterir', (tester) async {
    await tester.pumpWidget(const NotlarimApp());
    // Splash yüklenir yüklenmez 'Notes' metni görünür olmalı.
    expect(find.text('Notes'), findsOneWidget);
    // 2 sn timer'ı bitir (fake clock) → GirisEkrani'ya geçer, DB sorgusu yok.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
