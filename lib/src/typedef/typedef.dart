import 'dart:async';

typedef FutureOrBool = FutureOr<bool>;

typedef FutureOrBoolCallback = FutureOrBool Function();

typedef BoolCallback = bool Function();

typedef VoidCallback = void Function();

typedef BeanDecorator<BeanT> = BeanT Function(BeanT);

typedef ListDecorator<BeanT> = List<BeanDecorator<BeanT>>;

typedef BeanRegister<BeanT> = FutureOr<BeanT> Function();
