import 'package:dart_ddi/dart_ddi.dart';

final class SpyStrategy implements DDIStrategy {
  SpyStrategy(this._delegate);

  final DDIStrategy _delegate;
  int setFactoryCallCount = 0;

  @override
  ({DDIBaseFactory<BeanT> factory, Object context})?
      getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
    Object? contextQualifier,
  }) {
    return _delegate.getFactory<BeanT>(
      qualifier: qualifier,
      fallback: fallback,
      contextQualifier: contextQualifier,
    );
  }

  @override
  Object get currentContext => _delegate.currentContext;

  @override
  bool get hasContext => _delegate.hasContext;

  @override
  void createContext(Object name) => _delegate.createContext(name);

  @override
  bool hasContextQualifier(Object name) => _delegate.hasContextQualifier(name);

  @override
  void freezeContext(Object name) => _delegate.freezeContext(name);

  @override
  void unfreezeContext(Object name) => _delegate.unfreezeContext(name);

  @override
  bool isContextFrozen(Object name) => _delegate.isContextFrozen(name);

  @override
  Iterable<Object> contextDestroyOrder(Object name) =>
      _delegate.contextDestroyOrder(name);

  @override
  bool contextHasDestroyBlockers(Object name) =>
      _delegate.contextHasDestroyBlockers(name);

  @override
  void destroyContext(Object name) => _delegate.destroyContext(name);

  @override
  void setFactory(Object key, DDIBaseFactory<Object> value, {Object? context}) {
    setFactoryCallCount++;
    _delegate.setFactory(key, value, context: context);
  }

  @override
  Iterable<Object> get keys => _delegate.keys;

  @override
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> entries(
      {Object? context}) {
    return _delegate.entries(context: context);
  }

  @override
  bool get isEmpty => _delegate.isEmpty;

  @override
  int get length => _delegate.length;

  @override
  DDIBaseFactory<Object>? removeFactory(Object? key, {Object? context}) {
    return _delegate.removeFactory(key, context: context);
  }
}
