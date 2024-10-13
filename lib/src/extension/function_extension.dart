import 'dart:async';

import 'package:dart_ddi/src/data/custom_factory.dart';

extension P0<BeanT extends Object> on BeanT Function() {
  List<Type> get parameters => [];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P1<BeanT extends Object, A> on BeanT Function(A) {
  List<Type> get parameters => [A];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P2<BeanT extends Object, A, B> on BeanT Function(A, B) {
  List<Type> get parameters => [A, B];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P3<BeanT extends Object, A, B, C> on BeanT Function(A, B, C) {
  List<Type> get parameters => [A, B, C];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P4<BeanT extends Object, A, B, C, D> on BeanT Function(A, B, C, D) {
  List<Type> get parameters => [A, B, C, D];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P5<BeanT extends Object, A, B, C, D, E> on BeanT Function(
    A, B, C, D, E) {
  List<Type> get parameters => [A, B, C, D, E];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P6<BeanT extends Object, A, B, C, D, E, F> on BeanT Function(
    A, B, C, D, E, F) {
  List<Type> get parameters => [A, B, C, D, E, F];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P7<BeanT extends Object, A, B, C, D, E, F, G> on BeanT Function(
    A, B, C, D, E, F, G) {
  List<Type> get parameters => [A, B, C, D, E, F, G];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P8<BeanT extends Object, A, B, C, D, E, F, G, H> on BeanT Function(
    A, B, C, D, E, F, G, H) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P9<BeanT extends Object, A, B, C, D, E, F, G, H, I> on BeanT Function(
    A, B, C, D, E, F, G, H, I) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I];
  Type get returnType => BeanT;
  CustomFactory<BeanT> get factory =>
      CustomFactory<BeanT>(this, parameters, returnType, BeanT is Future);
}

extension P10<BeanT extends Object, A, B, C, D, E, F, G, H, I, J> on BeanT
    Function(A, B, C, D, E, F, G, H, I, J) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I, J];
  Type get returnType => BeanT;
}
