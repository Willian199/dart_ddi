import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

extension P0<BeanT extends Object> on BeanT Function() {
  List<Type> get parameters => [];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(),
      );
}

extension PF0<BeanT extends Object> on Future<BeanT> Function() {
  List<Type> get parameters => [];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P1<BeanT extends Object, A> on BeanT Function(A) {
  List<Type> get parameters => [A];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A),
      );
}

extension PF1<BeanT extends Object, A> on Future<BeanT> Function(A) {
  List<Type> get parameters => [A];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P2<BeanT extends Object, A, B> on BeanT Function(A, B) {
  List<Type> get parameters => [A, B];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B),
      );
}

extension PF2<BeanT extends Object, A, B> on Future<BeanT> Function(A, B) {
  List<Type> get parameters => [A, B];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P3<BeanT extends Object, A, B, C> on BeanT Function(A, B, C) {
  List<Type> get parameters => [A, B, C];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C),
      );
}

extension PF3<BeanT extends Object, A, B, C> on Future<BeanT> Function(
    A, B, C) {
  List<Type> get parameters => [A, B, C];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P4<BeanT extends Object, A, B, C, D> on BeanT Function(A, B, C, D) {
  List<Type> get parameters => [A, B, C, D];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D),
      );
}

extension PF4<BeanT extends Object, A, B, C, D> on Future<BeanT> Function(
    A, B, C, D) {
  List<Type> get parameters => [A, B, C, D];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P5<BeanT extends Object, A, B, C, D, E> on BeanT Function(
    A, B, C, D, E) {
  List<Type> get parameters => [A, B, C, D, E];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E),
      );
}

extension PF5<BeanT extends Object, A, B, C, D, E> on Future<BeanT> Function(
    A, B, C, D, E) {
  List<Type> get parameters => [A, B, C, D, E];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P6<BeanT extends Object, A, B, C, D, E, F> on BeanT Function(
    A, B, C, D, E, F) {
  List<Type> get parameters => [A, B, C, D, E, F];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F),
      );
}

extension PF6<BeanT extends Object, A, B, C, D, E, F> on BeanT Function(
    A, B, C, D, E, F) {
  List<Type> get parameters => [A, B, C, D, E, F];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P7<BeanT extends Object, A, B, C, D, E, F, G> on BeanT Function(
    A, B, C, D, E, F, G) {
  List<Type> get parameters => [A, B, C, D, E, F, G];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G),
      );
}

extension PF7<BeanT extends Object, A, B, C, D, E, F, G> on Future<BeanT>
    Function(A, B, C, D, E, F, G) {
  List<Type> get parameters => [A, B, C, D, E, F, G];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P8<BeanT extends Object, A, B, C, D, E, F, G, H> on BeanT Function(
    A, B, C, D, E, F, G, H) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H),
      );
}

extension PF8<BeanT extends Object, A, B, C, D, E, F, G, H> on Future<BeanT>
    Function(A, B, C, D, E, F, G, H) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P9<BeanT extends Object, A, B, C, D, E, F, G, H, I> on BeanT Function(
    A, B, C, D, E, F, G, H, I) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I),
      );
}

extension PF9<BeanT extends Object, A, B, C, D, E, F, G, H, I> on Future<BeanT>
    Function(A, B, C, D, E, F, G, H, I) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P10<BeanT extends Object, A, B, C, D, E, F, G, H, I, J> on BeanT
    Function(A, B, C, D, E, F, G, H, I, J) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I, J];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I, J),
      );
}

extension PF10<BeanT extends Object, A, B, C, D, E, F, G, H, I, J>
    on Future<BeanT> Function(A, B, C, D, E, F, G, H, I, J) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I, J];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}
