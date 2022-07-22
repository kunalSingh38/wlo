/*
 Copyright 2018 Square Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';
// import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
// import 'package:square_in_app_payments/models.dart';
// import 'package:square_in_app_payments/in_app_payments.dart';
// import 'package:square_in_app_payments/google_pay_constants.dart'
// as google_pay_constants;
import 'package:wlo_master/components/colors.dart';
import 'package:wlo_master/components/config.dart';
import 'package:wlo_master/components/transaction_service.dart';
import 'package:http/http.dart' as http;
import 'package:wlo_master/services/shared_preferences.dart';
import '../constants.dart';
import 'cookie_button.dart';
import 'dialog_modal.dart';
import 'package:http_parser/http_parser.dart';
// We use a custom modal bottom sheet to override the default height (and remove it).
import 'modal_bottom_sheet.dart' as custom_modal_bottom_sheet;
import 'order_sheet.dart';

enum ApplePayStatus { success, fail, unknown }

class BuySheet extends StatefulWidget {
  final bool applePayEnabled;
  final bool googlePayEnabled;
  final String squareLocationId;
  final String applePayMerchantId;
  final String driver_name;
  final String collection_qty;
  final String product_name;
  final String amount;
  final String job_id;
  final String vehicle_id;
  final String product_id;
  final String collection_vat;
  final String collection_amount;
  final String collection_signatory;
  final String payment_mode;
  final String payment_status;
  final String file;
  final String file1;
  final String bearer_token;
  final String square_application_id;
  final String location_id;
  final String email;
  final String account_email;
  final String po_no;
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  BuySheet({
    this.applePayEnabled,
    this.googlePayEnabled,
    this.applePayMerchantId,
    this.squareLocationId,
    this.driver_name,
    this.collection_qty,
    this.product_name,
    this.amount,
    this.job_id,
    this.vehicle_id,
    this.product_id,
    this.collection_vat,
    this.collection_amount,
    this.collection_signatory,
    this.payment_mode,
    this.payment_status,
    this.file,
    this.file1,
    this.bearer_token,
    this.square_application_id,
    this.location_id,
    this.email,
    this.account_email,
    this.po_no,
  });

  @override
  BuySheetState createState() => BuySheetState();
}

class BuySheetState extends State<BuySheet> {
  ApplePayStatus _applePayStatus = ApplePayStatus.unknown;
  bool _loading = false;
  bool get _chargeServerHostReplaced => chargeServerHost != "REPLACE_ME";

  bool get _squareLocationSet => widget.squareLocationId != "REPLACE_ME";

  bool get _applePayMerchantIdSet => widget.applePayMerchantId != "REPLACE_ME";
  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText2 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalText3 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));
  File fileImg;
  File fileImg1;
  var access_token;

  void _showOrderSheet() async {
    var selection =
        await custom_modal_bottom_sheet.showModalBottomSheet<PaymentType>(
            context: BuySheet.scaffoldKey.currentState.context,
            builder: (context) => OrderSheet(
                  applePayEnabled: widget.applePayEnabled,
                  googlePayEnabled: widget.googlePayEnabled,
                  driver_name: widget.driver_name,
                  product_name: widget.product_name,
                  amount: widget.amount,
                ));

    switch (selection) {
      /* case PaymentType.giftcardPayment:
      // call _onStartGiftCardEntryFlow to start Gift Card Entry.
        await _onStartGiftCardEntryFlow();
        break;*/
      case PaymentType.cardPayment:
        // call _onStartCardEntryFlow to start Card Entry without buyer verification (SCA)
        await _onStartCardEntryFlow();
        // OR call _onStartCardEntryFlowWithBuyerVerification to start Card Entry with buyer verification (SCA)
        // NOTE this requires _squareLocationSet to be set
        // await _onStartCardEntryFlowWithBuyerVerification();
        break;
      /*  case PaymentType.buyerVerification:
        await _onStartBuyerVerificationFlow();
        break;*/
      case PaymentType.googlePay:
        if (_squareLocationSet && widget.googlePayEnabled) {
          // _onStartGooglePay();
        } else {
          _showSquareLocationIdNotSet();
        }
        break;
      case PaymentType.applePay:
        if (_applePayMerchantIdSet && widget.applePayEnabled) {
          // _onStartApplePay();
        } else {
          _showapplePayMerchantIdNotSet();
        }
        break;
    }
  }

  Future<void> printCurlCommand(String nonce, String verificationToken) async {
    var hostUrl = 'https://connect.squareup.com';
    if (widget.square_application_id.startsWith('sandbox')) {
      hostUrl = 'https://connect.squareupsandbox.com';
    }
    var uuid = Uuid().v4();

    if (verificationToken == null) {
      print('curl --request POST $hostUrl/v2/payments \\'
          '--header \"Content-Type: application/json\" \\'
          '--header \"Authorization: Bearer YOUR_ACCESS_TOKEN\" \\'
          '--header \"Accept: application/json\" \\'
          '--data \'{'
          '\"idempotency_key\": \"$uuid\",'
          '\"amount_money\": {'
          '\"amount\": ${widget.amount},'
          '\"currency\": \"GBP\"},'
          '\"source_id\": \"$nonce\"'
          '}\'');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + widget.bearer_token,
      };
      var response = await http.post(
        Uri.parse("$hostUrl/v2/payments"),
        body: jsonEncode({
          "idempotency_key": uuid,
          "amount_money": {
            "amount": int.parse(widget.amount) * 100,
            "currency": "GBP"
          },
          "source_id": nonce,
        }),
        headers: headers,
      );
      print(jsonEncode({
        "idempotency_key": uuid,
        "amount_money": {
          "amount": int.parse(widget.amount) * 100,
          "currency": "GBP"
        },
        "source_id": nonce,
      }));
      var data = json.decode(response.body);
      print(data);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Payment done successfully - " +
                data['payment']['id'].toString(),
            toastLength: Toast.LENGTH_SHORT);

        final decodedBytes = base64Decode(widget.file);
        final decodedBytes1 = base64Decode(widget.file1);
        final directory = await getApplicationDocumentsDirectory();
        fileImg = File('${directory.path}/testImage.png');
        fileImg1 = File('${directory.path}/testImage1.png');
        print(fileImg.path);
        print(fileImg1.path);
        fileImg.writeAsBytesSync(List.from(decodedBytes));
        fileImg1.writeAsBytesSync(List.from(decodedBytes1));

        setState(() {
          _loading = true;
        });
        Map<String, String> headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer $access_token',
        };
        final mimeTypeData =
            lookupMimeType(fileImg.path, headerBytes: [0xFF, 0xD8]).split('/');
        final mimeTypeData1 =
            lookupMimeType(fileImg1.path, headerBytes: [0xFF, 0xD8]).split('/');

        var uri = Uri.parse(URL + "/job-collection/create");
        print(uri);
        final uploadRequest = http.MultipartRequest('POST', uri);
        final file = await http.MultipartFile.fromPath(
            'driver_signature', fileImg.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
        final file1 = await http.MultipartFile.fromPath(
            'customer_signature', fileImg1.path,
            contentType: MediaType(mimeTypeData1[0], mimeTypeData1[1]));

        uploadRequest.headers.addAll(headers);
        uploadRequest.fields['job_id'] = widget.job_id;
        uploadRequest.fields['vehicle_id'] = widget.vehicle_id;
        uploadRequest.fields['product_id'] = widget.product_id;
        uploadRequest.fields['collection_qty'] = widget.collection_qty;
        uploadRequest.fields['collection_vat'] = widget.collection_vat;
        uploadRequest.fields['collection_amount'] = widget.collection_amount;
        uploadRequest.fields['collection_signatory'] =
            widget.collection_signatory;
        uploadRequest.fields['payment_mode'] = widget.payment_mode;
        uploadRequest.fields['payment_status'] = widget.payment_status;
        uploadRequest.fields['payment[txn_id]'] = data['payment']['id'];
        uploadRequest.fields['payment[order_id]'] = data['payment']['order_id'];
        uploadRequest.fields['payment[amount]'] = widget.amount;
        uploadRequest.fields['email'] = widget.email;
        uploadRequest.fields['account_email'] = widget.account_email;
        uploadRequest.fields['po_no'] = widget.po_no;

        uploadRequest.files.add(file);
        uploadRequest.files.add(file1);

        print(uploadRequest.fields);
        final streamedResponse = await uploadRequest.send();
        final response = await http.Response.fromStream(streamedResponse);

        try {
          print("><>>>>>>>>>>>" + response.statusCode.toString());
          print("><>>>>>>>>>>>" + response.body);
          if (response.statusCode == 201) {
            setState(() {
              _loading = false;
            });
            var data = json.decode(response.body);
            Fluttertoast.showToast(msg: 'Created Successfully');

            Navigator.pushNamed(
              context,
              '/successful-screen',
              arguments: <String, String>{
                'collection_qty': data['data']['collection_qty'].toString(),
                'collection_vat': data['data']['collection_vat'].toString(),
                'collection_amount':
                    data['data']['collection_amount'].toString(),
                'collection_number':
                    data['data']['collection_number'].toString(),
                'collection_date': data['data']['collection_date'].toString(),
                'consignment_no': data['data']['consignment']
                        ['consignment_number']
                    .toString(),
                'product_info':
                    data['data']['product']['product_name'].toString() +
                        " - " +
                        data['data']['product']['product_ewc'].toString(),
              },
            );
          } else if (response.statusCode == 401) {
            setState(() {
              _loading = false;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.getKeys();
            for (String key in prefs.getKeys()) {
              if (key != "mDateKey") {
                prefs.remove(key);
              }
            }
            Navigator.pushReplacementNamed(context, '/login');
          } else if (response.statusCode == 403) {
            setState(() {
              _loading = false;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.getKeys();
            for (String key in prefs.getKeys()) {
              if (key != "mDateKey") {
                prefs.remove(key);
              }
            }
            Navigator.pushReplacementNamed(context, '/login');
          } else {}
        } catch (e) {
          print(e);
        }
      }
    } else {
      print('curl --request POST $hostUrl/v2/payments \\'
          '--header \"Content-Type: application/json\" \\'
          '--header \"Authorization: Bearer YOUR_ACCESS_TOKEN\" \\'
          '--header \"Accept: application/json\" \\'
          '--data \'{'
          '\"idempotency_key\": \"$uuid\",'
          '\"amount_money\": {'
          '\"amount\": $cookieAmount,'
          '\"currency\": \"GBP\"},'
          '\"source_id\": \"$nonce\",'
          '\"verification_token\": \"$verificationToken\"'
          '}\'');
    }
  }

  String html_currency_code = "";
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        html_currency_code = prefs.getString('html_currency_code').toString();
      });
    });
  }

  void _showUrlNotSetAndPrintCurlCommand(String nonce,
      {String verificationToken}) {
    String title;
    if (verificationToken != null) {
      title = "Nonce and verification token generated but not charged";
    } else {
      title = "Nonce generated but not charged";
    }
    /*showAlertDialog(
        context: BuySheet.scaffoldKey.currentContext,
        title: title,
        description:
            "Check your console for a CURL command to charge the nonce, or replace CHARGE_SERVER_HOST with your server host.");*/
    printCurlCommand(nonce, verificationToken);
  }

  void _showSquareLocationIdNotSet() {
    showAlertDialog(
        context: BuySheet.scaffoldKey.currentContext,
        title: "Missing Square Location ID",
        description:
            "To request a Google Pay nonce, replace squareLocationId in main.dart with a Square Location ID.");
  }

  void _showapplePayMerchantIdNotSet() {
    showAlertDialog(
        context: BuySheet.scaffoldKey.currentContext,
        title: "Missing Apple Merchant ID",
        description:
            "To request an Apple Pay nonce, replace applePayMerchantId in main.dart with an Apple Merchant ID.");
  }

  void _onCardEntryComplete() {
    if (_chargeServerHostReplaced) {
      showAlertDialog(
          context: BuySheet.scaffoldKey.currentContext,
          title: "Your order was successful",
          description:
              "Go to your Square dashboard to see this order reflected in the sales tab.");
    }
  }

  // void _onCardEntryCardNonceRequestSuccess(CardDetails result) async {
  //   print(result);
  //   if (!_chargeServerHostReplaced) {
  //     InAppPayments.completeCardEntry(
  //         onCardEntryComplete: _onCardEntryComplete);
  //     _showUrlNotSetAndPrintCurlCommand(result.nonce);
  //     return;
  //   }
  //   try {
  //     await chargeCard(result);
  //     InAppPayments.completeCardEntry(
  //         onCardEntryComplete: _onCardEntryComplete);
  //   } on ChargeException catch (ex) {
  //     InAppPayments.showCardNonceProcessingError(ex.errorMessage);
  //   }
  // }

  Future<void> _onStartCardEntryFlow() async {
    // await InAppPayments.startCardEntryFlow(
    //     onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
    //     onCardEntryCancel: _onCancelCardEntryFlow,
    //     collectPostalCode: true);
  }

  Future<void> _onStartGiftCardEntryFlow() async {
    // await InAppPayments.startGiftCardEntryFlow(
    //     onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
    //     onCardEntryCancel: _onCancelCardEntryFlow);
  }

  void _onCancelCardEntryFlow() {
    _showOrderSheet();
  }

  // void _onStartGooglePay() async {
  //   try {
  //     await InAppPayments.requestGooglePayNonce(
  //         priceStatus: google_pay_constants.totalPriceStatusFinal,
  //         price: getCookieAmount(),
  //         currencyCode: 'USD',
  //         onGooglePayNonceRequestSuccess: _onGooglePayNonceRequestSuccess,
  //         onGooglePayNonceRequestFailure: _onGooglePayNonceRequestFailure,
  //         onGooglePayCanceled: onGooglePayEntryCanceled);
  //   } on PlatformException catch (ex) {
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Failed to start GooglePay",
  //         description: ex.toString());
  //   }
  // }

  // void _onGooglePayNonceRequestSuccess(CardDetails result) async {
  //   if (!_chargeServerHostReplaced) {
  //     _showUrlNotSetAndPrintCurlCommand(result.nonce);
  //     return;
  //   }
  //   try {
  //     await chargeCard(result);
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Your order was successful",
  //         description:
  //             "Go to your Square dashbord to see this order reflected in the sales tab.");
  //   } on ChargeException catch (ex) {
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Error processing GooglePay payment",
  //         description: ex.errorMessage);
  //   }
  // }

  // void _onGooglePayNonceRequestFailure(ErrorInfo errorInfo) {
  //   showAlertDialog(
  //       context: BuySheet.scaffoldKey.currentContext,
  //       title: "Failed to request GooglePay nonce",
  //       description: errorInfo.toString());
  // }

  void onGooglePayEntryCanceled() {
    _showOrderSheet();
  }

  // void _onStartApplePay() async {
  //   try {
  //     await InAppPayments.requestApplePayNonce(
  //         price: getCookieAmount(),
  //         summaryLabel: 'WLO',
  //         countryCode: 'GBP',
  //         currencyCode: '£',
  //         paymentType: ApplePayPaymentType.finalPayment,
  //         onApplePayNonceRequestSuccess: _onApplePayNonceRequestSuccess,
  //         onApplePayNonceRequestFailure: _onApplePayNonceRequestFailure,
  //         onApplePayComplete: _onApplePayEntryComplete);
  //   } on PlatformException catch (ex) {
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Failed to start ApplePay",
  //         description: ex.toString());
  //   }
  // }

  // void _onBuyerVerificationSuccess(BuyerVerificationDetails result) async {
  //   if (!_chargeServerHostReplaced) {
  //     _showUrlNotSetAndPrintCurlCommand(result.nonce,
  //         verificationToken: result.token);
  //     return;
  //   }

  //   try {
  //     await chargeCardAfterBuyerVerification(result.nonce, result.token);
  //   } on ChargeException catch (ex) {
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Error processing card payment",
  //         description: ex.errorMessage);
  //   }
  // }

  // void _onApplePayNonceRequestSuccess(CardDetails result) async {
  //   if (!_chargeServerHostReplaced) {
  //     await InAppPayments.completeApplePayAuthorization(isSuccess: false);
  //     _showUrlNotSetAndPrintCurlCommand(result.nonce);
  //     return;
  //   }
  //   try {
  //     await chargeCard(result);
  //     _applePayStatus = ApplePayStatus.success;
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Your order was successful",
  //         description:
  //             "Go to your Square dashbord to see this order reflected in the sales tab.");
  //     await InAppPayments.completeApplePayAuthorization(isSuccess: true);
  //   } on ChargeException catch (ex) {
  //     await InAppPayments.completeApplePayAuthorization(
  //         isSuccess: false, errorMessage: ex.errorMessage);
  //     showAlertDialog(
  //         context: BuySheet.scaffoldKey.currentContext,
  //         title: "Error processing ApplePay payment",
  //         description: ex.errorMessage);
  //     _applePayStatus = ApplePayStatus.fail;
  //   }
  // }

  // void _onApplePayNonceRequestFailure(ErrorInfo errorInfo) async {
  //   _applePayStatus = ApplePayStatus.fail;
  //   await InAppPayments.completeApplePayAuthorization(
  //       isSuccess: false, errorMessage: errorInfo.message);
  //   showAlertDialog(
  //       context: BuySheet.scaffoldKey.currentContext,
  //       title: "Error request ApplePay nonce",
  //       description: errorInfo.toString());
  // }

  void _onApplePayEntryComplete() {
    if (_applePayStatus == ApplePayStatus.unknown) {
      // the apple pay is canceled
      _showOrderSheet();
    }
  }

  // void _onBuyerVerificationFailure(ErrorInfo errorInfo) async {
  //   showAlertDialog(
  //       context: BuySheet.scaffoldKey.currentContext,
  //       title: "Error verifying buyer",
  //       description: errorInfo.toString());
  // }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              "Are you sure",
            ),
            content: new Text("Do you want to cancel the payment?"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Color(0xff2E2A4A),
                  ),
                ),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child:
                    new Text("Yes", style: TextStyle(color: Color(0xff2E2A4A))),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: mainBackgroundColor,
        key: BuySheet.scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
            child: IconButton(
              icon: Image(
                image: AssetImage("assets/images/back_arrow.png"),
                height: 25.0,
                width: 25.0,
              ),
              onPressed: () {
                // Navigator.pop(context);
                _onWillPop();
                //  Navigator.pushNamed(context, '/jobs-pagination');
              },
            ),
          ),
          centerTitle: true,
          title: Container(
            child: Row(children: <Widget>[
              Center(
                child: BorderedText(
                  strokeWidth: 2.0,
                  strokeColor: Color(0xfffbefa7),
                  child: Text('Payment', style: normalText),
                ),
              ),
            ]),
          ),
          flexibleSpace: Container(
            height: 100,
            color: Color(0xfffbefa7),
          ),
          actions: <Widget>[],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.transparent,
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Builder(
            builder: (context) => Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Image(image: AssetImage("assets/images/logo.png")),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      margin: const EdgeInsets.only(
                          right: 10.0, left: 10, bottom: 15),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Color(0xFFe3e3e3)),
                          borderRadius: BorderRadius.all(Radius.circular(4.0))),
                      child: Column(children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            child: Row(children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: Text("Product" + "  :- ",
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: normalText1),
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              Expanded(
                                  child: Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Text(
                                      widget.product_name,
                                      style: normalText2,
                                    )),
                              ))
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            child: Row(children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: Text("Quantity" + "  :- ",
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: normalText1),
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              Expanded(
                                  child: Container(
                                width: MediaQuery.of(context).size.width * 0.50,
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Text(
                                      widget.collection_qty,
                                      style: normalText2,
                                    )),
                              )),
                              SizedBox(
                                width: 6.0,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.20,
                                child: Text("Litres",
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: normalText1),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            child: Row(children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: Text("Amount" + "  :- ",
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: normalText1),
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              Expanded(
                                  child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Html(
                                            data: html_currency_code +
                                                " " +
                                                widget.amount),
                                      )))
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ]),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: CookieButton(
                          text: "Pay Now", onPressed: _showOrderSheet),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
