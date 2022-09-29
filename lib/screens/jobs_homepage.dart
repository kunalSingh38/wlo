import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
import 'package:wlo_master/main.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class JobsScreen extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<JobsScreen> {
  Future<dynamic> _checkList;
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
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
  final Set<Marker> markers = new Set(); //markers for google map
  LatLng showLocation; //location to show in map

  String name = "";

  bool text1 = false;
  bool text2 = false;
  bool text3 = false;
  final postCodeController = TextEditingController();
  final bNameController = TextEditingController();
  int page1 = 1;
  int page = 1;
  ScrollController _sc = new ScrollController();

  List<City> _city = [];
  String catData = "";
  String cityData = "";
  String selectedCity;
  var _type1 = "";
  @override
  void initState() {
    super.initState();
    _getUser();
    print("this page");
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        name = prefs.getString('driverName').toString();
        _checkList = _checkListData("");
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

  Future _getZoneAccount() async {
    setState(() {
      _loading = true;
    });
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/driver-zones"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
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
      setState(() {
        _loading = false;
      });
      throw Exception('Something went wrong');
    }
  }

  void _profileData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/profile');
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

  Future _checkListData(String type) async {
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
    var uri;
    if (isEnabled3 == true) {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/jobs')
          .replace(query: type);
    } else if (isEnabled4 == true) {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/jobs')
          .replace(query: type);
    } else if (type == "") {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/jobs');
    } else {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/jobs')
          .replace(query: type);
    }

    var response = await http.get(
      uri,
      headers: headers,
    );
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      if (data['data'].length != 0) {
        view = false;
        totalCount = data['__meta']['totalCount'];
        pageCount = data['data'].length;
        showLocation = LatLng(
            double.parse(data['data'][0]['customer']['customer_lat']),
            double.parse(data['data'][0]['customer']['customer_lng']));
        for (int i = 0; i < data['data'].length; i++) {
          if (data['data'][i]['customer']['customer_lat'] != null) {
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
      } else {
        setState(() {
          view = true;
        });
      }
      _profileData();
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
      _checkList = _checkListData("");
    });
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
              new ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Color(0xffb5322f),
                  ),
                ),
              ),
              new ElevatedButton(
                onPressed: () async {
                  final service = FlutterBackgroundService();
                  var isRunning = await service.isRunning();

                  if (isRunning) {
                    submitData();
                    service.invoke("stopService");
                    Fluttertoast.showToast(msg: "Service stopped");
                  }
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
                backgroundImage: AssetImage("assets/images/avatar.png"),
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
                        Navigator.pushNamed(context, '/jobs-homepage');
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
                      leading: Image(
                        image: AssetImage(item.icon),
                        height: 20.0,
                      ),
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
              new ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Color(0xffb5322f),
                  ),
                ),
              ),
              new ElevatedButton(
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
            zoomGesturesEnabled: true, //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(
              //innital position in map
              target: showLocation != null
                  ? showLocation
                  : LatLng(0.0, 0.0), //initial position
              zoom: 6.0, //initial zoom level
            ),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers:
                getmarkers(loc, cusName, id, info), //markers to show on map
            mapType: MapType.normal,
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
              });
            },
          )
        : GoogleMap(
            //Map widget from google_maps_flutter package
            zoomGesturesEnabled: true, //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(
              //innital position in map
              target: showLocation != null
                  ? showLocation
                  : LatLng(0.0, 0.0), //initial position
              zoom: 6.0, //initial zoom level
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
              });
            },
          );
  }

  void displayModalBottomSheet(context) {
    var first1 = 0;
    bool first2 = false;
    bool first3 = false;
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
                        setState(() {
                          isEnabled3 = false;
                          isEnabled4 = false;
                          isEnabled5 = true;
                          isEnabled6 = false;

                          isEnabled7 = true;
                          isEnabled8 = false;
                        });
                        Navigator.pop(context);
                        _checkList = _checkListData("");
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
                                  _checkList = _checkListData("sort=id");
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
                                  _checkList = _checkListData("sort=-id");
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
                    /*ToggleSwitch(
                        minHeight: 30,
                        minWidth: 60.0,
                        cornerRadius: 20.0,
                        activeBgColor: Color(0xffb5322f),
                        activeFgColor: Colors.white,
                        inactiveBgColor: Color(0xfffbefa7),
                        inactiveFgColor: Colors.black,
                        //initialLabelIndex: first1,
                        labels: ['Asc', 'Dsc'],
                        onToggle: (index) {
                          print('switched to: $index');
                          setModalState(() {
                            if (index == 1) {
                              */ /* setState(() {
                              first1=index;
                            });*/ /*
                              //Navigator.pop(context);
                              _checkList = _checkListData("sort=-id");
                              print(index);
                            } else if (index == 0) {
                              //  Navigator.pop(context);
                              _checkList = _checkListData("sort=id");
                              print(index);
                            }
                          });

                        },
                      )*/

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
                                  _checkList = _checkListData("sort=job_date");
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
                                  _checkList = _checkListData("sort=-job_date");
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
                    ) /*ToggleSwitch(
                      minHeight: 30,
                      minWidth: 60.0,
                      cornerRadius: 20.0,
                      activeBgColor: Color(0xffb5322f),
                      activeFgColor: Colors.white,
                      inactiveBgColor: Color(0xfffbefa7),
                      inactiveFgColor: Colors.black,
                      labels: ['Asc', 'Dsc'],
                      onToggle: (index) {
                        print('switched to: $index');
                        setModalState(() {
                          if (index == 1) {
                            //  Navigator.of(context).pop();
                            _checkList = _checkListData("sort=-job_date");
                          } else if (index == 0) {
                            // Navigator.of(context).pop();
                            _checkList = _checkListData("sort=job_date");
                          }
                        });

                      },
                    )*/
                    ,
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
    var first1 = 0;
    bool first2 = false;
    bool first3 = false;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return Container(
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
                          setState(() {
                            isEnabled3 = false;
                            isEnabled4 = false;
                            /* isEnabled5=false;
                                isEnabled6=false;*/
                            /* isEnabled7=true;
                                isEnabled8=false;*/
                            postCodeController.text = "";
                            bNameController.text = "";
                            selectedCity = null;
                            _type1 = "";
                          });
                          Navigator.pop(context);
                          _checkList = _checkListData("");
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
                            /* boxShadow: [
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
                            ],*/
                          ),
                          margin: const EdgeInsets.only(right: 8.0, left: 8),
                          child: TextFormField(
                              controller: postCodeController,
                              keyboardType: TextInputType.text,
                              cursorColor: Color(0xff000000),
                              textCapitalization: TextCapitalization.sentences,
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
                              textCapitalization: TextCapitalization.sentences,
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
                                    setState(() {
                                      text3 = true;
                                    });
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
                              Navigator.pop(context);
                              if (text1) {
                                _checkList = _checkListData(
                                    "postcode=${postCodeController.text}");

                                if (text2) {
                                  _checkList = _checkListData(
                                      "postcode=${postCodeController.text}&customer_businessname=${bNameController.text}");
                                  if (text3) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_businessname=${bNameController.text}&zone_id=${_type1}");
                                  }
                                }
                              } else if (text2) {
                                _checkList = _checkListData(
                                    "customer_businessname=${bNameController.text}");

                                if (text1) {
                                  _checkList = _checkListData(
                                      "postcode=${postCodeController.text}&customer_businessname=${bNameController.text}");
                                  if (text3) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${postCodeController.text}&zone_id=${_type1}");
                                  }
                                }
                              } else if (text3) {
                                _checkList =
                                    _checkListData("zone_id=${_type1}");

                                if (text2) {
                                  _checkList = _checkListData(
                                      "zone_id=${_type1}&customer_businessname=${bNameController.text}");
                                  if (text1) {
                                    _checkList = _checkListData(
                                        "zone_id=${_type1}"
                                        "&postcode=${postCodeController.text}&customer_businessname=${bNameController.text}");
                                  }
                                } else if (text1) {
                                  _checkList = _checkListData(
                                      "customer_businessname=${bNameController.text}&postcode=${postCodeController.text}");
                                  if (text1) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&zone_id=${_type1}&customer_businessname=${bNameController.text}");
                                  }
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please enter any value",
                                    toastLength: Toast.LENGTH_LONG);
                              }
                              /* } else {
                                  Fluttertoast.showToast(
                                      msg: "Please enter any value",
                                      toastLength: Toast.LENGTH_LONG);
                                }*/
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
            );
          });
        });
  }

  Set<Marker> getmarkers(List loc, List cusName, List id, List info) {
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
        markers.add(Marker(
            //add first marker
            markerId: MarkerId(id[i].toString()),
            position: loc[i]['location'], //position of marker
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
                        BitmapDescriptor.hueYellow) //Ic
            //Icon for Marker
            ));
      });
    }

    return markers;
  }

  Widget quizList() {
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: Container());
        } else {
          if (snapshot.hasError) {
            _loading = false;
            return Column(children: <Widget>[
              Text(snapshot.error.toString()),
              SizedBox(
                height: 10.0,
              ),
              ButtonTheme(
                minWidth: 50,
                height: 30.0,
                child: Container(
                  child: RaisedButton(
                    splashColor: Color(0xffb5322f),
                    padding: const EdgeInsets.only(
                        top: 2, bottom: 2, left: 20, right: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    textColor: Color(0xfffbefa7),
                    color: Color(0xffb5322f),
                    onPressed: () {
                      _checkList = _checkListData("");
                    },
                    child: Text(
                      "Reload",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              )
            ]);
          } else {
            if (snapshot.hasData) {
              var errorCode = snapshot.data['status'];
              var response = snapshot.data['data'];
              if (errorCode == 200) {
                if (response.length != 0) {
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      controller: _sc,
                      itemCount: response.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/job-details',
                              arguments: <String, String>{
                                'job_id': response[index]['id'].toString(),
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 8, right: 5, top: 7, bottom: 7),
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xFFe3e3e3)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
                            child: Column(children: <Widget>[
                              Row(mainAxisSize: MainAxisSize.max, children: <
                                  Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.55,
                                    child: Row(children: [
                                      Image(
                                        image: AssetImage(
                                            "assets/images/user.png"),
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
                                                response[index]['customer']
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
                                          image: AssetImage(
                                              "assets/images/litre.png"),
                                          height: 17.0,
                                          width: 17.0,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                              response[index]['job_qty'] +
                                                  " Litres",
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
                              Row(mainAxisSize: MainAxisSize.max, children: <
                                  Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.55,
                                    child: Row(children: [
                                      Image(
                                        image: AssetImage(
                                            "assets/images/location.png"),
                                        height: 17.0,
                                        width: 17.0,
                                      ),
                                      SizedBox(
                                        width: 6.0,
                                      ),
                                      Expanded(
                                        child: Text(
                                            response[index]['customer']
                                                    ['customer_address1'] +
                                                ", " +
                                                response[index]['customer']
                                                    ['customer_address2'],
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
                                    child: Container(
                                      child: Row(children: [
                                        Image(
                                          image: AssetImage(
                                              "assets/images/package.png"),
                                          height: 17.0,
                                          width: 17.0,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                              response[index]['customer']
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
                              Row(mainAxisSize: MainAxisSize.max, children: <
                                  Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
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
                                        child: Text(response[index]['job_date'],
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
                                        _launchCaller(response[index]
                                                ['customer']
                                            ['customer_primaryphone']);
                                      },
                                      child: Container(
                                        child: Row(children: [
                                          Image(
                                            image: AssetImage(
                                                "assets/images/call.png"),
                                            height: 17.0,
                                            width: 17.0,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                                response[index]['customer']
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
                            ]),
                          ),
                        );
                      });
                } else {
                  return _emptyOrders();
                }
              } else {
                return _emptyOrders();
              }
            } else {
              return Text("No Data");
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
              /* IconButton(
                icon: Image(
                  image: AssetImage("assets/images/notifications.png"),
                  height: 30.0,
                  width: 30.0,
                ),
                onPressed: () async {

                },
              ),*/
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
                                  width: 40.0,
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
                                              displayModalBottomSheet2(context);
                                              _getZoneAccount();
                                            });
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
                      SizedBox(
                        height: 6.0,
                      ),
                      Expanded(
                          child: Container(
                              child: isEnabled1
                                  ? quizList()
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
                                      context, '/collection-list');
                                },
                                child: Text(
                                  "Show Collection",
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
