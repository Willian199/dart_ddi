import 'mother.dart';

class Father {
  factory Father.fromMother(Mother mother) => Father(mother: mother);

  Father({required this.mother});

  final Mother mother;
}
