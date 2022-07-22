import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:http_parser/http_parser.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as I;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:super_tooltip/super_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/models/xml_json.dart';
import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class JobCollection extends StatefulWidget {
  final Object argument;

  const JobCollection({Key key, this.argument}) : super(key: key);

  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<JobCollection> {
  Future<dynamic> _checkList;
  final signatoryController = TextEditingController();
  var emailSignatoryController = TextEditingController();
  var accountEmailSignatoryController = TextEditingController();
  var ponController = TextEditingController();
  File fileImg;
  File fileImg1;

  Future<File> f;
  bool _loading = false;
  var access_token;
  int arr;
  String vehicle_no;
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _dropdownValue = 'cash';
  String _dropdownValue1 = 'paid';
  bool showStatus = true;
  List<XMLJSON> xmlList = new List();
  var dataResponse;
  bool proceed = false;
  bool proceed2 = false;
  String formattedDate1 = "";
  String html_currency_code = "";
  String collection_tnc = "";
  String tipping_tnc = "";
  var checklist_id;
  ByteData _img = ByteData(0);
  ByteData _img1 = ByteData(0);
  var color = Colors.red;
  var color1 = Colors.blue;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();
  final _sign2 = GlobalKey<SignatureState>();
  String name = "";
  List<Region> _region = [];
  Future _vehicleData;
  String catData = "";
  String selectedRegion;
  var _type = "";
  var customer_accounttype = "";
  var customer_contactemail = "";
  var customer_accountemail = "";
  var pon = "";
  String job_id,
      vehicle_id,
      product_id,
      product_name,
      collection_qty,
      collection_vat,
      collection_amount,
      displayDropdown;
  Future _configData;
  String displayDropdownValue;
  bool loadingForDepotList = true;
  List depotList = [];
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    job_id = data['job_id'];
    print(job_id);
    vehicle_id = data['vehicle_id'];
    product_id = data['product_id'];
    product_name = data['product_name'];
    collection_qty = data['collection_qty'];
    collection_vat = data['collection_vat'];
    collection_amount = data['collection_amount'];
    customer_accounttype = data['customer_accounttype'];
    customer_contactemail = data['customer_contactemail'];
    customer_accountemail = data['customer_accountemail'];

    pon = data['po_no'];
    displayDropdown = data['displayDropdown'];
    print(displayDropdown);
    print(product_id);
    accountEmailSignatoryController =
        TextEditingController(text: customer_contactemail);
    emailSignatoryController =
        TextEditingController(text: customer_accountemail);
    ponController = TextEditingController(text: pon);
    _getUser();
  }

  Future<void> displayDropdownWidget(token) async {
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response = await http.get(
      Uri.parse(URL + "/depots"),
      headers: headers,
    );
    var data = jsonDecode(response.body);
    setState(() {
      loadingForDepotList = false;
    });
    if (data['status'] == 200) {
      print("insde");
      setState(() {
        // depotList.add({"depot_id": "0", "depot_name": "Select"});
        depotList.addAll(jsonDecode(response.body)['data']);
        // displayDropdownValue = depotList[0]['depot_id'].toString();
      });
      print(depotList);
    }
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        name = prefs.getString('driverName').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        html_currency_code = prefs.getString('html_currency_code').toString();
        collection_tnc = prefs.getString('collection_tnc').toString();
        tipping_tnc = prefs.getString('tipping_tnc').toString();
        print("<<<<<<<<<<<<<<<<" + vehicle_no);
        _configData = _getconfigCategories();
        print(access_token);
        if (displayDropdown == "true") {
          displayDropdownWidget(prefs.getString('access_token').toString());
        } else {
          setState(() {
            loadingForDepotList = false;
          });
        }
      });
    });
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText2 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalText3 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));

  Future _getconfigCategories() async {
    setState(() {
      _loading = true;
    });
    Map<String, String> headers = {
      'Authorization': 'Bearer $access_token',
      'Accept': 'application/json',
    };
    var response = await http.get(
      Uri.parse(URL + "/config"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      var data = json.decode(response.body);
      var result = data['data']['payment_mode'];
      if (mounted) {
        setState(() {
          catData = jsonEncode(result);

          final json = JsonDecoder().convert(catData);
          _region =
              (json).map<Region>((item) => Region.fromJson(item)).toList();
          List<String> item = _region.map((Region map) {
            for (int i = 0; i < _region.length; i++) {
              if (selectedRegion == map.THIRD_LEVEL_NAME) {
                _type = map.THIRD_LEVEL_ID;

                print(selectedRegion);
                return map.THIRD_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedRegion == "") {
            selectedRegion = _region[0].THIRD_LEVEL_NAME;
          }
        });
      }

      print("<<<<<<<<<<<<<<<" + _type);

      return result;
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
    }
  }

  selectedRadio(int val, int ind) {
    setState(() {
      arr = val;
    });
  }

  SuperTooltip tooltip;

  void onTap(response) {
    if (tooltip != null && tooltip.isOpen) {
      tooltip.close();
      return;
    }

    var renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    var targetGlobalCenter = renderBox
        .localToGlobal(renderBox.size.center(Offset.zero), ancestor: overlay);

    // We create the tooltip on the first use
    tooltip = SuperTooltip(
      popupDirection: TooltipDirection.up,
      top: 50.0,
      right: 5.0,
      left: 100.0,
      showCloseButton: ShowCloseButton.outside,
      hasShadow: false,
      content: new Material(
          child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text(
          response,
          softWrap: true,
        ),
      )),
    );

    tooltip.show(context);
  }

  Widget quizList() {
    return Column(children: <Widget>[
      Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.only(right: 15.0, left: 15),
          child: Text(
            "Driver Signature",
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: normalText1,
          ),
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Stack(children: <Widget>[
        Container(
            margin: const EdgeInsets.only(right: 10.0, left: 10),
            height: 200,
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Signature(
                color: color1,
                key: _sign,
                onSign: () {
                  final sign = _sign.currentState;
                  debugPrint('${sign.points.length} points in the signature');
                },
                strokeWidth: strokeWidth,
              ),
            )),
        InkWell(
          onTap: () {
            final sign = _sign.currentState;
            sign.clear();
            setState(() {
              _img = ByteData(0);
            });
            debugPrint("cleared");
          },
          child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.only(right: 20.0, top: 5),
                child:
                    Text("Clear", style: TextStyle(color: Color(0xffb5322f))),
              )),
        )
      ]),
      SizedBox(
        height: 20,
      ),
      InkWell(
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(right: 10.0, left: 10),
            child: Text(
              "Customer Signature",
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: normalText1,
            ),
          ),
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Stack(children: <Widget>[
        Container(
            height: 200,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.only(right: 10.0, left: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Signature(
                color: color,
                key: _sign2,
                onSign: () {
                  final sign1 = _sign2.currentState;
                  debugPrint('${sign1.points.length} points in the signature');
                },
                strokeWidth: strokeWidth,
              ),
            )),
        InkWell(
          onTap: () {
            final sign = _sign2.currentState;
            sign.clear();
            setState(() {
              _img1 = ByteData(0);
            });
            debugPrint("cleared");
          },
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
                margin: const EdgeInsets.only(right: 20.0, top: 5),
                child: Text(
                  "Clear",
                  style: TextStyle(color: Color(0xffb5322f)),
                )),
          ),
        )
      ]),
      SizedBox(
        height: 15.0,
      ),
      Container(
        margin: const EdgeInsets.only(right: 15.0, left: 15),
        child: TextFormField(
            controller: signatoryController,
            keyboardType: TextInputType.text,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            onSaved: (String value) {
              signatoryController.text = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter signatory name';
              }
              return null;
            },
            decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(15, 30, 30, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                counterText: "",
                hintText: 'Name of Signatory',
                hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                fillColor: Color(0xffffffff),
                filled: true)),
      ),
      SizedBox(
        height: 15.0,
      ),
      Container(
        margin: const EdgeInsets.only(right: 15.0, left: 15),
        child: TextFormField(
            controller: emailSignatoryController,
            //   initialValue: customer_contactemail,
            keyboardType: TextInputType.text,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            onSaved: (String value) {
              emailSignatoryController.text = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter email';
              }
              return null;
            },
            decoration: InputDecoration(
                isDense: true,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      String value1 = "";
                      value1 = emailSignatoryController.text;
                      accountEmailSignatoryController =
                          TextEditingController(text: value1);
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Copy",
                        style: TextStyle(
                            color: Color(0xffb5322f),
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      )),
                ),
                contentPadding: EdgeInsets.fromLTRB(15, 30, 30, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                counterText: "",
                hintText: 'Email',
                hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                fillColor: Color(0xffffffff),
                filled: true)),
      ),
      SizedBox(
        height: 15.0,
      ),
      Container(
        margin: const EdgeInsets.only(right: 15.0, left: 15),
        child: TextFormField(
            controller: accountEmailSignatoryController,
            // initialValue: customer_accountemail,
            keyboardType: TextInputType.text,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            onSaved: (String value) {
              accountEmailSignatoryController.text = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter account email';
              }
              return null;
            },
            decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(15, 30, 30, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                counterText: "",
                hintText: 'Accounts Email',
                hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                fillColor: Color(0xffffffff),
                filled: true)),
      ),
      SizedBox(
        height: 15.0,
      ),
      Container(
        margin: const EdgeInsets.only(right: 15.0, left: 15),
        child: TextFormField(
            controller: ponController,
            // initialValue: customer_accountemail,
            keyboardType: TextInputType.text,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            onSaved: (String value) {
              ponController.text = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter purchase order no.';
              }
              return null;
            },
            decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(15, 30, 30, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Color(0xffcdcbcb),
                  ),
                ),
                counterText: "",
                hintText: 'Purchase Order No.',
                hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                fillColor: Color(0xffffffff),
                filled: true)),
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(right: 10.0, left: 10, bottom: 15),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Color(0xFFe3e3e3)),
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        child: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: Container(
                child: RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(style: normalText3, text: collection_tnc),
            )),
          ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        product_name,
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
                  margin: const EdgeInsets.only(right: 8.0),
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        collection_qty,
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
                              data:
                                  html_currency_code + " " + collection_amount),
                        )))
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
                  child: Text("Vat" + "  :- ",
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Html(
                          data: html_currency_code + " " + collection_vat)),
                ))
              ]),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          loadingForDepotList
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : displayDropdown == "true"
                  ?
                  // Card(
                  //     elevation: 10,
                  //     child: ListTile(
                  //       title: Text("Select Depot",
                  //           style: TextStyle(
                  //               fontSize: 20, fontWeight: FontWeight.bold)),
                  //       subtitle: Text(displayDropdownValueText),
                  //       onTap: () {
                  //         showDialog(
                  //             context: context,
                  //             builder: (context) => AlertDialog(
                  //                   title: Text(
                  //                     "Select Depot",
                  //                   ),
                  //                   content: Container(
                  //                     height:
                  //                         MediaQuery.of(context).size.height /
                  //                             2,
                  //                     child: ListView(
                  //                       children: depotList
                  //                           .map((e) => ListTile(
                  //                                 onTap: () {
                  //                                   setState(() {
                  //                                     displayDropdownValue = "";
                  //                                     displayDropdownValue =
                  //                                         e['depot_id']
                  //                                             .toString();
                  //                                     displayDropdownValueText =
                  //                                         e['depot_name'];
                  //                                   });
                  //                                   Navigator.of(context).pop();
                  //                                 },
                  //                                 title: Text(e['depot_name']
                  //                                     .toString()),
                  //                               ))
                  //                           .toList(),
                  //                     ),
                  //                   ),
                  //                 ));
                  //       },
                  //     ),
                  //   )

                  Column(children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text("Depot" + " :- ",
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: normalText1),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            //background color of box
                            BoxShadow(
                              color: Color(0xffcdcbcb),
                              blurRadius: 1.0,
                              // soften the shadow
                              spreadRadius: 1.0,
                              //extend the shadow
                              offset: Offset(
                                0.0,
                                // Move to right 10  horizontally
                                0.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        // margin: const EdgeInsets.only(right: 8.0),
                        child: DropdownButtonHideUnderline(
                          child: new DropdownButton<String>(
                              isExpanded: true,
                              value: displayDropdownValue,
                              isDense: true,
                              hint: new Text(
                                "Select",
                                style: TextStyle(
                                    color: Color(0xffcdcbcb), fontSize: 16),
                              ),
                              icon: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ),
                              onChanged: (String newValue) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text("Confirmation"),
                                          content: Text(
                                              "Are you sure you want to tip on the selected depot?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "NO",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                            TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    displayDropdownValue =
                                                        newValue;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("YES",
                                                    style: TextStyle(
                                                        color: Colors.black)))
                                          ],
                                        ));
                              },
                              items: depotList
                                  .map((e) => DropdownMenuItem(
                                        child: Text(e['depot_name'].toString()),
                                        value: e['depot_id'].toString(),
                                      ))
                                  .toList()),
                        ),
                      ),
                    ])
                  : SizedBox(),
          SizedBox(
            height: 20,
          ),
          customer_accounttype == "0"
              ? Column(children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: Row(children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: Text("Payment Mode" + " :- ",
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
                            padding:
                                EdgeInsets.only(left: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                  color: Color(0xffcdcbcb),
                                )),
                            child: DropdownButtonHideUnderline(
                              child: Padding(
                                padding: EdgeInsets.only(right: 0, left: 0),
                                child: new DropdownButton<String>(
                                  isExpanded: true,
                                  hint: new Text(
                                    "Select",
                                    style: TextStyle(
                                        color: Color(0xffcdcbcb), fontSize: 16),
                                  ),
                                  icon: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: selectedRegion,
                                  isDense: true,
                                  autofocus: true,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      selectedRegion = newValue;
                                      List<String> item =
                                          _region.map((Region map) {
                                        for (int i = 0;
                                            i < _region.length;
                                            i++) {
                                          if (selectedRegion ==
                                              map.THIRD_LEVEL_NAME) {
                                            _type = map.THIRD_LEVEL_ID;
                                            return map.THIRD_LEVEL_ID;
                                          }
                                        }
                                      }).toList();
                                      if (_type == "online") {
                                        Navigator.pushNamed(
                                          context,
                                          '/payment-page',
                                          arguments: <String, String>{
                                            'job_id': job_id.toString(),
                                            'amount':
                                                collection_amount.toString(),
                                          },
                                        );
                                      }
                                    });
                                  },
                                  items: _region.map((Region map) {
                                    return new DropdownMenuItem<String>(
                                      value: map.THIRD_LEVEL_NAME,
                                      child: new Text(map.THIRD_LEVEL_NAME,
                                          style: new TextStyle(
                                              color: Color(0xff000000),
                                              fontSize: 16)),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: Row(children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: Text("Payment Status" + " :- ",
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
                            padding:
                                EdgeInsets.only(left: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                //background color of box
                                BoxShadow(
                                  color: Color(0xffcdcbcb),
                                  blurRadius: 1.0,
                                  // soften the shadow
                                  spreadRadius: 1.0,
                                  //extend the shadow
                                  offset: Offset(
                                    0.0,
                                    // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ],
                            ),
                            // margin: const EdgeInsets.only(right: 8.0),
                            child: DropdownButtonHideUnderline(
                              child: new DropdownButton<String>(
                                isExpanded: true,
                                value: _dropdownValue1,
                                isDense: true,
                                icon: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ),
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _dropdownValue1 = newValue;

                                    print(_dropdownValue1);
                                  });
                                },
                                items: <String>[
                                  'paid',
                                  'pending'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value,
                                        style: new TextStyle(
                                            color: Colors.black, fontSize: 14)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ])
              : Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Text("Payment On Account",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalText1),
                ),
          SizedBox(
            height: 20,
          ),
        ]),
      ),
      SizedBox(
        height: 30,
      ),
      Center(
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width * 0.50,
          height: 50.0,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xfffbefa7),
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                //background color of box
                BoxShadow(
                  color: Color(0xfffbefa7),
                  blurRadius: 2.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: Offset(
                    0.0,
                    // Move to right 10  horizontally
                    0.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
            ),
            child: RaisedButton(
              splashColor: Color(0xfffbefa7),
              padding:
                  const EdgeInsets.only(top: 2, bottom: 2, left: 20, right: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)),
              textColor: Color(0xffb5322f),
              color: Color(0xfffbefa7),
              onPressed: () async {
                if (displayDropdown == "true") {
                  if (displayDropdownValue != null) {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      print(_type);
                      print(_dropdownValue1);

                      if (_type == "") {
                        if (customer_accounttype == "0") {
                          Fluttertoast.showToast(msg: "Select payment Mode");
                        } else {
                          print("<<<<<<<<<<<<wfrwrfwrefwfw>>>>>>>>>>>>");
                          final sign = _sign.currentState;
                          //retrieve image data, do whatever you want with it (send to server, save locally...)
                          final image = await sign.getData();
                          var data = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          final encoded =
                              base64.encode(data.buffer.asUint8List());
                          setState(() {
                            _img = data;
                          });
                          //debugPrint("onPressed " + encoded);

                          final sign1 = _sign2.currentState;
                          //retrieve image data, do whatever you want with it (send to server, save locally...)
                          final image1 = await sign1.getData();
                          var data1 = await image1.toByteData(
                              format: ui.ImageByteFormat.png);
                          final encoded1 =
                              base64.encode(data1.buffer.asUint8List());
                          setState(() {
                            _img1 = data;
                          });
                          // log("onPressed " + encoded);
                          final decodedBytes = base64Decode(encoded);
                          final decodedBytes1 = base64Decode(encoded1);
                          final directory =
                              await getApplicationDocumentsDirectory();
                          fileImg = File('${directory.path}/testImage.png');
                          fileImg1 = File('${directory.path}/testImage1.png');
                          print(fileImg.path);
                          print(fileImg1.path);
                          fileImg.writeAsBytesSync(List.from(decodedBytes));
                          fileImg1.writeAsBytesSync(List.from(decodedBytes1));

                          if (sign.points.length != 0 &&
                              sign1.points.length != 0) {
                            print(sign.points.length);
                            print(sign1.points.length);
                            setState(() {
                              _loading = true;
                            });

                            Map<String, String> headers = {
                              'Accept': 'application/json',
                              'Authorization': 'Bearer $access_token',
                            };
                            final mimeTypeData = lookupMimeType(fileImg.path,
                                headerBytes: [0xFF, 0xD8]).split('/');
                            final mimeTypeData1 = lookupMimeType(fileImg1.path,
                                headerBytes: [0xFF, 0xD8]).split('/');

                            var uri = Uri.parse(URL + "/job-collection/create");
                            print(uri);
                            final uploadRequest =
                                http.MultipartRequest('POST', uri);
                            final file = await http.MultipartFile.fromPath(
                                'driver_signature', fileImg.path,
                                contentType: MediaType(
                                    mimeTypeData[0], mimeTypeData[1]));
                            final file1 = await http.MultipartFile.fromPath(
                                'customer_signature', fileImg1.path,
                                contentType: MediaType(
                                    mimeTypeData1[0], mimeTypeData1[1]));

                            uploadRequest.headers.addAll(headers);
                            uploadRequest.fields['job_id'] = job_id;
                            uploadRequest.fields['vehicle_id'] = vehicle_id;
                            uploadRequest.fields['product_id'] = product_id;
                            uploadRequest.fields['collection_qty'] =
                                collection_qty;
                            uploadRequest.fields['collection_vat'] =
                                collection_vat;
                            uploadRequest.fields['collection_amount'] =
                                collection_amount;
                            uploadRequest.fields['collection_signatory'] =
                                signatoryController.text;
                            uploadRequest.fields['email'] =
                                emailSignatoryController.text;
                            uploadRequest.fields['account_email'] =
                                accountEmailSignatoryController.text;
                            uploadRequest.fields['po_no'] = ponController.text;

                            uploadRequest.fields['depo_id'] =
                                displayDropdownValue.toString();
                            uploadRequest.files.add(file);
                            uploadRequest.files.add(file1);

                            final streamedResponse = await uploadRequest.send();
                            final response = await http.Response.fromStream(
                                streamedResponse);

                            try {
                              print("><>>>>>>>>>>>" +
                                  response.statusCode.toString());
                              print("><>>>>>>>>>>>" + response.body);
                              if (response.statusCode == 201) {
                                setState(() {
                                  _loading = false;
                                });
                                var data = json.decode(response.body);
                                Fluttertoast.showToast(
                                    msg: 'Created Successfully');
                                Navigator.pushNamed(
                                  context,
                                  '/successful-screen',
                                  arguments: <String, String>{
                                    'collection_qty': data['data']
                                            ['collection_qty']
                                        .toString(),
                                    'collection_vat': data['data']
                                            ['collection_vat']
                                        .toString(),
                                    'collection_amount': data['data']
                                            ['collection_amount']
                                        .toString(),
                                    'collection_number': data['data']
                                            ['collection_number']
                                        .toString(),
                                    'collection_date': data['data']
                                            ['collection_date']
                                        .toString(),
                                    'consignment_no': data['data']
                                                ['consignment']
                                            ['consignment_number']
                                        .toString(),
                                    'product_info': data['data']['product']
                                                ['product_name']
                                            .toString() +
                                        " - " +
                                        data['data']['product']['product_ewc']
                                            .toString(),
                                  },
                                );
                              } else if (response.statusCode == 401) {
                                setState(() {
                                  _loading = false;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.getKeys();
                                for (String key in prefs.getKeys()) {
                                  if (key != "mDateKey") {
                                    prefs.remove(key);
                                  }
                                }
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else if (response.statusCode == 403) {
                                setState(() {
                                  _loading = false;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.getKeys();
                                for (String key in prefs.getKeys()) {
                                  if (key != "mDateKey") {
                                    prefs.remove(key);
                                  }
                                }
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else {
                                setState(() {
                                  _loading = false;
                                });
                              }
                            } catch (e) {
                              print(e);
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Signatures can't be empty",
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        }
                      } else if (_type == "online") {
                        Map<String, String> headers = {
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $access_token',
                        };
                        var response = await http.get(
                          Uri.parse(URL + "/sage/" + job_id),
                          headers: headers,
                        );
                        var data_data = json.decode(response.body);
                        print(data_data);
                        if (response.statusCode == 200) {
                          if (data_data['status'] == 200) {
                            final sign = _sign.currentState;
                            //retrieve image data, do whatever you want with it (send to server, save locally...)
                            final image = await sign.getData();
                            var data = await image.toByteData(
                                format: ui.ImageByteFormat.png);
                            final encoded =
                                base64.encode(data.buffer.asUint8List());
                            setState(() {
                              _img = data;
                            });
                            //debugPrint("onPressed " + encoded);

                            final sign1 = _sign2.currentState;
                            //retrieve image data, do whatever you want with it (send to server, save locally...)
                            final image1 = await sign1.getData();
                            var data1 = await image1.toByteData(
                                format: ui.ImageByteFormat.png);
                            final encoded1 =
                                base64.encode(data1.buffer.asUint8List());
                            setState(() {
                              _img1 = data;
                            });
                            // log("onPressed " + encoded);
                            final decodedBytes = base64Decode(encoded);
                            final decodedBytes1 = base64Decode(encoded1);
                            final directory =
                                await getApplicationDocumentsDirectory();
                            fileImg = File('${directory.path}/testImage.png');
                            fileImg1 = File('${directory.path}/testImage1.png');
                            print(fileImg.path);
                            print(fileImg1.path);
                            fileImg.writeAsBytesSync(List.from(decodedBytes));
                            fileImg1.writeAsBytesSync(List.from(decodedBytes1));

                            if (sign.points.length != 0 &&
                                sign1.points.length != 0) {
                              print(sign.points.length);
                              print(sign1.points.length);
                              setState(() {
                                _loading = true;
                              });

                              Map<String, String> headers = {
                                'Accept': 'application/json',
                                'Authorization': 'Bearer $access_token',
                              };
                              final mimeTypeData = lookupMimeType(fileImg.path,
                                  headerBytes: [0xFF, 0xD8]).split('/');
                              final mimeTypeData1 = lookupMimeType(
                                  fileImg1.path,
                                  headerBytes: [0xFF, 0xD8]).split('/');

                              var uri =
                                  Uri.parse(URL + "/job-collection/create");
                              print(uri);
                              final uploadRequest =
                                  http.MultipartRequest('POST', uri);
                              final file = await http.MultipartFile.fromPath(
                                  'driver_signature', fileImg.path,
                                  contentType: MediaType(
                                      mimeTypeData[0], mimeTypeData[1]));
                              final file1 = await http.MultipartFile.fromPath(
                                  'customer_signature', fileImg1.path,
                                  contentType: MediaType(
                                      mimeTypeData1[0], mimeTypeData1[1]));

                              uploadRequest.headers.addAll(headers);
                              uploadRequest.fields['job_id'] = job_id;
                              uploadRequest.fields['vehicle_id'] = vehicle_id;
                              uploadRequest.fields['product_id'] = product_id;
                              uploadRequest.fields['collection_qty'] =
                                  collection_qty;
                              uploadRequest.fields['collection_vat'] =
                                  collection_vat;
                              uploadRequest.fields['collection_amount'] =
                                  collection_amount;
                              uploadRequest.fields['collection_signatory'] =
                                  signatoryController.text;
                              uploadRequest.fields['payment_mode'] = _type;
                              uploadRequest.fields['payment_status'] =
                                  _dropdownValue1;
                              uploadRequest.fields['payment[txn_id]'] =
                                  data_data['data']['transaction_id'];
                              uploadRequest.fields['payment[order_id]'] =
                                  data_data['data']['order_id'];
                              uploadRequest.fields['payment[amount]'] =
                                  data_data['data']['amount'];
                              uploadRequest.fields['email'] =
                                  emailSignatoryController.text;
                              uploadRequest.fields['account_email'] =
                                  accountEmailSignatoryController.text;
                              uploadRequest.fields['po_no'] =
                                  ponController.text;
                              uploadRequest.fields['depo_id'] =
                                  displayDropdownValue.toString();
                              uploadRequest.files.add(file);
                              uploadRequest.files.add(file1);

                              final streamedResponse =
                                  await uploadRequest.send();
                              final response = await http.Response.fromStream(
                                  streamedResponse);

                              try {
                                print("><>>>>>>>>>>>" +
                                    response.statusCode.toString());
                                print("><>>>>>>>>>>>" + response.body);
                                if (response.statusCode == 201) {
                                  setState(() {
                                    _loading = false;
                                  });
                                  var data = json.decode(response.body);
                                  Fluttertoast.showToast(
                                      msg: 'Created Successfully');

                                  Navigator.pushNamed(
                                    context,
                                    '/successful-screen',
                                    arguments: <String, String>{
                                      'collection_qty': data['data']
                                              ['collection_qty']
                                          .toString(),
                                      'collection_vat': data['data']
                                              ['collection_vat']
                                          .toString(),
                                      'collection_amount': data['data']
                                              ['collection_amount']
                                          .toString(),
                                      'collection_number': data['data']
                                              ['collection_number']
                                          .toString(),
                                      'collection_date': data['data']
                                              ['collection_date']
                                          .toString(),
                                      'consignment_no': data['data']
                                                  ['consignment']
                                              ['consignment_number']
                                          .toString(),
                                      'product_info': data['data']['product']
                                                  ['product_name']
                                              .toString() +
                                          " - " +
                                          data['data']['product']['product_ewc']
                                              .toString(),
                                    },
                                  );
                                } else if (response.statusCode == 401) {
                                  setState(() {
                                    _loading = false;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.getKeys();
                                  for (String key in prefs.getKeys()) {
                                    if (key != "mDateKey") {
                                      prefs.remove(key);
                                    }
                                  }
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                } else if (response.statusCode == 403) {
                                  setState(() {
                                    _loading = false;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.getKeys();
                                  for (String key in prefs.getKeys()) {
                                    if (key != "mDateKey") {
                                      prefs.remove(key);
                                    }
                                  }
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                } else {
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              } catch (e) {
                                print(e);
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Signatures can't be empty",
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please complete your payment...",
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        } else if (response.statusCode == 401) {
                          Fluttertoast.showToast(
                              msg: "Please complete your payment...",
                              toastLength: Toast.LENGTH_SHORT);
                        } else if (response.statusCode == 403) {
                          Fluttertoast.showToast(
                              msg: "Please complete your payment...",
                              toastLength: Toast.LENGTH_SHORT);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please complete your payment...",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      } else if (_type == "square") {
                        final sign = _sign.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign.getData();
                        var data = await image.toByteData(
                            format: ui.ImageByteFormat.png);
                        final encoded =
                            base64.encode(data.buffer.asUint8List());

                        final sign1 = _sign2.currentState;

                        final image1 = await sign1.getData();
                        var data1 = await image1.toByteData(
                            format: ui.ImageByteFormat.png);
                        final encoded1 =
                            base64.encode(data1.buffer.asUint8List());
                        var arr = collection_amount.split('.');
                        if (sign.points.length != 0 &&
                            sign1.points.length != 0) {
                          Navigator.pushNamed(
                            context,
                            '/square-pay',
                            arguments: <String, String>{
                              'collection_qty': collection_qty.toString(),
                              'product_name': product_name.toString(),
                              'amount': arr[0].toString(),
                              "driver_name": name,
                              "job_id": job_id,
                              "vehicle_id": vehicle_id,
                              "product_id": product_id,
                              "collection_vat": collection_vat,
                              "collection_amount": collection_amount,
                              "collection_signatory": signatoryController.text,
                              "payment_mode": _type,
                              "payment_status": _dropdownValue1,
                              "email": emailSignatoryController.text,
                              "account_email":
                                  accountEmailSignatoryController.text,
                              "po_no": ponController.text,
                              "file": encoded,
                              "file1": encoded1,
                            },
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg: "Signatures can't be empty",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      } else {
                        final sign = _sign.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign.getData();
                        var data = await image.toByteData(
                            format: ui.ImageByteFormat.png);
                        final encoded =
                            base64.encode(data.buffer.asUint8List());
                        setState(() {
                          _img = data;
                        });
                        //debugPrint("onPressed " + encoded);

                        final sign1 = _sign2.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image1 = await sign1.getData();
                        var data1 = await image1.toByteData(
                            format: ui.ImageByteFormat.png);
                        final encoded1 =
                            base64.encode(data1.buffer.asUint8List());
                        setState(() {
                          _img1 = data;
                        });
                        // log("onPressed " + encoded);
                        final decodedBytes = base64Decode(encoded);
                        final decodedBytes1 = base64Decode(encoded1);
                        final directory =
                            await getApplicationDocumentsDirectory();
                        fileImg = File('${directory.path}/testImage.png');
                        fileImg1 = File('${directory.path}/testImage1.png');
                        print(fileImg.path);
                        print(fileImg1.path);
                        fileImg.writeAsBytesSync(List.from(decodedBytes));
                        fileImg1.writeAsBytesSync(List.from(decodedBytes1));

                        if (sign.points.length != 0 &&
                            sign1.points.length != 0) {
                          print(sign.points.length);
                          print(sign1.points.length);
                          setState(() {
                            _loading = true;
                          });

                          Map<String, String> headers = {
                            'Accept': 'application/json',
                            'Authorization': 'Bearer $access_token',
                          };
                          final mimeTypeData = lookupMimeType(fileImg.path,
                              headerBytes: [0xFF, 0xD8]).split('/');
                          final mimeTypeData1 = lookupMimeType(fileImg1.path,
                              headerBytes: [0xFF, 0xD8]).split('/');

                          var uri = Uri.parse(URL + "/job-collection/create");
                          print(uri);
                          final uploadRequest =
                              http.MultipartRequest('POST', uri);
                          final file = await http.MultipartFile.fromPath(
                              'driver_signature', fileImg.path,
                              contentType:
                                  MediaType(mimeTypeData[0], mimeTypeData[1]));
                          final file1 = await http.MultipartFile.fromPath(
                              'customer_signature', fileImg1.path,
                              contentType: MediaType(
                                  mimeTypeData1[0], mimeTypeData1[1]));

                          uploadRequest.headers.addAll(headers);
                          uploadRequest.fields['job_id'] = job_id;
                          uploadRequest.fields['vehicle_id'] = vehicle_id;
                          uploadRequest.fields['product_id'] = product_id;
                          uploadRequest.fields['collection_qty'] =
                              collection_qty;
                          uploadRequest.fields['collection_vat'] =
                              collection_vat;
                          uploadRequest.fields['collection_amount'] =
                              collection_amount;
                          uploadRequest.fields['collection_signatory'] =
                              signatoryController.text;
                          uploadRequest.fields['payment_mode'] = _type;
                          uploadRequest.fields['payment_status'] =
                              _dropdownValue1;
                          uploadRequest.fields['email'] =
                              emailSignatoryController.text;
                          uploadRequest.fields['account_email'] =
                              accountEmailSignatoryController.text;
                          uploadRequest.fields['po_no'] = ponController.text;

                          uploadRequest.fields['depo_id'] =
                              displayDropdownValue.toString();
                          uploadRequest.files.add(file);
                          uploadRequest.files.add(file1);
                          print(uploadRequest.fields);
                          final streamedResponse = await uploadRequest.send();
                          final response =
                              await http.Response.fromStream(streamedResponse);

                          try {
                            print("><>>>>>>>>>>>" +
                                response.statusCode.toString());
                            print("><>>>>>>>>>>>" + response.body);
                            if (response.statusCode == 201) {
                              setState(() {
                                _loading = false;
                              });
                              var data = json.decode(response.body);
                              Fluttertoast.showToast(
                                  msg: 'Created Successfully');
                              Navigator.pushNamed(
                                context,
                                '/successful-screen',
                                arguments: <String, String>{
                                  'collection_qty':
                                      data['data']['collection_qty'].toString(),
                                  'collection_vat':
                                      data['data']['collection_vat'].toString(),
                                  'collection_amount': data['data']
                                          ['collection_amount']
                                      .toString(),
                                  'collection_number': data['data']
                                          ['collection_number']
                                      .toString(),
                                  'collection_date': data['data']
                                          ['collection_date']
                                      .toString(),
                                  'consignment_no': data['data']['consignment']
                                          ['consignment_number']
                                      .toString(),
                                  'product_info': data['data']['product']
                                              ['product_name']
                                          .toString() +
                                      " - " +
                                      data['data']['product']['product_ewc']
                                          .toString(),
                                },
                              );
                            } else if (response.statusCode == 401) {
                              setState(() {
                                _loading = false;
                              });
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
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
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.getKeys();
                              for (String key in prefs.getKeys()) {
                                if (key != "mDateKey") {
                                  prefs.remove(key);
                                }
                              }
                              Navigator.pushReplacementNamed(context, '/login');
                            } else {
                              setState(() {
                                _loading = false;
                              });
                            }
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Signatures can't be empty",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      }
                    } else {
                      setState(() {
                        _autoValidate = true;
                      });
                    }
                  } else {
                    Fluttertoast.showToast(msg: "Please select Depot");
                  }
                } else {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();

                    print(_type);
                    print(_dropdownValue1);

                    if (_type == "") {
                      if (customer_accounttype == "0") {
                        Fluttertoast.showToast(msg: "Select payment Mode");
                      } else {
                        print("<<<<<<<<<<<<wfrwrfwrefwfw>>>>>>>>>>>>");
                        final sign = _sign.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign.getData();
                        var data = await image.toByteData(
                            format: ui.ImageByteFormat.png);
                        final encoded =
                            base64.encode(data.buffer.asUint8List());
                        setState(() {
                          _img = data;
                        });
                        //debugPrint("onPressed " + encoded);

                        final sign1 = _sign2.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image1 = await sign1.getData();
                        var data1 = await image1.toByteData(
                            format: ui.ImageByteFormat.png);
                        final encoded1 =
                            base64.encode(data1.buffer.asUint8List());
                        setState(() {
                          _img1 = data;
                        });
                        // log("onPressed " + encoded);
                        final decodedBytes = base64Decode(encoded);
                        final decodedBytes1 = base64Decode(encoded1);
                        final directory =
                            await getApplicationDocumentsDirectory();
                        fileImg = File('${directory.path}/testImage.png');
                        fileImg1 = File('${directory.path}/testImage1.png');
                        print(fileImg.path);
                        print(fileImg1.path);
                        fileImg.writeAsBytesSync(List.from(decodedBytes));
                        fileImg1.writeAsBytesSync(List.from(decodedBytes1));

                        if (sign.points.length != 0 &&
                            sign1.points.length != 0) {
                          print(sign.points.length);
                          print(sign1.points.length);
                          setState(() {
                            _loading = true;
                          });

                          Map<String, String> headers = {
                            'Accept': 'application/json',
                            'Authorization': 'Bearer $access_token',
                          };
                          final mimeTypeData = lookupMimeType(fileImg.path,
                              headerBytes: [0xFF, 0xD8]).split('/');
                          final mimeTypeData1 = lookupMimeType(fileImg1.path,
                              headerBytes: [0xFF, 0xD8]).split('/');

                          var uri = Uri.parse(URL + "/job-collection/create");
                          print(uri);
                          final uploadRequest =
                              http.MultipartRequest('POST', uri);
                          final file = await http.MultipartFile.fromPath(
                              'driver_signature', fileImg.path,
                              contentType:
                                  MediaType(mimeTypeData[0], mimeTypeData[1]));
                          final file1 = await http.MultipartFile.fromPath(
                              'customer_signature', fileImg1.path,
                              contentType: MediaType(
                                  mimeTypeData1[0], mimeTypeData1[1]));

                          uploadRequest.headers.addAll(headers);
                          uploadRequest.fields['job_id'] = job_id;
                          uploadRequest.fields['vehicle_id'] = vehicle_id;
                          uploadRequest.fields['product_id'] = product_id;
                          uploadRequest.fields['collection_qty'] =
                              collection_qty;
                          uploadRequest.fields['collection_vat'] =
                              collection_vat;
                          uploadRequest.fields['collection_amount'] =
                              collection_amount;
                          uploadRequest.fields['collection_signatory'] =
                              signatoryController.text;
                          uploadRequest.fields['email'] =
                              emailSignatoryController.text;
                          uploadRequest.fields['account_email'] =
                              accountEmailSignatoryController.text;
                          uploadRequest.fields['po_no'] = ponController.text;

                          // uploadRequest.fields['depo_id'] =
                          //     displayDropdownValue.toString();
                          uploadRequest.files.add(file);
                          uploadRequest.files.add(file1);
                          print(uploadRequest.fields);
                          final streamedResponse = await uploadRequest.send();
                          final response =
                              await http.Response.fromStream(streamedResponse);

                          try {
                            print("><>>>>>>>>>>>" +
                                response.statusCode.toString());
                            print("><>>>>>>>>>>>" + response.body);
                            if (response.statusCode == 201) {
                              setState(() {
                                _loading = false;
                              });
                              var data = json.decode(response.body);
                              Fluttertoast.showToast(
                                  msg: 'Created Successfully');
                              Navigator.pushNamed(
                                context,
                                '/successful-screen',
                                arguments: <String, String>{
                                  'collection_qty':
                                      data['data']['collection_qty'].toString(),
                                  'collection_vat':
                                      data['data']['collection_vat'].toString(),
                                  'collection_amount': data['data']
                                          ['collection_amount']
                                      .toString(),
                                  'collection_number': data['data']
                                          ['collection_number']
                                      .toString(),
                                  'collection_date': data['data']
                                          ['collection_date']
                                      .toString(),
                                  'consignment_no': data['data']['consignment']
                                          ['consignment_number']
                                      .toString(),
                                  'product_info': data['data']['product']
                                              ['product_name']
                                          .toString() +
                                      " - " +
                                      data['data']['product']['product_ewc']
                                          .toString(),
                                },
                              );
                            } else if (response.statusCode == 401) {
                              setState(() {
                                _loading = false;
                              });
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
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
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.getKeys();
                              for (String key in prefs.getKeys()) {
                                if (key != "mDateKey") {
                                  prefs.remove(key);
                                }
                              }
                              Navigator.pushReplacementNamed(context, '/login');
                            } else {
                              setState(() {
                                _loading = false;
                              });
                            }
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Signatures can't be empty",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      }
                    } else if (_type == "online") {
                      Map<String, String> headers = {
                        'Accept': 'application/json',
                        'Authorization': 'Bearer $access_token',
                      };
                      var response = await http.get(
                        Uri.parse(URL + "/sage/" + job_id),
                        headers: headers,
                      );
                      var data_data = json.decode(response.body);
                      print(data_data);
                      if (response.statusCode == 200) {
                        if (data_data['status'] == 200) {
                          final sign = _sign.currentState;
                          //retrieve image data, do whatever you want with it (send to server, save locally...)
                          final image = await sign.getData();
                          var data = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          final encoded =
                              base64.encode(data.buffer.asUint8List());
                          setState(() {
                            _img = data;
                          });
                          //debugPrint("onPressed " + encoded);

                          final sign1 = _sign2.currentState;
                          //retrieve image data, do whatever you want with it (send to server, save locally...)
                          final image1 = await sign1.getData();
                          var data1 = await image1.toByteData(
                              format: ui.ImageByteFormat.png);
                          final encoded1 =
                              base64.encode(data1.buffer.asUint8List());
                          setState(() {
                            _img1 = data;
                          });
                          // log("onPressed " + encoded);
                          final decodedBytes = base64Decode(encoded);
                          final decodedBytes1 = base64Decode(encoded1);
                          final directory =
                              await getApplicationDocumentsDirectory();
                          fileImg = File('${directory.path}/testImage.png');
                          fileImg1 = File('${directory.path}/testImage1.png');
                          print(fileImg.path);
                          print(fileImg1.path);
                          fileImg.writeAsBytesSync(List.from(decodedBytes));
                          fileImg1.writeAsBytesSync(List.from(decodedBytes1));

                          if (sign.points.length != 0 &&
                              sign1.points.length != 0) {
                            print(sign.points.length);
                            print(sign1.points.length);
                            setState(() {
                              _loading = true;
                            });

                            Map<String, String> headers = {
                              'Accept': 'application/json',
                              'Authorization': 'Bearer $access_token',
                            };
                            final mimeTypeData = lookupMimeType(fileImg.path,
                                headerBytes: [0xFF, 0xD8]).split('/');
                            final mimeTypeData1 = lookupMimeType(fileImg1.path,
                                headerBytes: [0xFF, 0xD8]).split('/');

                            var uri = Uri.parse(URL + "/job-collection/create");
                            print(uri);
                            final uploadRequest =
                                http.MultipartRequest('POST', uri);
                            final file = await http.MultipartFile.fromPath(
                                'driver_signature', fileImg.path,
                                contentType: MediaType(
                                    mimeTypeData[0], mimeTypeData[1]));
                            final file1 = await http.MultipartFile.fromPath(
                                'customer_signature', fileImg1.path,
                                contentType: MediaType(
                                    mimeTypeData1[0], mimeTypeData1[1]));

                            uploadRequest.headers.addAll(headers);
                            uploadRequest.fields['job_id'] = job_id;
                            uploadRequest.fields['vehicle_id'] = vehicle_id;
                            uploadRequest.fields['product_id'] = product_id;
                            uploadRequest.fields['collection_qty'] =
                                collection_qty;
                            uploadRequest.fields['collection_vat'] =
                                collection_vat;
                            uploadRequest.fields['collection_amount'] =
                                collection_amount;
                            uploadRequest.fields['collection_signatory'] =
                                signatoryController.text;
                            uploadRequest.fields['payment_mode'] = _type;
                            uploadRequest.fields['payment_status'] =
                                _dropdownValue1;
                            uploadRequest.fields['payment[txn_id]'] =
                                data_data['data']['transaction_id'];
                            uploadRequest.fields['payment[order_id]'] =
                                data_data['data']['order_id'];
                            uploadRequest.fields['payment[amount]'] =
                                data_data['data']['amount'];
                            uploadRequest.fields['email'] =
                                emailSignatoryController.text;
                            uploadRequest.fields['account_email'] =
                                accountEmailSignatoryController.text;
                            uploadRequest.fields['po_no'] = ponController.text;
                            // uploadRequest.fields['depo_id'] =
                            //     displayDropdownValue.toString();
                            uploadRequest.files.add(file);
                            uploadRequest.files.add(file1);

                            final streamedResponse = await uploadRequest.send();
                            final response = await http.Response.fromStream(
                                streamedResponse);

                            try {
                              print("><>>>>>>>>>>>" +
                                  response.statusCode.toString());
                              print("><>>>>>>>>>>>" + response.body);
                              if (response.statusCode == 201) {
                                setState(() {
                                  _loading = false;
                                });
                                var data = json.decode(response.body);
                                Fluttertoast.showToast(
                                    msg: 'Created Successfully');

                                Navigator.pushNamed(
                                  context,
                                  '/successful-screen',
                                  arguments: <String, String>{
                                    'collection_qty': data['data']
                                            ['collection_qty']
                                        .toString(),
                                    'collection_vat': data['data']
                                            ['collection_vat']
                                        .toString(),
                                    'collection_amount': data['data']
                                            ['collection_amount']
                                        .toString(),
                                    'collection_number': data['data']
                                            ['collection_number']
                                        .toString(),
                                    'collection_date': data['data']
                                            ['collection_date']
                                        .toString(),
                                    'consignment_no': data['data']
                                                ['consignment']
                                            ['consignment_number']
                                        .toString(),
                                    'product_info': data['data']['product']
                                                ['product_name']
                                            .toString() +
                                        " - " +
                                        data['data']['product']['product_ewc']
                                            .toString(),
                                  },
                                );
                              } else if (response.statusCode == 401) {
                                setState(() {
                                  _loading = false;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.getKeys();
                                for (String key in prefs.getKeys()) {
                                  if (key != "mDateKey") {
                                    prefs.remove(key);
                                  }
                                }
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else if (response.statusCode == 403) {
                                setState(() {
                                  _loading = false;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.getKeys();
                                for (String key in prefs.getKeys()) {
                                  if (key != "mDateKey") {
                                    prefs.remove(key);
                                  }
                                }
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else {
                                setState(() {
                                  _loading = false;
                                });
                              }
                            } catch (e) {
                              print(e);
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Signatures can't be empty",
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please complete your payment...",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      } else if (response.statusCode == 401) {
                        Fluttertoast.showToast(
                            msg: "Please complete your payment...",
                            toastLength: Toast.LENGTH_SHORT);
                      } else if (response.statusCode == 403) {
                        Fluttertoast.showToast(
                            msg: "Please complete your payment...",
                            toastLength: Toast.LENGTH_SHORT);
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please complete your payment...",
                            toastLength: Toast.LENGTH_SHORT);
                      }
                    } else if (_type == "square") {
                      final sign = _sign.currentState;
                      //retrieve image data, do whatever you want with it (send to server, save locally...)
                      final image = await sign.getData();
                      var data = await image.toByteData(
                          format: ui.ImageByteFormat.png);
                      final encoded = base64.encode(data.buffer.asUint8List());

                      final sign1 = _sign2.currentState;

                      final image1 = await sign1.getData();
                      var data1 = await image1.toByteData(
                          format: ui.ImageByteFormat.png);
                      final encoded1 =
                          base64.encode(data1.buffer.asUint8List());
                      var arr = collection_amount.split('.');
                      if (sign.points.length != 0 && sign1.points.length != 0) {
                        Navigator.pushNamed(
                          context,
                          '/square-pay',
                          arguments: <String, String>{
                            'collection_qty': collection_qty.toString(),
                            'product_name': product_name.toString(),
                            'amount': arr[0].toString(),
                            "driver_name": name,
                            "job_id": job_id,
                            "vehicle_id": vehicle_id,
                            "product_id": product_id,
                            "collection_vat": collection_vat,
                            "collection_amount": collection_amount,
                            "collection_signatory": signatoryController.text,
                            "payment_mode": _type,
                            "payment_status": _dropdownValue1,
                            "email": emailSignatoryController.text,
                            "account_email":
                                accountEmailSignatoryController.text,
                            "po_no": ponController.text,
                            "file": encoded,
                            "file1": encoded1,
                          },
                        );
                      } else {
                        Fluttertoast.showToast(
                            msg: "Signatures can't be empty",
                            toastLength: Toast.LENGTH_SHORT);
                      }
                    } else {
                      final sign = _sign.currentState;
                      //retrieve image data, do whatever you want with it (send to server, save locally...)
                      final image = await sign.getData();
                      var data = await image.toByteData(
                          format: ui.ImageByteFormat.png);
                      final encoded = base64.encode(data.buffer.asUint8List());
                      setState(() {
                        _img = data;
                      });
                      //debugPrint("onPressed " + encoded);

                      final sign1 = _sign2.currentState;
                      //retrieve image data, do whatever you want with it (send to server, save locally...)
                      final image1 = await sign1.getData();
                      var data1 = await image1.toByteData(
                          format: ui.ImageByteFormat.png);
                      final encoded1 =
                          base64.encode(data1.buffer.asUint8List());
                      setState(() {
                        _img1 = data;
                      });
                      // log("onPressed " + encoded);
                      final decodedBytes = base64Decode(encoded);
                      final decodedBytes1 = base64Decode(encoded1);
                      final directory =
                          await getApplicationDocumentsDirectory();
                      fileImg = File('${directory.path}/testImage.png');
                      fileImg1 = File('${directory.path}/testImage1.png');
                      print(fileImg.path);
                      print(fileImg1.path);
                      fileImg.writeAsBytesSync(List.from(decodedBytes));
                      fileImg1.writeAsBytesSync(List.from(decodedBytes1));

                      if (sign.points.length != 0 && sign1.points.length != 0) {
                        print(sign.points.length);
                        print(sign1.points.length);
                        setState(() {
                          _loading = true;
                        });

                        Map<String, String> headers = {
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $access_token',
                        };
                        final mimeTypeData = lookupMimeType(fileImg.path,
                            headerBytes: [0xFF, 0xD8]).split('/');
                        final mimeTypeData1 = lookupMimeType(fileImg1.path,
                            headerBytes: [0xFF, 0xD8]).split('/');

                        var uri = Uri.parse(URL + "/job-collection/create");
                        print(uri);
                        final uploadRequest =
                            http.MultipartRequest('POST', uri);
                        final file = await http.MultipartFile.fromPath(
                            'driver_signature', fileImg.path,
                            contentType:
                                MediaType(mimeTypeData[0], mimeTypeData[1]));
                        final file1 = await http.MultipartFile.fromPath(
                            'customer_signature', fileImg1.path,
                            contentType:
                                MediaType(mimeTypeData1[0], mimeTypeData1[1]));

                        uploadRequest.headers.addAll(headers);
                        uploadRequest.fields['job_id'] = job_id;
                        uploadRequest.fields['vehicle_id'] = vehicle_id;
                        uploadRequest.fields['product_id'] = product_id;
                        uploadRequest.fields['collection_qty'] = collection_qty;
                        uploadRequest.fields['collection_vat'] = collection_vat;
                        uploadRequest.fields['collection_amount'] =
                            collection_amount;
                        uploadRequest.fields['collection_signatory'] =
                            signatoryController.text;
                        uploadRequest.fields['payment_mode'] = _type;
                        uploadRequest.fields['payment_status'] =
                            _dropdownValue1;
                        uploadRequest.fields['email'] =
                            emailSignatoryController.text;
                        uploadRequest.fields['account_email'] =
                            accountEmailSignatoryController.text;
                        uploadRequest.fields['po_no'] = ponController.text;

                        // uploadRequest.fields['depo_id'] =
                        //     displayDropdownValue.toString();
                        uploadRequest.files.add(file);
                        uploadRequest.files.add(file1);
                        print(uploadRequest.fields);
                        final streamedResponse = await uploadRequest.send();
                        final response =
                            await http.Response.fromStream(streamedResponse);

                        try {
                          print(
                              "><>>>>>>>>>>>" + response.statusCode.toString());
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
                                'collection_qty':
                                    data['data']['collection_qty'].toString(),
                                'collection_vat':
                                    data['data']['collection_vat'].toString(),
                                'collection_amount': data['data']
                                        ['collection_amount']
                                    .toString(),
                                'collection_number': data['data']
                                        ['collection_number']
                                    .toString(),
                                'collection_date':
                                    data['data']['collection_date'].toString(),
                                'consignment_no': data['data']['consignment']
                                        ['consignment_number']
                                    .toString(),
                                'product_info': data['data']['product']
                                            ['product_name']
                                        .toString() +
                                    " - " +
                                    data['data']['product']['product_ewc']
                                        .toString(),
                              },
                            );
                          } else if (response.statusCode == 401) {
                            setState(() {
                              _loading = false;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
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
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.getKeys();
                            for (String key in prefs.getKeys()) {
                              if (key != "mDateKey") {
                                prefs.remove(key);
                              }
                            }
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            setState(() {
                              _loading = false;
                            });
                          }
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Signatures can't be empty",
                            toastLength: Toast.LENGTH_SHORT);
                      }
                    }
                  } else {
                    setState(() {
                      _autoValidate = true;
                    });
                  }
                }
                //   _launchURLBrowser("https://wloapp.crowdrcrm.com/admin/sage?token=96898bb8544fa56b03c08cdc09886c6c&job_id=65&amount=100");
              },
              child: Text(
                "Confirm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 20.0,
      ),
    ]);
  }

  _launchURLBrowser(url) async {
    // const url = 'https://flutterdevs.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              /*buildUserInfo(context),
              buildDrawerItem(),*/
            ],
          ),
        ),
        appBar: AppBar(
          leading: InkWell(
            child: IconButton(
              icon: Image(
                image: AssetImage("assets/images/back_arrow.png"),
                height: 25.0,
                width: 25.0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
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
                  child: Text('Job Complete', style: normalText),
                ),
              ),
            ]),
          ),
          flexibleSpace: Container(
            height: 100,
            color: Color(0xfffbefa7),
          ),
          actions: <Widget>[
            /*IconButton(
              icon: Image(
                image: AssetImage("assets/images/notifications.png"),
                height: 30.0,
                width: 30.0,
              ),
              onPressed: () async {},
            ),*/
          ],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.transparent,
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Container(
              child: Scrollbar(
                thickness: 6,
                child: ListView(children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: deviceSize.width * 0.03,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(
                            height: 20.0,
                          ),
                          Container(child: quizList()),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )),
                ]),
              ),
            ),
          ),
        ));
  }
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8,
        Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatermarkPaint &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['payment_value'].toString(),
        THIRD_LEVEL_NAME: json['payment_mode']);
  }
}
