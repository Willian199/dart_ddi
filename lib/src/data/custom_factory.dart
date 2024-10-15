import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

final class CustomBuilder<BeanT extends Object> {
  const CustomBuilder(
      this.clazzRegister, this.parametersType, this.returnType, this.isFuture);
  final Function clazzRegister;
  final List<Type> parametersType;
  final Type returnType;
  final bool isFuture;

  ScopeFactory<BeanT> asApplication({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>.application(
      builder: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }

  ScopeFactory<BeanT> asSession({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>.session(
      builder: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }

  ScopeFactory<BeanT> asDependent({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>.dependent(
      builder: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }

  ScopeFactory<BeanT> asSingleton({
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>.singleton(
      builder: this,
      postConstruct: postConstruct,
      decorators: decorators,
      destroyable: destroyable,
      children: children,
    );
  }
}
