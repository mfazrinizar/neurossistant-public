import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

class PaymentPage extends StatelessWidget {
  final String token;
  final MidtransSDK? midtrans;

  const PaymentPage({super.key, required this.token, required this.midtrans});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await midtrans?.startPaymentUiFlow(token: token);

              Get.back();
            },
            child: const Text('Start Payment'),
          ),
        ),
      ),
    );
  }
}
