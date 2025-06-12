import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CardPaymentScreen extends StatelessWidget {
  const CardPaymentScreen({super.key});

  Future<void> _handlePayment() async {
    try {
      final billingDetails = BillingDetails(
        email: 'test@example.com',
        phone: '+221771234567',
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Inside Casa',
          customerId: 'cus_xxxx', // à récupérer depuis ton backend
          paymentIntentClientSecret: 'pi_xxxx_secret_xxxx', // depuis backend
          billingDetails: billingDetails,
          allowsDelayedPaymentMethods: true,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print("Paiement échoué: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement par carte")),
      body: Center(
        child: ElevatedButton(
          onPressed: _handlePayment,
          child: const Text("Payer maintenant"),
        ),
      ),
    );
  }
}
