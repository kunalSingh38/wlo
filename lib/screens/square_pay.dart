
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io' show Platform;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:square_in_app_payments/models.dart';
// import 'package:square_in_app_payments/in_app_payments.dart';
// import 'package:square_in_app_payments/google_pay_constants.dart'
// as google_pay_constants;

// import 'package:wlo_master/components/colors.dart';
// import 'package:wlo_master/components/config.dart';
// import 'package:wlo_master/services/shared_preferences.dart';
// import 'package:wlo_master/widgets/buy_sheet.dart';

// class SquarePay extends StatefulWidget {
//   final Object argument;

//   const SquarePay({Key key, this.argument}) : super(key: key);

//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<SquarePay> {
//   bool isLoading = true;
//   bool applePayEnabled = false;
//   bool googlePayEnabled = false;
//   String amount="";
//   String collection_qty="";
//   String product_name="";
//   String driver_name="";
//   String job_id="";
//   String vehicle_id="";
//   String product_id="";
//   String collection_vat="";
//   String collection_amount="";
//   String collection_signatory="";
//   String payment_mode="";
//   String payment_status="";
//   String email="";
//   String account_email="";
//   String po_no="";
//   String file="";
//   String file1="";

//   String bearer_token="";
//   String square_application_id="";
//   String location_id="";
//   static final GlobalKey<ScaffoldState> scaffoldKey =
//   GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     var encodedJson = json.encode(widget.argument);
//     var data = json.decode(encodedJson);
//     collection_qty = data['collection_qty'];
//     product_name = data['product_name'];
//     amount = data['amount'];
//     driver_name = data['driver_name'];
//     job_id = data['job_id'];
//     vehicle_id = data['vehicle_id'];
//     product_id = data['product_id'];
//     collection_vat = data['collection_vat'];
//     collection_amount = data['collection_amount'];
//     collection_signatory = data['collection_signatory'];
//     payment_mode = data['payment_mode'];
//     payment_status = data['payment_status'];
//     email = data['email'];
//     account_email = data['account_email'];
//     po_no = data['po_no'];
//     file = data['file'];
//     file1 = data['file1'];
//     _getUser();


//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   }
//   _getUser() async {
//     Preference().getPreferences().then((prefs) {
//       setState(() {
//         bearer_token = prefs.getString('bearer_token').toString();
//         square_application_id = prefs.getString('square_application_id').toString();
//         location_id = prefs.getString('location_id').toString();

//         print(bearer_token);
//         print(square_application_id);
//         print(location_id);
//         _initSquarePayment();
//       });
//     });
//   }
//   Future<void> _initSquarePayment() async {
//     await InAppPayments.setSquareApplicationId(square_application_id);

//     var canUseApplePay = false;
//     var canUseGooglePay = false;
//     if (Platform.isAndroid) {
//       await InAppPayments.initializeGooglePay(
//           location_id, google_pay_constants.environmentTest);
//       canUseGooglePay = await InAppPayments.canUseGooglePay;
//     } else if (Platform.isIOS) {
//       await _setIOSCardEntryTheme();
//       await InAppPayments.initializeApplePay(applePayMerchantId);
//       canUseApplePay = await InAppPayments.canUseApplePay;
//     }

//     setState(() {
//       isLoading = false;
//       applePayEnabled = canUseApplePay;
//       googlePayEnabled = canUseGooglePay;
//     });
//   }

//   Future _setIOSCardEntryTheme() async {
//     var themeConfiguationBuilder = IOSThemeBuilder();
//     themeConfiguationBuilder.saveButtonTitle = 'Pay';
//     themeConfiguationBuilder.errorColor = RGBAColorBuilder()
//       ..r = 255
//       ..g = 0
//       ..b = 0;
//     themeConfiguationBuilder.tintColor = RGBAColorBuilder()
//       ..r = 36
//       ..g = 152
//       ..b = 141;
//     themeConfiguationBuilder.keyboardAppearance = KeyboardAppearance.light;
//     themeConfiguationBuilder.messageColor = RGBAColorBuilder()
//       ..r = 114
//       ..g = 114
//       ..b = 114;

//     await InAppPayments.setIOSCardEntryTheme(themeConfiguationBuilder.build());
//   }

//   Widget build(BuildContext context) =>  Scaffold(
//           body: isLoading
//               ? Center(
//               child: CircularProgressIndicator(
//                 valueColor:
//                 AlwaysStoppedAnimation<Color>(mainBackgroundColor),
//               ))
//               : BuySheet(
//               applePayEnabled: applePayEnabled,
//               googlePayEnabled: googlePayEnabled,
//               applePayMerchantId: applePayMerchantId,
//               squareLocationId: location_id,
//               driver_name: driver_name,
//               collection_qty: collection_qty,
//               product_name: product_name,
//               amount: amount,
//               job_id: job_id,
//               vehicle_id: vehicle_id,
//               product_id: product_id,
//               collection_vat: collection_vat,
//               collection_amount: collection_amount,
//               collection_signatory: collection_signatory,
//               payment_mode: payment_mode,
//               payment_status: payment_status,
//               email: email,
//             account_email: account_email,
//             po_no: po_no,
//               file: file,
//               file1: file1,
//             bearer_token: bearer_token,
//             square_application_id: square_application_id,
//             location_id: location_id,

//           ));
// }