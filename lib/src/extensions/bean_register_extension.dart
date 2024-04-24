import 'package:dart_ddi/src/typedef/typedef.dart';

extension type RegisterFunction<BeanT extends Object>(Function register) {}

extension type CustomBeanFactory<BeanT extends Object>(
    BeanFactory<BeanT, dynamic> register) implements RegisterFunction<BeanT> {
  FutureOrBean<BeanT> call<ParameterT>(ParameterT parameter) =>
      register(parameter);
}

extension type SimpleBeanFactory<BeanT extends Object>(
    BeanRegister<BeanT> register) implements RegisterFunction<BeanT> {
  FutureOrBean<BeanT> call() => register();
}
