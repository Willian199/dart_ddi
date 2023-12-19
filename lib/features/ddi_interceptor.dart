class DDIInterceptor<T> {
  T aroundConstruct(T instance) {
    return instance;
  }

  T aroundDestroy(T instance) {
    return instance;
  }

  T aroundDispose(T instance) {
    return instance;
  }
}
