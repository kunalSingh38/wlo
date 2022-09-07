import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/main.dart';
import 'package:wlo_master/screens/send_mesage.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class JobsScreen11 extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<JobsScreen11> {
  Future<dynamic> _checkList;
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  String currency = '';
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  final GlobalKey scaffoldKey = GlobalKey();
  bool isEnabled1 = true;

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
  List loc = new List();
  List cusName = new List();
  List cusId = new List();
  List cusInfo = new List();
  GoogleMapController mapController; //contrller for Google map
  Set<Marker> markers = new Set(); //markers for google map
  LatLng showLocation; //location to show in map

  String name = "";

  bool text1 = false;
  bool text2 = false;
  bool text3 = false;
  final postCodeController = TextEditingController();
  final bNameController = TextEditingController();

  List<City> _city = [];
  String catData = "";
  String cityData = "";
  String profile_pic = "";
  String selectedCity;
  var _type1 = "";
  bool isLoading = false;
  ScrollController _sc = new ScrollController();
  int page = 1;
  int page1;
  int current_page = 1;

  String callApi;

  List notificationLis = [];
  Future<void> getNotification() async {
    var response = await http.get(Uri.parse(URL + "/message/unread"), headers: {
      'Authorization': 'Bearer ' + access_token.toString(),
      'Content-Type': 'application/json'
    });
    print(access_token);
    print("---------" + response.body.toString());
    if (jsonDecode(response.body)['status'] == 200) {
      setState(() {
        notificationLis.addAll(jsonDecode(response.body)['data']['messages']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    
  }

  // bool getWeek(DateTime today) {
  //   print("week");

  //   var firstDay =
  //       DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  //   var lastday = DateTime.now()
  //       .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday));

  //   if (firstDay.isBefore(today) && lastday.isAfter(today)) {
  //     print("lie");
  //   } else {
  //     print("don't lie");
  //   }
  // }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        name = prefs.getString('driverName').toString();
        profile_pic = prefs.getString('profile_pic').toString();

        _myProfileData("", page);
        _profileData();
        _getZoneAccount();
        _sc.addListener(() {
          if (_sc.position.pixels == _sc.position.maxScrollExtent) {
            _myProfileData("", page1);
          }
        });
        getNotification();
      });
    });
  }

  Future _getZoneAccount() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/driver-zones"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['data'];

      if (mounted) {
        setState(() {
          cityData = jsonEncode(result);

          final json = JsonDecoder().convert(cityData);
          _city = (json).map<City>((item) => City.fromJson(item)).toList();
          List<String> item = _city.map((City map) {
            for (int i = 0; i < _city.length; i++) {
              if (selectedCity == map.FOURTH_LEVEL_NAME) {
                _type1 = map.FOURTH_LEVEL_ID;

                return map.FOURTH_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedCity == "") {
            selectedCity = _city[0].FOURTH_LEVEL_NAME;
          }
        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _profileData() async {
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
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        name = data['data']['first_name'] + " " + data['data']['last_name'];
        prefs.setString('driverName', name.toString());
      });

      _configData();
    }
  }

  Future _configData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    print(access_token.toString());
    var uri = Uri.parse(URL + '/config');
    var response = await http.get(
      uri,
      headers: headers,
    );
    var data = json.decode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        currency = data['data']['currency']['html_currency_code'].toString();
        prefs.setString('html_currency_code', currency);
        prefs.setString(
            'collection_tnc', data['data']['collection_tnc'].toString());
        prefs.setString('tipping_tnc', data['data']['tipping_tnc'].toString());

        for (int i = 0; i < data['data']['payment_mode'].length; i++) {
          if (data['data']['payment_mode'][i]['payment_mode'] ==
              "Online-Square") {
            prefs.setString('bearer_token',
                data['data']['payment_mode'][i]['bearer_token'].toString());
            prefs.setString(
                'square_application_id',
                data['data']['payment_mode'][i]['square_application_id']
                    .toString());
            prefs.setString('location_id',
                data['data']['payment_mode'][i]['location_id'].toString());
          }
        }
      });
    }
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));
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
  TextStyle normalText6 = GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xff000000),
      decoration: TextDecoration.underline);
  TextStyle normalText12 = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xff000000),
  );

  int t2 = 1;

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  List users = new List();

  void _myProfileData(String query, int page) async {
    if (page <= t2) {
      if (page == 1) {
        setState(() {
          isLoading = true;
        });
      }
      if (!_loading) {
        setState(() {
          _loading = true;
        });
      }
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $access_token',
      };
      var uri;
      if (query == "") {
        uri = Uri.parse(URL + '/jobs').replace(query: "page=$page");
      } else {
        uri = Uri.parse(URL + '/jobs').replace(query: query);
      }

      var response = await http.get(
        uri,
        headers: headers,
      );

      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        var data = json.decode(response.body);
        if (data['data'].length != 0) {
          var result1 = data['data'];
          totalCount = data['__meta']['totalCount'];
          current_page = data['__meta']['currentPage'];
          pageCount = pageCount + data['data'].length;

          List tList = new List();

          for (int i = 0; i < result1.length; i++) {
            tList.add(result1[i]);
            if (data['data'][i]['customer']['customer_lat'] != null) {
              showLocation = LatLng(
                  double.parse(data['data'][i]['customer']['customer_lat']),
                  double.parse(data['data'][i]['customer']['customer_lng']));

              cusName.add(data['data'][i]['customer']['customer_businessname'] +
                  ", " +
                  data['data'][i]['customer']['customer_primaryphone']);
              cusInfo.add(data['data'][i]['customer']['customer_address1'] +
                  ", " +
                  data['data'][i]['customer']['customer_address2'] +
                  ", " +
                  data['data'][i]['customer']['postcode']);
              cusId.add(data['data'][i]['id']);

              loc.add({
                "location": LatLng(
                    double.parse(data['data'][i]['customer']['customer_lat']),
                    double.parse(data['data'][i]['customer']['customer_lng'])),
                "date": data['data'][i]['job_date'].toString()
              });
            }
          }
          setState(() {
            _loading = false;
            t2 = data['__meta']['pageCount'];
            users.addAll(tList);
            page1 = page + 1;
          });
        } else {
          setState(() {
            Fluttertoast.showToast(msg: "No Records Found");
            view = true;
          });
        }
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
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "No Records Found");
      }
    }
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text(
        'NO JOBS FOUND!',
        style:
            TextStyle(fontSize: 20, letterSpacing: 1, color: Color(0xffb5322f)),
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
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Color(0xffb5322f),
                  ),
                ),
              ),
              new FlatButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.getKeys();
                  for (String key in prefs.getKeys()) {
                    if (key != "mDateKey") {
                      prefs.remove(key);
                    }
                  }
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child:
                    new Text("Yes", style: TextStyle(color: Color(0xffb5322f))),
              ),
            ],
          ),
        )) ??
        false;
  }

  buildUserInfo(context) => Container(
        color: Color(0xffb5322f),
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
            Material(
              elevation: 5.0,
              shape: CircleBorder(),
              child: CircleAvatar(
                radius: 40.0,
                backgroundImage: profile_pic != ''
                    ? NetworkImage(profile_pic)
                    : AssetImage("assets/images/avatar.png"),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              "Hello  $name!",
              style: TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
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
              children: <Widget>[
                for (Draw item in drawerItems)
                  InkWell(
                    onTap: () {
                      if (item.title == "My Account") {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile-show');
                      }
                      if (item.title == "Home") {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, '/jobs-pagination');
                      } else if (item.title == "View Checklist") {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/view-checklist');
                      } else if (item.title == "Change Password") {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/change-password');
                      } else if (item.title == "Inbox") {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/inbox-message');
                      }
                    },
                    child: ListTile(
                      leading: Image.asset(item.icon,
                          color: Color(0xffb5322f), scale: 12),
                      title: Text(
                        item.title,
                        style: TextStyle(color: Color(0xffb5322f)),
                      ),
                    ),
                  ),
              ],
            ),
            InkWell(
              onTap: () async {
                _logoutPop();
              },
              child: ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Color(0xffb5322f),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xffb5322f),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              "Are you sure",
            ),
            content: new Text("Do you want to exit an App"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Color(0xffb5322f),
                  ),
                ),
              ),
              new FlatButton(
                onPressed: () {
                  exit(0);
                },
                child:
                    new Text("Yes", style: TextStyle(color: Color(0xffb5322f))),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget mapView(List loc, List cusName, List id, List info) {
    return view != true
        ? GoogleMap(
            //Map widget from google_maps_flutter package
            zoomGesturesEnabled: true,
            //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(
              //innital position in map
              target: showLocation != null ? showLocation : LatLng(0.0, 0.0),
              //initial position
              zoom: 6.0, //initial zoom level
            ),
            markers: getmarkers(loc, cusName, id, info),
            //markers to show on map
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,

            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
              });
            },
          )
        : GoogleMap(
            //Map widget from google_maps_flutter package
            zoomGesturesEnabled: true,
            //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(
              //innital position in map
              target: showLocation != null ? showLocation : LatLng(0.0, 0.0),
              //initial position
              zoom: 6.0, //initial zoom level
            ),

            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
              });
            },
          );
  }

  void displayModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: new Wrap(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: BorderedText(
                          strokeWidth: 2.0,
                          strokeColor: Color(0xfffbefa7),
                          child: Text("Sort",
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: normalText5),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/jobs-pagination');
                        /* setState(() {
                              page1=0;
                              isEnabled3=false;
                              isEnabled4=false;
                              isEnabled5 = true;
                              isEnabled6 = false;

                              isEnabled7 = true;
                              isEnabled8 = false;
                              users.clear();
                              loc.clear();
                              cusName.clear();
                              cusInfo.clear();
                              cusId.clear();
                            });
                            Navigator.pop(context);
                            _myProfileData("",1 );*/
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text("Reset Sort",
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: normalTex4),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 5.0,
                  ),
                  new Container(
                      child: Divider(
                    color: Color(0xfffbefa7),
                    thickness: 1,
                  )),
                  SizedBox(
                    height: 10.0,
                  ),
                  new ListTile(
                    trailing: Container(
                      width: 120,
                      child: Row(children: [
                        Expanded(
                          child: ButtonTheme(
                            minWidth: 60.0,
                            height: 30.0,
                            child: RaisedButton(
                              padding: const EdgeInsets.only(
                                  top: 2, bottom: 2, left: 10, right: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25))),
                              color: isEnabled5
                                  ? Color(0xffb5322f)
                                  : Color(0xfffbefa7),
                              onPressed: () async {
                                setState(() {
                                  isEnabled5 = true;
                                  isEnabled6 = false;
                                  users.clear();
                                  loc.clear();
                                  cusName.clear();
                                  cusInfo.clear();
                                  cusId.clear();
                                  _myProfileData("page=$current_page&sort=id",
                                      current_page);
                                });
                              },
                              child: Text(
                                "Asc",
                                style: TextStyle(
                                  color: isEnabled5
                                      ? Color(0xfffbefa7)
                                      : Color(0xffb5322f),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ButtonTheme(
                            minWidth: 60.0,
                            height: 30.0,
                            child: RaisedButton(
                              padding: const EdgeInsets.only(
                                  top: 2, bottom: 2, left: 5, right: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      bottomRight: Radius.circular(25))),
                              color: isEnabled6
                                  ? Color(0xffb5322f)
                                  : Color(0xfffbefa7),
                              onPressed: () async {
                                setState(() {
                                  isEnabled6 = true;
                                  isEnabled5 = false;
                                  users.clear();
                                  loc.clear();
                                  cusName.clear();
                                  cusInfo.clear();
                                  cusId.clear();
                                  _myProfileData("page=$current_page&sort=-id",
                                      current_page);
                                });
                              },
                              child: Text(
                                "Dsc",
                                style: TextStyle(
                                  color: isEnabled6
                                      ? Colors.white
                                      : Color(0xffb5322f),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    title: new Align(
                      alignment: Alignment.topLeft,
                      child: BorderedText(
                        strokeWidth: 1.0,
                        strokeColor: Color(0xfffbefa7),
                        child: Text("Job Id",
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: normalText5),
                      ),
                    ),
                  ),
                  new ListTile(
                    trailing: Container(
                      width: 120,
                      child: Row(children: [
                        Expanded(
                          child: ButtonTheme(
                            minWidth: 60.0,
                            height: 30.0,
                            child: RaisedButton(
                              padding: const EdgeInsets.only(
                                  top: 2, bottom: 2, left: 10, right: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25))),
                              color: isEnabled7
                                  ? Color(0xffb5322f)
                                  : Color(0xfffbefa7),
                              onPressed: () async {
                                setState(() {
                                  isEnabled7 = true;
                                  isEnabled8 = false;
                                  users.clear();
                                  loc.clear();
                                  cusName.clear();
                                  cusInfo.clear();
                                  cusId.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=job_date",
                                      current_page);
                                });
                              },
                              child: Text(
                                "Asc",
                                style: TextStyle(
                                  color: isEnabled7
                                      ? Color(0xfffbefa7)
                                      : Color(0xffb5322f),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ButtonTheme(
                            minWidth: 60.0,
                            height: 30.0,
                            child: RaisedButton(
                              padding: const EdgeInsets.only(
                                  top: 2, bottom: 2, left: 5, right: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      bottomRight: Radius.circular(25))),
                              color: isEnabled8
                                  ? Color(0xffb5322f)
                                  : Color(0xfffbefa7),
                              onPressed: () async {
                                setState(() {
                                  isEnabled8 = true;
                                  isEnabled7 = false;
                                  users.clear();
                                  loc.clear();
                                  cusName.clear();
                                  cusInfo.clear();
                                  cusId.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=-job_date",
                                      current_page);
                                });
                              },
                              child: Text(
                                "Dsc",
                                style: TextStyle(
                                  color: isEnabled8
                                      ? Colors.white
                                      : Color(0xffb5322f),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    title: new Align(
                      alignment: Alignment.topLeft,
                      child: BorderedText(
                        strokeWidth: 1.0,
                        strokeColor: Color(0xfffbefa7),
                        child: Text("Job date",
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: normalText5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  void displayModalBottomSheet2(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        builder: (
          BuildContext context,
        ) {
          return SingleChildScrollView(
            child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Container(
                // height: MediaQuery.of(context).copyWith().size.height * 0.50,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: new Wrap(
                  children: <Widget>[
                    Column(children: <Widget>[
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: BorderedText(
                              strokeWidth: 2.0,
                              strokeColor: Color(0xfffbefa7),
                              child: Text("Filter",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalText5),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/jobs-pagination');
                            /* setState(() {
                                    page1=0;
                                    isEnabled3=false;
                                    isEnabled4=false;

                                    postCodeController.text="";
                                    bNameController.text="";
                                    selectedCity=null;
                                    _type1="";
                                    users.clear();
                                    loc.clear();
                                    cusName.clear();
                                    cusInfo.clear();
                                    cusId.clear();
                                  });
                                  Navigator.pop(context);
                                  _myProfileData("",1 );*/
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Text("Reset Filter",
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: normalTex4),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 5.0,
                      ),
                      new Container(
                          child: Divider(
                        color: Color(0xfffbefa7),
                        thickness: 1,
                      )),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(children: <Widget>[
                        Container(
                          width: 100,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: BorderedText(
                              strokeWidth: 2.0,
                              strokeColor: Color(0xfffbefa7),
                              child: Text("Post Code",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalText5),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            margin: const EdgeInsets.only(right: 8.0, left: 8),
                            child: TextFormField(
                                controller: postCodeController,
                                keyboardType: TextInputType.text,
                                cursorColor: Color(0xff000000),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onSaved: (String value) {
                                  postCodeController.text = value;
                                },
                                onChanged: (String value) {
                                  text1 = true;
                                },
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 30, 30, 0),
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
                                    hintText: 'PostCode...',
                                    hintStyle: TextStyle(
                                        color: Color(0xffcdcbcb), fontSize: 16),
                                    fillColor: Color(0xffffffff),
                                    filled: true)),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(children: <Widget>[
                        Container(
                          width: 100,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: BorderedText(
                              strokeWidth: 2.0,
                              strokeColor: Color(0xfffbefa7),
                              child: Text("Business name",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalText5),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            margin: const EdgeInsets.only(right: 8.0, left: 8),
                            child: TextFormField(
                                controller: bNameController,
                                keyboardType: TextInputType.text,
                                cursorColor: Color(0xff000000),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (String value) {
                                  text2 = true;
                                },
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 30, 30, 0),
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
                                    hintText: 'Business name...',
                                    hintStyle: TextStyle(
                                        color: Color(0xffcdcbcb), fontSize: 16),
                                    fillColor: Color(0xffffffff),
                                    filled: true)),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(children: <Widget>[
                        Container(
                          width: 100,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: BorderedText(
                              strokeWidth: 2.0,
                              strokeColor: Color(0xfffbefa7),
                              child: Text("Zone",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalText5),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                  color: Color(0xffcdcbcb),
                                )),
                            margin: const EdgeInsets.only(right: 8.0, left: 8),
                            child: DropdownButtonHideUnderline(
                              child: Padding(
                                padding: EdgeInsets.only(right: 0, left: 0),
                                child: new DropdownButton<String>(
                                  isExpanded: true,
                                  hint: new Text(
                                    "Select Zone ",
                                    style: TextStyle(
                                        color: Color(0xffcdcbcb), fontSize: 16),
                                  ),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: selectedCity,
                                  isDense: true,
                                  autofocus: true,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      selectedCity = newValue;
                                      List<String> item = _city.map((City map) {
                                        for (int i = 0; i < _city.length; i++) {
                                          if (selectedCity ==
                                              map.FOURTH_LEVEL_NAME) {
                                            _type1 = map.FOURTH_LEVEL_ID;
                                            return map.FOURTH_LEVEL_ID;
                                          }
                                        }
                                      }).toList();

                                      text3 = true;
                                    });
                                  },
                                  items: _city.map((City map) {
                                    return new DropdownMenuItem<String>(
                                      value: map.FOURTH_LEVEL_NAME,
                                      child: new Text(map.FOURTH_LEVEL_NAME,
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
                      SizedBox(
                        height: 20.0,
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
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                )
                              ],
                            ),
                            child: RaisedButton(
                              splashColor: Color(0xfffbefa7),
                              padding: const EdgeInsets.only(
                                  top: 2, bottom: 2, left: 10, right: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                              textColor: Color(0xffb5322f),
                              color: Color(0xfffbefa7),
                              onPressed: () {
                                users.clear();
                                loc.clear();
                                cusName.clear();
                                cusInfo.clear();
                                cusId.clear();
                                markers.clear();
                                Navigator.pop(context);
                                if (text1) {
                                  _myProfileData(
                                      "page=$current_page&postcode=${postCodeController.text}",
                                      current_page);

                                  if (text2) {
                                    _myProfileData(
                                        "page=$current_page&postcode=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                        current_page);
                                    if (text3) {
                                      _myProfileData(
                                          "page=$current_page&postcode=${postCodeController.text}&customer_businessname=${bNameController.text}&zone_id=${_type1}",
                                          current_page);
                                    }
                                  }
                                } else if (text2) {
                                  _myProfileData(
                                      "page=$current_page&customer_businessname=${bNameController.text}",
                                      current_page);

                                  if (text1) {
                                    _myProfileData(
                                        "page=$current_page&postcode=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                        current_page);

                                    if (text3) {
                                      _myProfileData(
                                          "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}&zone_id=${_type1}",
                                          current_page);
                                    }
                                  }
                                } else if (text3) {
                                  _myProfileData(
                                      "page=$current_page&zone_id=${_type1}",
                                      current_page);

                                  if (text2) {
                                    _myProfileData(
                                        "page=$current_page&zone_id=${_type1}&customer_businessname=${bNameController.text}",
                                        current_page);

                                    if (text1) {
                                      _myProfileData(
                                          "page=$current_page&zone_id=${_type1}&postcode=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                          current_page);
                                    }
                                  } else if (text1) {
                                    _myProfileData(
                                        "page=$current_page&customer_businessname=${bNameController.text}&postcode=${postCodeController.text}",
                                        current_page);

                                    if (text1) {
                                      _myProfileData(
                                          "page=$current_page&postcode=${postCodeController.text}&zone_id=${_type1}&customer_businessname=${bNameController.text}",
                                          current_page);
                                    }
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please enter any value",
                                      toastLength: Toast.LENGTH_LONG);
                                }
                              },
                              child: Text(
                                "Filter",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Set<Marker> getmarkers(List loc, List cusName, List id, List info) {
    Marker resultMarker;
    var firstDay =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday));

    var lastday = DateTime.now()
        .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday));

    for (int i = 0; i < loc.length; i++) {
      bool match = false;
      bool forred = false;

      if (DateTime.parse(DateTime.now().toString().split(" ")[0]).isAfter(
          DateTime.parse(DateTime.parse(
                  loc[i]['date'].toString().split('-').reversed.join())
              .toString()
              .split(" ")[0]))) {
        forred = true;
      }
      if (firstDay.isBefore(DateTime.parse(loc[i]['date'].toString().split('-').reversed.join())) &&
              lastday.isAfter(DateTime.parse(
                  loc[i]['date'].toString().split('-').reversed.join())) &&
              DateTime.parse(DateTime.now().toString().split(" ")[0]).isBefore(
                  DateTime.parse(
                      DateTime.parse(loc[i]['date'].toString().split('-').reversed.join())
                          .toString()
                          .split(" ")[0])) ||
          DateTime.parse(DateTime.now().toString().split(" ")[0])
              .isAtSameMomentAs(DateTime.parse(
                  DateTime.parse(loc[i]['date'].toString().split('-').reversed.join())
                      .toString()
                      .split(" ")[0]))) {
        match = true;
      }

      setState(() {
        resultMarker = Marker(
            //add first marker
            markerId: MarkerId(id[i].toString()),
            position: loc[i]['location'],
            //position of marker
            draggable: true,
            infoWindow: InfoWindow(
              //popup info
              title: cusName[i],
              snippet: info[i],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/job-details',
                  arguments: <String, String>{
                    'job_id': id[i].toString(),
                  },
                );
              },
            ),
            icon: forred
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : match
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen)
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow) //Icon for Marker
            );

        markers.add(resultMarker);
      });
    }

    return markers;
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _loading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  showConfirmDialog(id, cancel, done, title, content) {
    Widget cancelButton = FlatButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text(done),
      onPressed: () {
        Navigator.of(context).pop();
        removeItemFromCart(id);
      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        doneButton,
      ],
    );

    // Show the Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void removeItemFromCart(Id) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };

    var uri = Uri.parse(URL + '/job/delete/' + Id);

    var response = await http.delete(
      uri,
      headers: headers,
    );
    if (response.statusCode == 204) {
      Navigator.pushNamed(context, '/jobs-pagination');
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

  TextStyle normalText2 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));
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
      //  top: 50.0,
      right: 20.0,
      left: 50.0,
      // maxHeight: 200,
      minHeight: 200,
      minWidth: 200,
      arrowLength: 0,
      showCloseButton: ShowCloseButton.inside,
      hasShadow: false,
      content: new Material(
          child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          response,
          style: normalText2,
        ),
      )),
    );

    tooltip.show(context);
  }

  Widget quizList() {
    if (users.length != 0) {
      var firstDay =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday));

      var lastday = DateTime.now()
          .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday));

      return ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: users.length + 1,
          itemBuilder: (context, index) {
            bool match = false;
            bool forred = false;
            if (index != users.length) {
              if (DateTime.parse(DateTime.now().toString().split(" ")[0])
                  .isAfter(DateTime.parse(DateTime.parse(users[index]
                              ['job_date']
                          .toString()
                          .split('-')
                          .reversed
                          .join())
                      .toString()
                      .split(" ")[0]))) {
                forred = true;
              }
              if (firstDay.isBefore(DateTime.parse(users[index]['job_date'].toString().split('-').reversed.join())) &&
                      lastday.isAfter(DateTime.parse(users[index]['job_date']
                          .toString()
                          .split('-')
                          .reversed
                          .join())) &&
                      DateTime.parse(DateTime.now().toString().split(" ")[0])
                          .isBefore(DateTime.parse(
                              DateTime.parse(users[index]['job_date'].toString().split('-').reversed.join())
                                  .toString()
                                  .split(" ")[0])) ||
                  DateTime.parse(DateTime.now().toString().split(" ")[0])
                      .isAtSameMomentAs(DateTime.parse(DateTime.parse(
                              users[index]['job_date'].toString().split('-').reversed.join())
                          .toString()
                          .split(" ")[0]))) {
                match = true;
              }
            }

            if (index == users.length) {
              return _buildProgressIndicator();
            } else {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/job-details',
                    arguments: <String, String>{
                      'job_id': users[index]['id'].toString(),
                    },
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 8, right: 5, top: 7, bottom: 7),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFe3e3e3)),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /* InkWell(
                            onTap: () {
                              onTap(users[index]['job_remarks']);
                            },
                            child: Row(children: [
                              Container(
                                padding: EdgeInsets.only(right: 6),
                                child: Text("Remarks", style: normalText6),
                              ),
                             Image(
                                  image: AssetImage("assets/images/tool.png"),
                                  height: 15.0,
                                  width: 15.0,
                                ),

                            ]),
                          ),*/

                          Container(
                            child: forred
                                ? Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                  )
                                : match
                                    ? Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.circle,
                                        color: Colors.amber,
                                      ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => SendMessage(
                                                messageFor: users[index]
                                                            ['customer'][
                                                        'customer_businessname']
                                                    .toString(),
                                                jobId: users[index]['id']
                                                    .toString(),
                                              ))));
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.yellow[300],
                                  child: Icon(Icons.message,
                                      color: Color(0xffb5322f)),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    showConfirmDialog(
                                        users[index]['id'].toString(),
                                        'Cancel',
                                        'Remove',
                                        'Remove Job',
                                        'Are you sure want to remove this job?');
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.yellow[300],
                                    child: Icon(
                                      Icons.delete,
                                      color: Color(0xffb5322f),
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.55,
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
                                      users[index]['customer']
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
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            child: Row(children: [
                              Image(
                                image: AssetImage("assets/images/litre.png"),
                                height: 17.0,
                                width: 17.0,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Expanded(
                                child: Text(users[index]['job_qty'] + " Litres",
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                    Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.55,
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
                                  users[index]['customer']
                                          ['customer_address1'] +
                                      ", " +
                                      users[index]['customer']
                                          ['customer_address2'] +
                                      ", " +
                                      users[index]['customer']['postcode'],
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTex2),
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
                                image: AssetImage("assets/images/package.png"),
                                height: 17.0,
                                width: 17.0,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Expanded(
                                child: Text(
                                    users[index]['customer']
                                        ['customer_accountnumber'],
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: normalTex2),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.55,
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
                              child: Text(users[index]['job_date'],
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTex2),
                            ),
                          ]),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: InkWell(
                            onTap: () {
                              _launchCaller(users[index]['customer']
                                  ['customer_primaryphone']);
                            },
                            child: Container(
                              child: Row(children: [
                                Image(
                                  image: AssetImage("assets/images/call.png"),
                                  height: 17.0,
                                  width: 17.0,
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Expanded(
                                  child: Text(
                                      users[index]['customer']
                                          ['customer_primaryphone'],
                                      softWrap: true,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: normalTex4),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Text("Remarks:", style: normalText12),
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Expanded(
                                  child: Text(users[index]['job_remarks'],
                                      softWrap: true,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: normalText12),
                                ),
                              ]),
                        ),
                      ),
                    ]),
                  ]),
                ),
              );
            }
          });
    } else {
      _emptyOrders();
    }
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

  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                buildUserInfo(context),
                buildDrawerItem(),
              ],
            ),
          ),
          appBar: AppBar(
            leading: InkWell(
              child: IconButton(
                icon: Image(
                  image: AssetImage("assets/images/menu.png"),
                  height: 30.0,
                  width: 30.0,
                ),
                onPressed: () => _scaffoldKey.currentState.openDrawer(),
              ),
            ),
            centerTitle: true,
            title: Container(
              child: Row(children: <Widget>[
                Center(
                  child: BorderedText(
                    strokeWidth: 2.0,
                    strokeColor: Color(0xfffbefa7),
                    child: Text('Your Jobs', style: normalText),
                  ),
                ),
              ]),
            ),
            flexibleSpace: Container(
              height: 100,
              color: Color(0xfffbefa7),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/inbox-message');
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Badge(
                    badgeContent: Text(notificationLis.length.toString()),
                    badgeColor: Colors.white,
                    child: Icon(Icons.notifications, color: Color(0xffb5322f)),
                  ),
                ),
              ),
              // PopupMenuButton(
              //     itemBuilder: (context) => notificationLis
              //         .map((e) => PopupMenuItem(child: Text("data")))
              //         .toList()),
              IconButton(
                icon: Image(
                  image: AssetImage("assets/images/refresh.png"),
                  color: Color(0xffb5322f),
                  height: 24.0,
                  width: 24.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/jobs-pagination');
                },
              ),
            ],
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Colors.transparent,
          ),
          body: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: Container(
              child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: deviceSize.width * 0.04,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: Row(children: [
                                    Expanded(
                                      child: ButtonTheme(
                                        //  minWidth: 50.0,
                                        height: 35.0,
                                        child: RaisedButton(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 10,
                                              right: 10),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomLeft:
                                                      Radius.circular(25))),
                                          color: isEnabled1
                                              ? Color(0xffb5322f)
                                              : Colors.white,
                                          onPressed: () async {
                                            setState(() {
                                              isEnabled1 = true;
                                              isEnabled2 = false;
                                            });
                                          },
                                          child: Text(
                                            "List View",
                                            style: TextStyle(
                                              color: isEnabled1
                                                  ? Colors.white
                                                  : Color(0xffb5322f),
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ButtonTheme(
                                        // minWidth: 50.0,
                                        height: 35.0,
                                        child: RaisedButton(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 10,
                                              right: 10),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(25))),
                                          color: isEnabled2
                                              ? Color(0xffb5322f)
                                              : Colors.white,
                                          onPressed: () async {
                                            setState(() {
                                              isEnabled2 = true;
                                              isEnabled1 = false;
                                            });
                                          },
                                          child: Text(
                                            "Map View",
                                            style: TextStyle(
                                              color: isEnabled2
                                                  ? Colors.white
                                                  : Color(0xffb5322f),
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                  child: Row(children: [
                                    Expanded(
                                      child: ButtonTheme(
                                        //  minWidth: 50.0,
                                        height: 35.0,
                                        child: RaisedButton(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 10,
                                              right: 10),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomLeft:
                                                      Radius.circular(25))),
                                          color: isEnabled3
                                              ? Color(0xffb5322f)
                                              : Colors.white,
                                          onPressed: () async {
                                            setState(() {
                                              isEnabled3 = true;
                                              isEnabled4 = false;
                                              displayModalBottomSheet(context);
                                            });
                                          },
                                          child: Row(children: [
                                            Image(
                                              image: AssetImage(
                                                  "assets/images/shortby.png"),
                                              height: 17.0,
                                              width: 17.0,
                                              color: isEnabled3
                                                  ? Colors.white
                                                  : Color(0xffb5322f),
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "Sort",
                                              style: TextStyle(
                                                color: isEnabled3
                                                    ? Colors.white
                                                    : Color(0xffb5322f),
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ButtonTheme(
                                        // minWidth: 50.0,
                                        height: 35.0,
                                        child: RaisedButton(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              left: 10,
                                              right: 10),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(25))),
                                          color: isEnabled4
                                              ? Color(0xffb5322f)
                                              : Colors.white,
                                          onPressed: () async {
                                            setState(() {
                                              isEnabled4 = true;
                                              isEnabled3 = false;
                                            });

                                            displayModalBottomSheet2(context);
                                          },
                                          child: Row(children: [
                                            Text(
                                              "Filter",
                                              style: TextStyle(
                                                color: isEnabled4
                                                    ? Colors.white
                                                    : Color(0xffb5322f),
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Image(
                                              image: AssetImage(
                                                  "assets/images/filter.png"),
                                              height: 17.0,
                                              width: 17.0,
                                              color: isEnabled4
                                                  ? Colors.white
                                                  : Color(0xffb5322f),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ]),
                        ),
                      ),
                      new Container(
                          child: Divider(
                        color: Color(0xfffbefa7),
                        thickness: 1,
                      )),
                      SizedBox(
                        height: 6.0,
                      ),
                      /*  Align(
                            alignment: Alignment.topRight,
                            child:  Text(
                                "Displaying- "+pageCount.toString()+" of "+totalCount.toString(),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:normalTex2
                            ),

                          ),*/
                      SizedBox(
                        height: 6.0,
                      ),
                      Expanded(
                          child: Container(
                              child: isEnabled1
                                  ? ListView(
                                      shrinkWrap: true,
                                      controller: _sc,
                                      children: <Widget>[
                                          Center(
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 5),
                                              child: quizList(),
                                            ),
                                          ),
                                        ])
                                  : mapView(loc, cusName, cusId, cusInfo))),
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
                                    top: 2, bottom: 2, left: 10, right: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                textColor: Color(0xfffbefa7),
                                color: Color(0xffb5322f),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/customer-pagination');
                                },
                                child: Text(
                                  "Add Job",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800),
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
                                    blurRadius: 1.0, // soften the shadow
                                    spreadRadius: 1.0, //extend the shadow
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
                                    top: 2, bottom: 2, left: 5, right: 5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                textColor: Color(0xffb5322f),
                                color: Color(0xfffbefa7),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/collection-list');
                                },
                                child: Text(
                                  "Show Collections",
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
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
          )),
    );
  }
}

class City {
  final String FOURTH_LEVEL_ID;
  final String FOURTH_LEVEL_NAME;

  City({this.FOURTH_LEVEL_ID, this.FOURTH_LEVEL_NAME});

  factory City.fromJson(Map<String, dynamic> json) {
    return new City(
        FOURTH_LEVEL_ID: json['zone_id'].toString(),
        FOURTH_LEVEL_NAME: json['zone']['zone_name']);
  }
}
