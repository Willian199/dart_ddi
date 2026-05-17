import 'package:dart_ddi/dart_ddi.dart';

final class InterceptorResultValidator {
  const InterceptorResultValidator._();

  static BeanT ensureCompatible<BeanT extends Object>({
    required Object? value,
    required Object interceptor,
    required String lifecycle,
  }) {
    if (value is! BeanT) {
      throw IncompatibleInterceptorResultException(
        interceptor: interceptor,
        lifecycle: lifecycle,
        expectedType: BeanT,
        actualType: value?.runtimeType.toString() ?? 'Null',
      );
    }

    return value;
  }
}
