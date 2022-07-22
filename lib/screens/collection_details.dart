import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class CollectionDetails extends StatefulWidget {
  final Object argument;

  const CollectionDetails({Key key, this.argument}) : super(key: key);

  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<CollectionDetails> {
  Future<dynamic> _checkList;
  var amountController;
  var qtyController;
  //final qtyController = TextEditingController();
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  String job_id;
  String _dropdownValue = 'Cash';
  String name = "Cash";
  bool isEnabled1 = true;
  String html_currency_code = "";
  String collection_tnc = "";
  String tipping_tnc = "";

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    job_id = data['job_id'];
    _getUser();
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
                  FlatButton(
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
        collection_tnc = prefs.getString('collection_tnc').toString();
        tipping_tnc = prefs.getString('tipping_tnc').toString();
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
  TextStyle normalTex4 = GoogleFonts.montserrat(
      fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xffb5322f));

  double lat = 0.0;
  double lng = 0.0;
  var vat = 0.0;
  Future _checkListData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/job-collection/$job_id"),
      headers: headers,
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFe3e3e3)),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: Column(children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: BorderedText(
                        strokeWidth: 1.0,
                        strokeColor: Color(0xfffbefa7),
                        child: Text("Customer Details",
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: normalText1),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
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
                                maxLines: 3,
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
                            image: AssetImage("assets/images/package.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Expanded(
                            child: Text(response['customer']['postcode'],
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFe3e3e3)),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: Column(children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: BorderedText(
                        strokeWidth: 1.0,
                        strokeColor: Color(0xfffbefa7),
                        child: Text("Collection Details",
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: normalText1),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Row(children: [
                          Image(
                            image: AssetImage("assets/images/product_name.png"),
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
                                    response['product']['product_name'] +
                                        " - " +
                                        response['product']['product_ewc'],
                                    softWrap: true,
                                    maxLines: 3,
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
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 24),
                      child: Text("Collection No.",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: normalTex4),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Row(children: [
                          Image(
                            image: AssetImage("assets/images/collec_no.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Expanded(
                            child: Text(response['collection_number'],
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
                    Container(
                      margin: EdgeInsets.only(left: 24),
                      alignment: Alignment.topLeft,
                      child: Text("Collection Date",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: normalTex4),
                    ),
                    SizedBox(
                      height: 4.0,
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
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text(response['collection_date'],
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
                    Container(
                      margin: EdgeInsets.only(left: 24),
                      alignment: Alignment.topLeft,
                      child: Text("Collection Quantity",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: normalTex4),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Row(children: [
                          Image(
                            image: AssetImage("assets/images/quantity.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text(response['collection_qty'] + " Litres",
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
                    Container(
                      margin: EdgeInsets.only(left: 24),
                      alignment: Alignment.topLeft,
                      child: Text("Collection Vat",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: normalTex4),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Row(children: [
                          Image(
                            image: AssetImage("assets/images/vat.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Expanded(
                            child: Html(
                              data: html_currency_code +
                                  " " +
                                  response['collection_vat'],
                            ),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24),
                      alignment: Alignment.topLeft,
                      child: Text("Collection Amount",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: normalTex4),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Row(children: [
                          Image(
                            image: AssetImage("assets/images/am.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Expanded(
                            child: Html(
                              data: html_currency_code +
                                  " " +
                                  response['collection_amount'],
                            ),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24),
                      alignment: Alignment.topLeft,
                      child: Text("Consignment No.",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: normalTex4),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Row(children: [
                          Image(
                            image: AssetImage("assets/images/collec_no.png"),
                            height: 17.0,
                            width: 17.0,
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                          Expanded(
                            child: Text(
                                response['consignment']['consignment_number'],
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
        resizeToAvoidBottomInset: false,
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
                  child: Text('Collection Details', style: normalText),
                ),
              ),
            ]),
          ),
          flexibleSpace: Container(
            height: 100,
            color: Color(0xfffbefa7),
          ),
          actions: <Widget>[
            /* IconButton(
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
        body: Container(
          child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: deviceSize.width * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Expanded(child: Container(child: quizList())),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              )),
        ));
  }
}
