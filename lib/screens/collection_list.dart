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
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class JobsCollectionScreen extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<JobsCollectionScreen> {
  Future<dynamic> _checkList;
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  int id = 0;
  bool valuefirst = true;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  final GlobalKey scaffoldKey = GlobalKey();
  bool isEnabled1 = true;
  bool enable = false;
  bool view = false;
  int totalCount = 0;
  int pageCount = 0;
  bool isEnabled2 = false;
  bool isEnabled3 = false;
  bool isEnabled4 = false;

  bool isEnabled5 = true;
  bool isEnabled6 = false;

  bool isEnabled7 = true;
  bool isEnabled8 = false;
  List<LatLng> loc = new List();
  List cusName = new List();
  List cusId = new List();
  List cusInfo = new List();
  GoogleMapController mapController; //contrller for Google map
  final Set<Marker> markers = new Set(); //markers for google map
  LatLng showLocation; //location to show in map

  List<bool> isChecked = new List();
  String name = "";

  bool text1 = false;
  bool text2 = false;
  final postCodeController = TextEditingController();
  final bNameController = TextEditingController();
  int page1 = 1;
  int page = 1;
  ScrollController _sc = new ScrollController();
  String html_currency_code = "";
  String collection_tnc = "";
  String tipping_tnc = "";

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        name = prefs.getString('driverName').toString();
        html_currency_code = prefs.getString('html_currency_code').toString();
        collection_tnc = prefs.getString('collection_tnc').toString();
        tipping_tnc = prefs.getString('tipping_tnc').toString();
        _checkList = _checkListData();
        /* _sc.addListener(() {

          if (_sc.position.pixels == _sc.position.maxScrollExtent) {
            setState(() {
              _checkList = _checkListData("page=$page1&per-page=8");
            });
          }

        });*/
      });
    });
  }

  void _profileData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var uri = Uri.parse(URL + '/profile');
    var response = await http.get(
      uri,
      headers: headers,
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        name = data['data']['first_name'] + " " + data['data']['last_name'];
        prefs.setString('driverName', name.toString());
      });
    }
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalTex4 = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );
  TextStyle normalTex3 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff000000));

  TextStyle normalText5 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));

  var responseList;

  Future _checkListData() async {
    loc.clear();
    cusName.clear();
    cusInfo.clear();
    cusId.clear();
    setState(() {
      _loading = true;
    });
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };

    var uri = Uri.parse(URL + '/job-collections');

    print(uri);
    var response = await http.get(
      uri,
      headers: headers,
    );
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      print(data);
      responseList = data['data'];

      if (data['data'].length != 0) {
        print(data['__meta']);
        setState(() {
          view = false;
          totalCount = data['__meta']['totalCount'];
          pageCount = data['data'].length;
          for (int i = 0; i < data['data'].length; i++) {
            isChecked.add(true);
            list.add(responseList[i]['id'].toString());
            enable = true;
          }
        });
      } else {
        setState(() {
          valuefirst = false;
        });
      }
      return data;
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
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text(
        'NO COLLECTION FOUND!',
        style:
            TextStyle(fontSize: 20, letterSpacing: 1, color: Color(0xffb5322f)),
      )),
    );
  }

  List<String> list = [];

  Widget quizList() {
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: Container());
        } else {
          if (snapshot.hasError) {
            _loading = false;
            return Column(children: <Widget>[Container()]);
          } else {
            if (snapshot.hasData) {
              var errorCode = snapshot.data['status'];
              var response = snapshot.data['data'];
              if (errorCode == 200) {
                if (response.length != 0) {
                  return Scrollbar(
                    thickness: 6,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        controller: _sc,
                        itemCount: response.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/collection-details',
                                arguments: <String, String>{
                                  'job_id': response[index]['id'].toString(),
                                },
                              );
                            },
                            child: Row(children: <Widget>[
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Color(0xffb5322f),
                                value: isChecked[index],
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isChecked[index] = value;
                                      if (isChecked[index] == true) {
                                        enable = true;
                                        print(isChecked);

                                        list.add(
                                            response[index]['id'].toString());
                                        print(list);
                                      } else if (isChecked[index] == false) {
                                        list.remove(
                                            response[index]['id'].toString());
                                        print(isChecked);
                                        print(list);
                                        valuefirst = false;
                                        if (isChecked.contains(true)) {
                                          enable = true;
                                        } else {
                                          enable = false;
                                        }
                                      } else {
                                        if (isChecked.contains(true)) {
                                          enable = true;
                                        } else {
                                          enable = false;
                                        }

                                        print(isChecked);
                                      }
                                    },
                                  );
                                },
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 5, top: 7, bottom: 7),
                                  margin: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border:
                                          Border.all(color: Color(0xFFe3e3e3)),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                  child: Column(children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        child: Row(children: [
                                          Image(
                                            image: AssetImage(
                                                "assets/images/user.png"),
                                            height: 16.0,
                                            width: 16.0,
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
                                                    response[index]['customer'][
                                                        'customer_businessname'],
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: normalText),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                              child: Row(children: [
                                                Image(
                                                  image: AssetImage(
                                                      "assets/images/product_name.png"),
                                                  height: 17.0,
                                                  width: 17.0,
                                                ),
                                                SizedBox(
                                                  width: 6.0,
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: BorderedText(
                                                      strokeWidth: 1.0,
                                                      strokeColor:
                                                          Color(0xfffbefa7),
                                                      child: Text(
                                                          response[index][
                                                                      'product']
                                                                  [
                                                                  'product_name'] +
                                                              "-" +
                                                              response[index][
                                                                      'product']
                                                                  [
                                                                  'product_ewc'],
                                                          softWrap: true,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: normalText1),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Container(
                                                child: Row(children: [
                                                  Image(
                                                    image: AssetImage(
                                                        "assets/images/collec_no.png"),
                                                    height: 17.0,
                                                    width: 17.0,
                                                  ),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                        response[index][
                                                            'collection_number'],
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: normalTex3),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        ]),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                              child: Row(children: [
                                                Image(
                                                  image: AssetImage(
                                                      "assets/images/quantity.png"),
                                                  height: 17.0,
                                                  width: 17.0,
                                                ),
                                                SizedBox(
                                                  width: 6.0,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      response[index][
                                                              'collection_qty'] +
                                                          " Litres",
                                                      softWrap: true,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: normalTex3),
                                                )
                                              ]),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Container(
                                                child: Row(children: [
                                                  Image(
                                                    image: AssetImage(
                                                        "assets/images/am.png"),
                                                    height: 17.0,
                                                    width: 17.0,
                                                  ),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Expanded(
                                                    child: Html(
                                                      data: html_currency_code +
                                                          " " +
                                                          response[index][
                                                              'collection_amount'],
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        ]),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                              child: Row(children: [
                                                Image(
                                                  image: AssetImage(
                                                      "assets/images/calendar.png"),
                                                  height: 17.0,
                                                  width: 17.0,
                                                ),
                                                SizedBox(
                                                  width: 6.0,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      response[index]
                                                          ['collection_date'],
                                                      softWrap: true,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: normalTex2),
                                                ),
                                              ]),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: InkWell(
                                                child: Container(
                                                  child: Row(children: [
                                                    Image(
                                                      image: AssetImage(
                                                          "assets/images/vat.png"),
                                                      height: 17.0,
                                                      width: 17.0,
                                                    ),
                                                    SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Expanded(
                                                        child: Html(
                                                      data: html_currency_code +
                                                          " " +
                                                          response[index][
                                                              'collection_vat'],
                                                    )),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ]),
                                ),
                              ),
                            ]),
                          );
                        }),
                  );
                } else {
                  return _emptyOrders();
                }
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

  _launchCaller(String number) async {
    String url = 'tel:' + number;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List collections = new List();
  Future<void> _pullRefresh() async {}
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
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
                  child: Text('Collections', style: normalText),
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
              icon: Image(
                image: AssetImage("assets/images/refresh.png"),
                color: Color(0xffb5322f),
                height: 26.0,
                width: 26.0,
              ),
              onPressed: () async {
                _checkList = _checkListData();
              },
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.transparent,
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Container(
            child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: deviceSize.width * 0.02,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 15.0,
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Color(0xffb5322f),
                                      value: this.valuefirst,
                                      onChanged: (bool value) {
                                        setState(() {
                                          isChecked.clear();
                                          list.clear();
                                          this.valuefirst = value;

                                          if (valuefirst == true) {
                                            enable = true;
                                            for (int i = 0;
                                                i < responseList.length;
                                                i++) {
                                              isChecked.add(true);
                                              list.add(responseList[i]['id']
                                                  .toString());
                                              print(isChecked);
                                              print(list);
                                            }
                                          } else if (valuefirst == false) {
                                            for (int i = 0;
                                                i < responseList.length;
                                                i++) {
                                              isChecked.add(false);
                                              list.remove(responseList[i]['id']
                                                  .toString());
                                              print(isChecked);
                                              print(list);
                                            }
                                            if (isChecked.contains(true)) {
                                              enable = true;
                                            } else {
                                              enable = false;
                                            }
                                          } else {
                                            if (isChecked.contains(true)) {
                                              enable = true;
                                            } else {
                                              enable = false;
                                            }

                                            print(isChecked);
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      "Check All",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                    ),
                                  ]),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                                "Displaying- " +
                                    pageCount.toString() +
                                    " of " +
                                    totalCount.toString(),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: normalTex2),
                          ),
                        ]),
                    Expanded(child: Container(child: quizList())),
                    SizedBox(
                      height: 10.0,
                    ),
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
                              splashColor: Color(0xffb5322f),
                              padding: const EdgeInsets.only(
                                  top: 2, bottom: 2, left: 20, right: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                              textColor: Color(0xfffbefa7),
                              color: Color(0xffb5322f),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushNamed(
                                    context, '/jobs-pagination');
                              },
                              child: Text(
                                "Back",
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
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
                              color: enable
                                  ? Color(0xfffbefa7)
                                  : Colors.grey.shade200,
                              onPressed: () async {
                                if (enable) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  Map<String, String> headers = {
                                    'Accept': 'application/json',
                                    'Authorization': 'Bearer $access_token',
                                  };
                                  var params = {
                                    "id[]": list,
                                  };
                                  var uri = Uri.parse(URL + "/tipping-process")
                                      .replace(queryParameters: params);

                                  print(uri);
                                  var response = await http.get(
                                    uri,
                                    headers: headers,
                                  );
                                  var data = json.decode(response.body);
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      _loading = false;
                                    });
                                    print(data);
                                    List tList = new List();
                                    if (data['data'].length != 0) {
                                      for (int i = 0;
                                          i < data['data'].length;
                                          i++) {
                                        tList.add(data['data'][i]);
                                      }
                                      setState(() {
                                        collections.addAll(tList);
                                      });

                                      Navigator.pushNamed(
                                        context,
                                        '/create-tip',
                                        arguments: <String, dynamic>{
                                          'collections_list': collections,
                                        },
                                      );
                                    }
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
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Please checked at least one collection.",
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                              },
                              child: Text(
                                "Tip",
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                )),
          ),
        ));
  }
}
