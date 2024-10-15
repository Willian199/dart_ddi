import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

final class CustomFactory<BeanT extends Object> {
  const CustomFactory(
      this.clazzRegister, this.parametersType, this.returnType, this.isFuture);
  final Function clazzRegister;
  final List<Type> parametersType;
  final Type returnType;
  final bool isFuture;

  FactoryClazz<BeanT> asApplication({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>.application(
      clazzFactory: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }

  FactoryClazz<BeanT> asSession({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>.session(
      clazzFactory: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }

  FactoryClazz<BeanT> asDependent({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>.dependent(
      clazzFactory: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }

  FactoryClazz<BeanT> asSingleton({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>.singleton(
      clazzFactory: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }
}
