// Kalıtım örneği (Ders-7-8 abstract class / extends / super).
// Ortak alanları (id, olusturmaTarihi) tutan temel soyut sınıf.
abstract class Kayit {
  final int? id;
  final String olusturmaTarihi;

  const Kayit({this.id, required this.olusturmaTarihi});
}
