import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/settings/custom_expansion_tile.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  PaymentHistoryPageState createState() => PaymentHistoryPageState();
}

class PaymentHistoryPageState extends State<PaymentHistoryPage>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          AppLocalizations.of(context)!.translate('payment_page_title1') ??
              'Payment History',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          LanguageSwitcher(
            onPressed: localizationChange,
            textColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
          ),
          ThemeSwitcher(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white,
            onPressed: () {
              setState(
                () {
                  themeChange();
                },
              );
            },
          ),
        ],
      ),
      body: user != null
          ? FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('payment')
                  .where('customerDetails.userId', isEqualTo: user?.uid ?? "")
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error occurred, contact developer.'),
                  );
                }

                final paymentDocs = snapshot.data!.docs;

                // Filter out documents where 'transactionDetails.dateAndTime' is null
                final filteredPaymentDocs = paymentDocs.where((doc) {
                  final transactionDetails = (doc.data()
                      as Map<String, dynamic>)['transactionDetails'];
                  return transactionDetails != null &&
                      transactionDetails['dateAndTime'] != null;
                }).toList();

                // Sort the documents by 'transactionDetails.dateAndTime' in descending order
                filteredPaymentDocs.sort((a, b) {
                  final aDate =
                      (a.data() as Map<String, dynamic>)['transactionDetails']
                              ['dateAndTime']
                          .toDate();
                  final bDate =
                      (b.data() as Map<String, dynamic>)['transactionDetails']
                              ['dateAndTime']
                          .toDate();
                  return bDate.compareTo(aDate);
                });

                if (filteredPaymentDocs.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'assets/images/payment1_dark.svg'
                                : 'assets/images/payment1_light.svg',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.scaleDown,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!
                                      .translate('payment_page_empty1') ??
                                  'You have no payment history in Neurossistant app.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

//        {
//         'isProduction': isProduction,
//         'transactionDetails': {
//           'orderId': orderId,
//           'grossAmount': priceTotal,
//           'dateAndTime': DateTime.now(),
//           'paymentType': paymentType,
//           'transactionStatus': transactionStatus,
//           'transactionId': transactionId,
//         },
//         'itemDetails': {
//           'id': itemId,
//           'category': category,
//           'price': priceTotal,
//           'quantity': 1,
//           'name': itemName,
//           'itemDescription': itemDescription,
//         },
//         'customerDetails': {
//           'email': email,
//           'firstName': firstName,
//           'lastName': lastName,
//           'name': name,
//           'userId': userId,
//         },
//       },

                return ListView.builder(
                  itemCount: filteredPaymentDocs.length,
                  itemBuilder: (context, index) {
                    final payment = filteredPaymentDocs[index];

                    return CustomExpansionTile(payment: payment);
                  },
                );
              },
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/payment1_dark.svg'
                          : 'assets/images/payment1_light.svg',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.scaleDown,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'No user is signed in.\n\nPlease logout and sign in...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
