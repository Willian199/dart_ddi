import 'father.dart';

class Mother {
  factory Mother.fromFather(Father father) => Mother(father: father);

  Mother({required this.father});

  final Father father;
}
