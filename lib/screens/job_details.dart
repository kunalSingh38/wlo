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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/screens/conversation.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class JobsDetails extends StatefulWidget {
  final Object argument;

  const JobsDetails({Key key, this.argument}) : super(key: key);

  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<JobsDetails> {
  Future<dynamic> _checkList;
  var amountController;
  var qtyController;
  //final qtyController = TextEditingController();
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  String html_currency_code = '';
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  String job_id;
  String _dropdownValue = 'Cash';
  String name = "Cash";
  bool isEnabled1 = true;

  bool isEnabled2 = false;
  bool isEnabled3 = false;
  bool isEnabled4 = false;
  List<Region> _region = [];
  Future _productData;
  String catData = "";
  String customer_contactemail = "";
  String customer_accountemail = "";
  String po_no = "";
  String selectedRegion;
  var _type = "";
  var customer_accounttype = "";
  var displayDropDown = "";
  String jobName = "";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    job_id = data['job_id'];
    _getUser();
  }

  static void openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl) != null) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
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
            print(_type);
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
    } else {
      _showCompulsoryUpdateDialog(
        context,
        "Please refresh again",
      );
    }
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

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xff000000));
  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalTex3 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));

  double lat = 0.0;
  double lng = 0.0;
  var vat = 0.0;
  Future _checkListData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/job/$job_id"),
      headers: headers,
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        vat = double.parse(data['data']['job_vat']);
        displayDropDown =
            data['data']['depot']['displayDropdown'].toString() == "true"
                ? "true"
                : "false";
        customer_accounttype =
            data['data']['customer']['customer_accounttype'].toString();
        if (data['data']['customer']['customer_primarycontactemail'] != null) {
          customer_contactemail = data['data']['customer']
                  ['customer_primarycontactemail']
              .toString();
        } else {
          customer_contactemail = "";
        }
        if (data['data']['customer']['customer_accountemail'] != null) {
          customer_accountemail =
              data['data']['customer']['customer_accountemail'].toString();
        } else {
          customer_accountemail = "";
        }

        if (data['data']['po_no'] != null) {
          po_no = data['data']['po_no'].toString();
        } else {
          po_no = "";
        }

        amountController =
            TextEditingController(text: data['data']['job_amount']);
        qtyController = TextEditingController(text: data['data']['job_qty']);
      });
      if (data['data']['customer']['customer_lat'] != null) {
        lat = double.parse(data['data']['customer']['customer_lat']);
        lng = double.parse(data['data']['customer']['customer_lng']);
      }
      selectedRegion = data['data']['product']['product_name'] +
          " - " +
          data['data']['product']['product_ewc'].toString();
      _productData = _getProductCategories();
      jobName = data['data']['customer']['customer_businessname'].toString();
      return data;
    } else if (response.statusCode == 401) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.getKeys();
      for (String key in preferences.getKeys()) {
        if (key != "mDateKey") {
          preferences.remove(key);
        }
      }
      Navigator.pushReplacementNamed(context, '/login');
    } else if (response.statusCode == 403) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.getKeys();
      for (String key in preferences.getKeys()) {
        if (key != "mDateKey") {
          preferences.remove(key);
        }
      }
      Navigator.pushReplacementNamed(context, '/login');
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

  Future<bool> _logoutPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              "Are you sure",
            ),
            content: new Text("Do you want to Log Out?"),
            actions: <Widget>[
              new ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Color(0xff0347FD),
                  ),
                ),
              ),
              new ElevatedButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.getKeys();
                  for (String key in preferences.getKeys()) {
                    if (key != "mDateKey") {
                      preferences.remove(key);
                    }
                  }

                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login-new');
                },
                child:
                    new Text("Yes", style: TextStyle(color: Color(0xff0347FD))),
              ),
            ],
          ),
        )) ??
        false;
  }

  buildUserInfo(context) => Container(
        color: Color(0xff0347FD),
        padding: EdgeInsets.only(bottom: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
              },
              leading: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              "Hello,",
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              "!",
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            )
          ],
        ),
      );

  Widget buildDrawerItem() {
    return Flexible(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[],
            ),
            InkWell(
              onTap: () async {
                _logoutPop();
              },
              child: ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Color(0xff0347FD),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xff0347FD),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleTextBox2() {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Html(
              data: html_currency_code == null
                  ? ""
                  : html_currency_code + " " + vat.toStringAsFixed(2))),
    ));
  }

  Widget _titleTextBox3(_initialValue) {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(_initialValue)),
    ));
  }

  Widget _titleTextBox(_initialValue) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        margin: const EdgeInsets.only(right: 8.0),
        child: TextFormField(
            // inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
            controller: amountController,
            keyboardType: TextInputType.number,
            cursorColor: Color(0xff000000),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter emp code';
              }
              return null;
            },
            onSaved: (String value) {
              amountController.text = value;
            },
            onChanged: (String value) {
              var amount = amountController.text;
              if (amountController.text != "") {
                setState(() {
                  vat = double.parse(amount.toString()) -
                      (double.parse(amount.toString()) / 1.2);
                  print(">>>>>>>>>>>>>>>>" + amountController.text.toString());
                  print(">>>>>>>>>>>>>>>>" + vat.toStringAsFixed(2));
                });
              } else {
                setState(() {
                  vat = 0.0;
                });
              }
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

  Widget quizList() {
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var errorCode = snapshot.data['status'];
          var response = snapshot.data['data'];
          if (errorCode == 200) {
            return ListView(children: <Widget>[
              Column(children: <Widget>[
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
                                child: Text(
                                    response['customer']
                                        ['customer_businessname'],
                                    softWrap: true,
                                    maxLines: 2,
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
                                response['customer']['customer_address1'] +
                                    ", " +
                                    response['customer']['customer_address2'] +
                                    ", " +
                                    response['customer']['postcode'],
                                softWrap: true,
                                maxLines: 2,
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
                            child: Text(
                                response['customer']['customer_accountnumber'],
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
                            child: Text(
                                response['customer']['customer_primaryphone'],
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
                            image: AssetImage("assets/images/calendar.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Expanded(
                            child: Text(response['job_date'],
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
                      // width: MediaQuery.of(context).size.width * 0.60,
                      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0),
                          border: Border.all(
                            color: Color(0xffcdcbcb),
                          )),
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
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              margin: const EdgeInsets.only(right: 8.0),
                              child: TextFormField(
                                  //  inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Color(0xff000000),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  /* validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter emp code';
                                                }
                                                return null;
                                              },*/
                                  onSaved: (String value) {
                                    qtyController.text = value;
                                  },
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                          _titleTextBox(response['job_amount'])
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
                            child: Text("Remarks" + "  :- ",
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: normalText1),
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          _titleTextBox3(response['job_remarks'])
                        ]),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                  ]),
                ),
              ]),
            ]);
          } else {
            return _emptyOrders();
          }
        } else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        //m8 resizeToAvoidBottomInset: false,
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
                  child: Text('Job Details', style: normalText),
                ),
              ),
            ]),
          ),
          flexibleSpace: Container(
            height: 100,
            color: Color(0xfffbefa7),
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  // print(job_id.toString());

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Conversation(
                                jobId: job_id.toString(),
                                jobName: jobName,
                              )));
                },
                icon: Icon(Icons.message, color: Color(0xffb5322f)))
          ],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: deviceSize.width * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Expanded(child: Container(child: quizList())),
                  Row(children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 50,
                        height: 50.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffb5322f),
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              //background color of box
                              BoxShadow(
                                color: Color(0xffb5322f),
                                blurRadius: 2.0, // soften the shadow
                                spreadRadius: 2.0, //extend the shadow
                                offset: Offset(
                                  0.0, // Move to right 10  horizontally
                                  0.0, // Move to bottom 10 Vertically
                                ),
                              )
                            ],
                          ),
                          child: RaisedButton(
                            splashColor: Color(0xffb5322f),
                            padding: const EdgeInsets.only(
                                top: 2, bottom: 2, left: 20, right: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            textColor: Color(0xfffbefa7),
                            color: Color(0xffb5322f),
                            onPressed: () async {
                              openMap(lat, lng);
                            },
                            child: Text(
                              "Navigate",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 50,
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
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/job-complete',
                                arguments: <String, String>{
                                  'job_id': job_id.toString(),
                                  'vehicle_id': vehicle_no.toString(),
                                  'product_id': _type.toString(),
                                  'product_name': selectedRegion.toString(),
                                  'collection_qty': qtyController.text,
                                  'collection_vat': vat.toStringAsFixed(2),
                                  'collection_amount': amountController.text,
                                  'customer_accounttype': customer_accounttype,
                                  'customer_contactemail':
                                      customer_contactemail,
                                  'customer_accountemail':
                                      customer_accountemail,
                                  'po_no': po_no,
                                  'displayDropdown': displayDropDown
                                },
                              );
                              print(jsonEncode({
                                'job_id': job_id.toString(),
                                'vehicle_id': vehicle_no.toString(),
                                'product_id': _type.toString(),
                                'product_name': selectedRegion.toString(),
                                'collection_qty': qtyController.text,
                                'collection_vat': vat.toStringAsFixed(2),
                                'collection_amount': amountController.text,
                                'customer_accounttype': customer_accounttype,
                                'customer_contactemail': customer_contactemail,
                                'customer_accountemail': customer_accountemail,
                                'po_no': po_no,
                                'displayDropdown': displayDropDown
                              }));
                            },
                            child: Text(
                              "Complete",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              )),
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
