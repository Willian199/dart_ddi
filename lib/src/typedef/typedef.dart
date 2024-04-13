import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

typedef FutureOrBool = FutureOr<bool>;

typedef FutureOrBoolCallback = FutureOrBool Function();

typedef BoolCallback = bool Function();

typedef VoidCallback = void Function();

typedef BeanDecorator<BeanT> = BeanT Function(BeanT);

typedef ListDecorator<BeanT> = List<BeanDecorator<BeanT>>;

typedef BeanInterceptor<BeanT> = DDIInterceptor<BeanT> Function();

typedef ListDDIInterceptor<BeanT> = List<BeanInterceptor<BeanT>>;

typedef BeanRegister<BeanT> = FutureOr<BeanT> Function();
