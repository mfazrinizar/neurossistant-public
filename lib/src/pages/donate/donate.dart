// under_construction.dart

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:neurossistant/src/db/payment/midtrans_api.dart';
import 'package:neurossistant/src/db/payment/payment_db_api.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/reusable_comp/language_changer.dart';
import 'package:neurossistant/src/reusable_comp/theme_changer.dart';
import 'package:neurossistant/src/reusable_func/form_validator.dart';
import 'package:neurossistant/src/reusable_func/localization_change.dart';
import 'package:neurossistant/src/reusable_func/theme_change.dart';
import 'package:neurossistant/src/theme/theme.dart';
import 'package:neurossistant/src/homepage.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  DonateState createState() => DonateState();
}

class DonateState extends State<DonatePage> {
  bool isProcessing = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController donationAmountController =
      TextEditingController();
  final TextEditingController donationMessageController =
      TextEditingController();
  bool isDarkMode = Get.isDarkMode;
  late TransactionResult transactionCallbackResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    MidtransAPI.removeTransactionFinishedCallback();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: isDarkMode
          ? ThemeClass.darkTheme.scaffoldBackgroundColor
          : ThemeClass().lightPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
            color: Colors.white,
            onPressed: () => Get.offAll(() => const HomePage())),
        title: Text(
            AppLocalizations.of(context)!.translate('donate_title1') ??
                'Donate',
            style: const TextStyle(color: Colors.white)),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.transparent : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
              ),
            ),
            child: const LanguageSwitcher(onPressed: localizationChange),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.transparent : Colors.white,
            ),
            child: ThemeSwitcher(
              color: isDarkMode
                  ? const Color.fromARGB(255, 211, 227, 253)
                  : Colors.black,
              onPressed: () {
                setState(
                  () {
                    themeChange();
                    isDarkMode = !isDarkMode;
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  child: SvgPicture.asset(
                    isDarkMode
                        ? 'assets/images/donate1_dark.svg'
                        : 'assets/images/donate1_light.svg',
                    width: width * 1,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: height * 0.33,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: ShapeDecoration(
                      color:
                          isDarkMode ? ThemeClass().darkRounded : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            topLeft: Radius.circular(50)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.05,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                        .translate('donate_subtitle1') ??
                                    'Please Fill the Form',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                        .translate('donate_desc1') ??
                                    'Your donation means so much for our kids in need\n(Donation will be managed by Neurossistant team and will be forwarded to neurodivergent kids in need)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 211, 227, 253)
                                      : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              TextFormField(
                                controller: donationAmountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                ],
                                validator: FormValidator.validatePayment,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors
                                            .black, // Change this to your desired color
                                  ),
                                  hintText: AppLocalizations.of(context)!
                                          .translate('donate_amount_hint1') ??
                                      '10000 (in IDR)',
                                  labelText: AppLocalizations.of(context)!
                                          .translate('donate_amount_label1') ??
                                      'Donation Amount',
                                  prefixIcon: Icon(Icons.favorite,
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.black),
                                ),
                              ),
                              TextFormField(
                                controller: donationMessageController,
                                validator: FormValidator.validateText,
                                style: TextStyle(
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors.black),
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 211, 227, 253)
                                        : Colors
                                            .black, // Change this to your desired color
                                  ),
                                  hintText: AppLocalizations.of(context)!
                                          .translate('donate_msg_hint1') ??
                                      'I want to donate...',
                                  labelText: AppLocalizations.of(context)!
                                          .translate('donate_msg_label1') ??
                                      'Donation Message',
                                  prefixIcon: Icon(Icons.message,
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 211, 227, 253)
                                          : Colors.black),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.05,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.grey,
                                  elevation: 5,
                                ),
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(
                                            () {
                                              isProcessing = true;
                                            },
                                          );
                                          final user =
                                              FirebaseAuth.instance.currentUser;

                                          if (user != null) {
                                            EasyLoading.show(
                                                status: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'donate_process1') ??
                                                    'Processing Payment...');
                                            MidtransAPI.initSDK(context);

                                            String displayName =
                                                user.displayName ?? "";
                                            int spaceAtIndex =
                                                displayName.indexOf(' ');

                                            // fix: Unhandled Exception: RangeError (end): Invalid value: Not in inclusive range 0..6: -1
                                            String firstName, lastName;
                                            if (spaceAtIndex != -1 &&
                                                spaceAtIndex >= 0) {
                                              firstName = displayName.substring(
                                                  0, spaceAtIndex);
                                              lastName = displayName
                                                  .substring(spaceAtIndex + 1);
                                            } else {
                                              firstName = displayName;
                                              lastName = '';
                                            }

                                            final token = await MidtransAPI
                                                .generatePaymentToken(
                                                    itemName:
                                                        "Donation for NeuroDivergent Kids",
                                                    itemDescription:
                                                        donationMessageController
                                                            .text,
                                                    priceTotal: int.parse(
                                                        donationAmountController
                                                            .text),
                                                    firstName: firstName,
                                                    lastName: lastName,
                                                    email: user.email ??
                                                        "null@email.com",
                                                    itemId: "donate",
                                                    category: "Donation");

                                            await MidtransAPI
                                                .startPaymentUiFlow(token);

                                            final result = await MidtransAPI
                                                .returnTransactionCallbackResult();

                                            final responseBody =
                                                result.toJson();

                                            if (!responseBody[
                                                    'isTransactionCanceled'] &&
                                                responseBody[
                                                        'transactionStatus'] ==
                                                    'settlement') {
                                              await PaymentDbAPI.postPayment(
                                                isProduction: false,
                                                orderId:
                                                    responseBody['orderId'],
                                                priceTotal: int.parse(
                                                    donationAmountController
                                                        .text),
                                                paymentType:
                                                    responseBody['paymentType'],
                                                transactionStatus: responseBody[
                                                    'transactionStatus'],
                                                transactionId: responseBody[
                                                    'transactionId'],
                                                itemId: "donate",
                                                category: "Donation",
                                                itemName:
                                                    "Donation for NeuroDivergent Kids",
                                                itemDescription:
                                                    donationMessageController
                                                        .text,
                                                email: user.email ??
                                                    "null@email.com",
                                                firstName: firstName,
                                                lastName: lastName,
                                                userId: user.uid,
                                                name: displayName,
                                              );
                                              if (!context.mounted) return;
                                              AwesomeDialog(
                                                dismissOnTouchOutside: false,
                                                context: context,
                                                keyboardAware: true,
                                                dismissOnBackKeyPress: false,
                                                dialogType: DialogType.success,
                                                animType: AnimType.scale,
                                                transitionAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                btnOkText: "Ok",
                                                title: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'donate_success1') ??
                                                    'Donation Success',
                                                desc: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'donate_success_desc1') ??
                                                    'Thank you for your donation. Your donation and your message has been received.',
                                                btnOkOnPress: () {
                                                  DismissType.btnOk;
                                                },
                                              ).show();
                                            } else {
                                              if (!context.mounted) return;
                                              AwesomeDialog(
                                                dismissOnTouchOutside: false,
                                                context: context,
                                                keyboardAware: true,
                                                dismissOnBackKeyPress: false,
                                                dialogType: DialogType.info,
                                                animType: AnimType.scale,
                                                transitionAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                btnOkText: "Ok",
                                                title: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'donate_canceled1') ??
                                                    'Donation Canceled',
                                                desc: AppLocalizations.of(
                                                            context)!
                                                        .translate(
                                                            'donate_canceled_desc1') ??
                                                    'You have canceled your donation or error occured.',
                                                btnOkOnPress: () {
                                                  DismissType.btnOk;
                                                },
                                              ).show();
                                            }

                                            // await Future.delayed(
                                            //     const Duration(seconds: 2));
                                            MidtransAPI
                                                .removeTransactionFinishedCallback();
                                            responseBody.clear();

                                            setState(
                                              () {
                                                isProcessing = false;
                                              },
                                            );

                                            EasyLoading.dismiss();
                                          }

                                          // Check the result
                                          // if (result['status'] == 'success') {
                                          //   // If the login was successful, navigate to HomePage
                                          //   Get.offAll(() => const HomePage());
                                          // } else {
                                          //   // If there was an error, show a message to the user
                                          //   if (!context.mounted) return;
                                          //   AwesomeDialog(
                                          //     dismissOnTouchOutside: false,
                                          //     context: context,
                                          //     keyboardAware: true,
                                          //     dismissOnBackKeyPress: false,
                                          //     dialogType: DialogType.error,
                                          //     animType: AnimType.scale,
                                          //     transitionAnimationDuration:
                                          //         const Duration(milliseconds: 200),
                                          //     btnOkText: "Ok",
                                          //     title: 'Error Occured',
                                          //     desc: result['message'],
                                          //     btnOkOnPress: () {
                                          //       DismissType.btnOk;
                                          //     },
                                          //   ).show();
                                          //   // Get.snackbar('Error: ', result['message']);
                                          // }
                                        }
                                      },
                                child: Text(
                                    '  ${AppLocalizations.of(context)!.translate('donate_button1') ?? 'Donate'}  ',
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
