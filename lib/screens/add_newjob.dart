import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class AddNewJob extends StatefulWidget {
  final Object argument;

  const AddNewJob({Key key, this.argument}) : super(key: key);

  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<AddNewJob> {
  Future<dynamic> _checkList;
  final amountController = TextEditingController();
  final vatController = TextEditingController();
  final qtyController = TextEditingController();
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  int id = 0;
  bool _autoValidate = false;
  bool valuefirst = false;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  var cust_id;
  String _dropdownValue = 'Cash';
  String name = "Cash";
  bool isEnabled1 = true;
  final fromDateController = TextEditingController();
  final remarksController = TextEditingController();
  var finalDate;
  bool isEnabled2 = false;
  bool isEnabled3 = false;
  bool isEnabled4 = false;
  List<Region> _region = [];
  Future _productData;
  String catData = "";
  String selectedRegion = "";
  String html_currency_code = "";
  var _type = "";
  final format = DateFormat("yyyy-MM-dd HH:mm");
  final initialValue = DateTime.now();
  String formattedDate1;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    var now = new DateTime.now();
    var firstDate = DateTime.utc(now.year, now.month, 1);
    var formatter = new DateFormat('dd-MM-yyyy');
    formattedDate1 = formatter.format(now);
    fromDateController.text = formattedDate1;
    cust_id = data['cust_id'];
    print("..............." + cust_id.toString());
    _getUser();
  }

  Future _getProductCategories() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/products"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['data'];
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
            _type = _region[0].THIRD_LEVEL_ID;
          }
        });
      }

      return result;
    } else if (response.statusCode == 401) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getKeys();
      for (String key in prefs.getKeys()) {
        if (key != "mDateKey") {
          prefs.remove(key);
        }
      }
      Navigator.pushReplacementNamed(context, '/login');
    } else if (response.statusCode == 403) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getKeys();
      for (String key in prefs.getKeys()) {
        if (key != "mDateKey") {
          prefs.remove(key);
        }
      }
      Navigator.pushReplacementNamed(context, '/login');
    }
    /*else{
      _showCompulsoryUpdateDialog(
        context,
        "Please refresh again",
      );
    }*/
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        html_currency_code = prefs.getString('html_currency_code').toString();
        _checkList = _checkListData();
      });
    });
  }

  _showCompulsoryUpdateDialog(context, String message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "Please refresh again...";
        String btnLabel = "ok";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      btnLabel,
                    ),
                    isDefaultAction: true,
                    onPressed: _onUpdateNowClicked,
                  ),
                ],
              )
            : new AlertDialog(
                title: Text(
                  title,
                  style: TextStyle(fontSize: 22),
                ),
                content: Text(message),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(btnLabel),
                    onPressed: _onUpdateNowClicked,
                  ),
                ],
              );
      },
    );
  }

  _onUpdateNowClicked() {
    setState(() {
      _checkList = _checkListData();
    });
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xff000000));
  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalTex3 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));

  Future _checkListData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/customer/$cust_id"),
      headers: headers,
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      _productData = _getProductCategories();
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text(
        'NO RECORDS FOUND!',
        style: TextStyle(fontSize: 20, letterSpacing: 1, color: Colors.white),
      )),
    );
  }

  void callDatePicker2() async {
    var order = await getDate2();
    setState(() {
      finalDate = order;
      var formatter = new DateFormat('dd-MM-yyyy');
      String formatted = formatter.format(finalDate);
      print(formatted);
      fromDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate2() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Color(0xfffbefa7),
              accentColor: Color(0xfffbefa7),
              primarySwatch: MaterialColor(
                0xfffbefa7,
                const <int, Color>{
                  50: const Color(0xfffbefa7),
                  100: const Color(0xfffbefa7),
                  200: const Color(0xfffbefa7),
                  300: const Color(0xfffbefa7),
                  400: const Color(0xfffbefa7),
                  500: const Color(0xfffbefa7),
                  600: const Color(0xfffbefa7),
                  700: const Color(0xfffbefa7),
                  800: const Color(0xfffbefa7),
                  900: const Color(0xfffbefa7),
                },
              )),
          child: child,
        );
      },
    );
  }

  var vat = 0.0;
  Widget _titleTextBox() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: TextFormField(
            //inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
            controller: amountController,
            keyboardType: TextInputType.number,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter amount';
              }

              return null;
            },
            onSaved: (String value) {
              amountController.text = value;
              print(">>>>>>>>>>>>>>>>" + amountController.text.toString());
            },
            onChanged: (String value) {
              setState(() {
                var amount = amountController.text;
                if (amountController.text != "") {
                  vat = double.parse(amount.toString()) -
                      (double.parse(amount.toString()) / 1.2);
                  print(">>>>>>>>>>>>>>>>" + amountController.text.toString());
                  print(">>>>>>>>>>>>>>>>" + vat.toStringAsFixed(2));
                }
              });
            },
            decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                hintText: '',
                hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                fillColor: Color(0xffffffff),
                filled: true)),
      ),
    );
  }

  Widget _titleTextBox4() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: TextFormField(
            controller: remarksController,
            keyboardType: TextInputType.text,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            minLines:
                6, // any number you need (It works as the rows for the textarea)
            // keyboardType: TextInputType.multiline,
            maxLines: null,
            onSaved: (String value) {
              remarksController.text = value;
            },
            decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                hintText: '',
                hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                fillColor: Color(0xffffffff),
                filled: true)),
      ),
    );
  }

  Widget _titleTextBox2() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child:
                Html(data: html_currency_code + " " + vat.toStringAsFixed(2))),
      ),
    );
  }

  Widget _titleTextBox3() {
    return Expanded(
      child: Container(
        /*   decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            //background color of box
            BoxShadow(
              color: Color(0xffe0e0e0),
              blurRadius: 1.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                0.0, // Move to right 10  horizontally
                0.0, // Move to bottom 10 Vertically
              ),
            )
          ],
        ),*/
        margin: const EdgeInsets.only(right: 8.0),
        child: InkWell(
          onTap: () {
            callDatePicker2();
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: TextFormField(
              controller: fromDateController,
              keyboardType: TextInputType.text,
              cursorColor: Color(0xff000000),
              textCapitalization: TextCapitalization.sentences,
              enabled: false,
              onSaved: (String value) {
                fromDateController.text = value;
              },
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                  hintText: '',
                  hintStyle: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                  fillColor: Color(0xffffffff),
                  filled: true)),
        ),
      ),
    );
  }

  Widget quizList() {
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: Container(child: CircularProgressIndicator()));
        } else {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            if (snapshot.hasData) {
              var errorCode = snapshot.data['status'];
              var response = snapshot.data['data'];
              if (errorCode == 200) {
                return Column(children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFe3e3e3)),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: Column(children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Row(children: [
                            Image(
                              image: AssetImage("assets/images/user.png"),
                              height: 17.0,
                              width: 17.0,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: BorderedText(
                                  strokeWidth: 1.0,
                                  strokeColor: Color(0xfffbefa7),
                                  child: Text(response['customer_businessname'],
                                      softWrap: true,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: normalText),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Row(children: [
                            Image(
                              image: AssetImage("assets/images/location.png"),
                              height: 17.0,
                              width: 17.0,
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Expanded(
                              child: Text(
                                  response['customer_address1'] +
                                      ", " +
                                      response['customer_address2'] +
                                      " , " +
                                      response['postcode'],
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTex2),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Row(children: [
                            Image(
                              image: AssetImage("assets/images/package.png"),
                              height: 17.0,
                              width: 17.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text(response['customer_accountnumber'],
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTex2),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Row(children: [
                            Image(
                              image: AssetImage("assets/images/call.png"),
                              height: 17.0,
                              width: 17.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text(response['customer_primarycontact'],
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTex2),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFe3e3e3)),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: Column(children: <Widget>[
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
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(color: Color(0xffcdcbcb))),
                        margin: const EdgeInsets.only(right: 8.0),
                        child: DropdownButtonHideUnderline(
                          child: Padding(
                            padding: EdgeInsets.only(right: 0, left: 0),
                            child: new DropdownButton<String>(
                              isExpanded: true,
                              hint: new Text(
                                "",
                                style: TextStyle(
                                    color: Color(0xffcdcbcb), fontSize: 16),
                              ),
                              icon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, right: 10),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ),
                              value: selectedRegion,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() {
                                  selectedRegion = newValue;
                                  List<String> item = _region.map((Region map) {
                                    for (int i = 0; i < _region.length; i++) {
                                      if (selectedRegion ==
                                          map.THIRD_LEVEL_NAME) {
                                        _type = map.THIRD_LEVEL_ID;
                                        return map.THIRD_LEVEL_ID;
                                      }
                                    }
                                  }).toList();
                                });
                              },
                              items: _region.map((Region map) {
                                return new DropdownMenuItem<String>(
                                  value: map.THIRD_LEVEL_NAME,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: new Text(map.THIRD_LEVEL_NAME,
                                        softWrap: true,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: new TextStyle(
                                            color: Color(0xff000000),
                                            fontSize: 16)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
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
                                width: MediaQuery.of(context).size.width * 0.60,
                                margin: const EdgeInsets.only(right: 8.0),
                                child: TextFormField(
                                    //   inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                                    controller: qtyController,
                                    keyboardType: TextInputType.number,
                                    cursorColor: Color(0xff000000),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter quantity';
                                      }
                                      return null;
                                    },
                                    onSaved: (String value) {
                                      qtyController.text = value;
                                    },
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 20, 20, 0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Color(0xffcdcbcb),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Color(0xffcdcbcb),
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Color(0xffcdcbcb),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Color(0xffcdcbcb),
                                          ),
                                        ),
                                        counterText: "",
                                        hintText: '',
                                        hintStyle: TextStyle(
                                            color: Color(0xffcdcbcb),
                                            fontSize: 16),
                                        fillColor: Color(0xffffffff),
                                        filled: true)),
                              ),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.10,
                              child: Text("Litres",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTex2),
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
                            _titleTextBox()
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
                            _titleTextBox2()
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
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Text("Date" + "  :- ",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalText1),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            _titleTextBox3()
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
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Text("Remarks" + "  :- ",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalText1),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            _titleTextBox4()
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 15.0,
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
                              blurRadius: 0.5, // soften the shadow
                              spreadRadius: 0.5, //extend the shadow
                              offset: Offset(
                                0.0, // Move to right 10  horizontally
                                0.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        child: RaisedButton(
                          splashColor: Color(0xfffbefa7),
                          padding: const EdgeInsets.only(
                              top: 2, bottom: 2, left: 20, right: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          textColor: Color(0xffb5322f),
                          color: Color(0xfffbefa7),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              setState(() {
                                _loading = true;
                              });
                              Map<String, String> headers = {
                                'Accept': 'application/json',
                                'Authorization': 'Bearer $access_token',
                              };
                              var response = await http.post(
                                Uri.parse(URL + "/job/create"),
                                body: {
                                  "customer_id": cust_id,
                                  "product_id": _type,
                                  "job_date": fromDateController.text,
                                  "job_qty": qtyController.text,
                                  "job_amount": amountController.text,
                                  "job_vat": vat.toStringAsFixed(2),
                                  "job_remarks": remarksController.text,
                                },
                                headers: headers,
                              );
                              print({
                                "customer_id": cust_id,
                                "product_id": _type,
                                "job_date": fromDateController.text,
                                "job_qty": qtyController.text,
                                "job_amount": amountController.text,
                                "job_vat": vat.toStringAsFixed(2),
                                "job_remarks": remarksController.text,
                              });
                              var data = json.decode(response.body);
                              print(data);
                              if (response.statusCode == 201) {
                                setState(() {
                                  _loading = false;
                                });
                                Fluttertoast.showToast(
                                    msg: "Job created successfully",
                                    toastLength: Toast.LENGTH_SHORT);

                                Navigator.of(context).pop();
                                Navigator.pushNamed(
                                  context,
                                  '/jobs-pagination',
                                );
                                /* Navigator.pushNamed(
                                    context,
                                    '/job-details',
                                    arguments: <String, String>{
                                      'job_id': data['data']['id'].toString(),
                                    },
                                  );*/

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
                                var errorMessage = data['errors'][0]['message'];
                                showAlertDialog(
                                    context, ALERT_DIALOG_TITLE, errorMessage);
                              }
                            } else {
                              setState(() {
                                _autoValidate = true;
                              });
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]);
              } else {
                return _emptyOrders();
              }
            } else {
              return Text("No DAta");
            }
          }
        }
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        //   resizeToAvoidBottomInset: false,
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
                  child: Text('Add New Job', style: normalText),
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
                margin: EdgeInsets.symmetric(
                  horizontal: deviceSize.width * 0.05,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(child: quizList()),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                )),
          ),
        ));
  }
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['product_id'].toString(),
        THIRD_LEVEL_NAME: json['product_name'] + " - " + json['product_ewc']);
  }
}
