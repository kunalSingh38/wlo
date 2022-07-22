import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlo_master/constants.dart';

import 'checklist_screen.dart';
import 'job_pagination.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loggedIn = false;
  bool _next = false;
  bool firstShow = false;
  final splashDelay = 3;
  String formattedDate1 = "";
  String lastVisitDate = "";
  @override
  void initState() {
    super.initState();
    getDeviceId().then((di) {
      print(di.toString());
      _checkDevice(di).then((value) {
        if (value == 200) {
          Fluttertoast.showToast(
              msg: "Device Registered.",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT);
          _checkLoggedIn();
        } else {
          showPhotoCaptureOptions(di);
        }
      });
    });

    // checkIsTodayVisit();
  }

  Future<int> _checkDevice(String deviceId) async {
    print(URL + '/access-code/$deviceId');
    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    var uri = Uri.parse(URL + '/access-code/$deviceId');
    var response = await http.get(
      uri,
      headers: headers,
    );

    print("test" + response.body);
    return response.statusCode;
  }

  String os = "";
  String model = "";
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      var device_Id = await deviceInfoPlugin.androidInfo;
      setState(() {
        os = "android";
        model = device_Id.model.toString();
      });
      return device_Id.androidId.toString();
    } else {
      var device_Id = await deviceInfoPlugin.iosInfo;
      setState(() {
        os = "ios";
        model = device_Id.model.toString();
      });
      return device_Id.identifierForVendor.toString();
    }
  }

  _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _isLoggedIn = prefs.getBool('logged_in');
    if (_isLoggedIn == true) {
      setState(() {
        _loggedIn = _isLoggedIn;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
    checkIsTodayVisit();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 30, fontWeight: FontWeight.w300, color: Colors.black);
  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                _next == true ? homeOrLog() : homeOrLog1()));
  }

  checkIsTodayVisit() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    SharedPreferences prefs = await _prefs;
    lastVisitDate = prefs.get("mDateKey");
    if (prefs.getBool("firstShow") != null) {
      firstShow = prefs.getBool("firstShow");
    }

    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MMM-yyyy');
    String toDayDate = formatter.format(now);

    if (toDayDate == lastVisitDate) {
      print(lastVisitDate);
      setState(() {
        _next = true;
      });
    } else {
      print(lastVisitDate);
      if (lastVisitDate == null) {
        if (firstShow) {
          setState(() {
            _next = true;
          });
        } else {
          setState(() {
            _next = false;
          });
        }
      } else {
        setState(() {
          _next = false;
        });
      }

      /* if(firstShow) {
        prefs.setString("mDateKey", toDayDate);
      }
      else{
        prefs.setString("mDateKey", "");
      }*/
    }
    _loadWidget();
  }

  Widget homeOrLog() {
    if (this._loggedIn) {
      var obj = 0;
      return JobsScreen11();
    } else {
      return LoginScreen();
    }
  }

  Widget homeOrLog1() {
    if (this._loggedIn) {
      var obj = 0;
      return VehicleChecklists();
    } else {
      return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/login.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Image.asset("assets/images/app_icon.png"),
                    ),
                    Text(
                      "SmartCollect",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: MaterialButton(
                      onPressed: () => {},
                      child: Text("Loading...", style: normalText),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  TextEditingController accessCode = TextEditingController();
  GlobalKey<FormState> key = GlobalKey<FormState>();
  Future<void> showPhotoCaptureOptions(String deviceId) async {
    setState(() {
      accessCode.text = "";
    });
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: key,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
                      child: Text(
                        'YOUR DEVICE IS NOT REGISTERED WITH US.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
                      child: Text(
                        'Enter you access code',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: accessCode,
                      // autofocus: true,
                      validator: (value) {
                        if (value.isEmpty)
                          return "Required Field";
                        else
                          return null;
                      },
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: "Enter Access Code",
                          counterText: ""),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 12,
                            right: 12),
                        child: SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green[600]),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ))),
                                onPressed: () async {
                                  if (key.currentState.validate()) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text("Loading"),
                                              content: SizedBox(
                                                height: 30,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                            ));
                                    print(jsonEncode({
                                      "device_id": deviceId.toString(),
                                      "access_code": accessCode.text.toString(),
                                      "os": os,
                                      "model": model
                                    }));
                                    Map<String, String> headers = {
                                      'Accept': 'application/json',
                                    };
                                    var uri =
                                        Uri.parse(URL + '/access-code/create');
                                    var response = await http
                                        .post(uri, headers: headers, body: {
                                      "device_id": deviceId.toString(),
                                      "access_code": accessCode.text.toString(),
                                      "os": os,
                                      "model": model
                                    });
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    print(response.body);
                                    print(response.statusCode);
                                    if (response.statusCode == 201) {
                                      Fluttertoast.showToast(
                                          msg: "Device ID Registered.",
                                          gravity: ToastGravity.CENTER,
                                          toastLength: Toast.LENGTH_LONG);
                                      _checkLoggedIn();
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text(
                                                    "Incorrect Access Code"),
                                                content: Text(
                                                    "Access code is wrong. Please try again"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        getDeviceId()
                                                            .then((di) {
                                                          print(di.toString());
                                                          _checkDevice(di)
                                                              .then((value) {
                                                            if (value == 200) {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "Device Registered.",
                                                                  gravity:
                                                                      ToastGravity
                                                                          .BOTTOM,
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT);
                                                              _checkLoggedIn();
                                                            } else {
                                                              showPhotoCaptureOptions(
                                                                  di);
                                                            }
                                                          });
                                                        });
                                                      },
                                                      child: Text(
                                                        "Try Again",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ))
                                                ],
                                              ));

                                      // Fluttertoast.showToast(
                                      //     msg:
                                      //         "Access code is wrong. Please try again",
                                      //     gravity: ToastGravity.CENTER,
                                      //     toastLength: Toast.LENGTH_LONG);
                                    }
                                  }
                                })))
                  ]),
            )));
  }
}
