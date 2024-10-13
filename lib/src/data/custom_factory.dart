final class CustomFactory<BeanT extends Object> {
  const CustomFactory(
      this.clazzRegister, this.parametersType, this.returnType, this.isFuture);
  final Function clazzRegister;
  final List<Type> parametersType;
  final Type returnType;
  final bool isFuture;
}
