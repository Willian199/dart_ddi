abstract class PaymentService {
  double get value => 0;
}

class CreditCardPaymentService implements PaymentService {
  @override
  double get value => 100.0;
}

class PayPalPaymentService implements PaymentService {
  @override
  double get value => 200.0;
}
