import 'dart:async';
import 'dart:convert';
import 'package:bordered_text/bordered_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wlo_master/components/general.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<LoginScreen> {
  final empCodeController = TextEditingController();
  final pinController = TextEditingController();
  List<Region> _region = [];
  Future _vehicleData;
  String catData = "";
  String selectedRegion;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  String fcmToken = "";
  var _type = "";
  bool _autoValidate = false;
  bool _isHidden = true;
  @override
  void initState() {
    super.initState();
    _vehicleData = _getVehicleCategories();
    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        fcmToken = value.toString();
        print(fcmToken);
      });
    });
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 38, fontWeight: FontWeight.w500, color: Colors.black);

  Future _getVehicleCategories() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    var response = await http.get(
      Uri.parse(URL + "/vehicles"),
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
          }
        });
      }

      print("<<<<<<<<<<<<<<<" + _type);

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future<bool> onWillPop() {
    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget _loginContent() {
    return Container(
      margin: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: empCodeController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter emp code';
                  }
                  return null;
                },
                onSaved: (String value) {
                  empCodeController.text = value;
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
                    hintText: 'Enter Employee Code',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 25.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: pinController,
                obscureText: _isHidden,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                onSaved: (String value) {
                  pinController.text = value;
                },
                decoration: InputDecoration(
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          _isHidden = !_isHidden;
                        });
                      },
                      child: Icon(
                          _isHidden ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xffb5322f)),
                    ),
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
                    hintText: 'Enter Password',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 25.0),
          Container(
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
                    "Vehicle Registration No.",
                    style: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                  value: selectedRegion,
                  isDense: true,
                  autofocus: true,
                  onChanged: (String newValue) {
                    setState(() {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      selectedRegion = newValue;
                      List<String> item = _region.map((Region map) {
                        for (int i = 0; i < _region.length; i++) {
                          if (selectedRegion == map.THIRD_LEVEL_NAME) {
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
                      child: new Text(map.THIRD_LEVEL_NAME,
                          style: new TextStyle(
                              color: Color(0xff000000), fontSize: 16)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          Center(
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              height: 50.0,
              child: Container(
                child: RaisedButton(
                  splashColor: Color(0xfffbefa7),
                  padding: const EdgeInsets.only(
                      top: 2, bottom: 2, left: 10, right: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  textColor: Color(0xffb5322f),
                  color: Color(0xfffbefa7),
                  onPressed: () async {
                    if (_type != "") {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        setState(() {
                          _loading = true;
                        });
                        /* final msg = jsonEncode({
                        "empcode" : empCodeController.text,
                        "password" : pinController.text,
                      });*/
                        Map<String, String> headers = {
                          'Accept': 'application/json',
                        };
                        var response = await http.post(
                          Uri.parse(URL + "/login"),
                          body: {
                            "empcode": empCodeController.text,
                            "password": pinController.text,
                            "fcm_token": fcmToken.toString()
                          },
                          headers: headers,
                        );
                        print(URL + "/login");
                        print({
                          "empcode": empCodeController.text,
                          "password": pinController.text,
                          "fcm_token": fcmToken.toString()
                        });
                        var data = json.decode(response.body);
                        print(data);
                        if (response.statusCode == 201) {
                          setState(() {
                            _loading = false;
                          });

                          var errorCode = data['status'];

                          if (errorCode == 201) {
                            setState(() {
                              _loading = false;
                            });
                            var errorMessage = data['message'];

                            /* Fluttertoast.showToast(
                                msg: errorMessage, toastLength: Toast
                                .LENGTH_SHORT);*/
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('logged_in', true);
                            print(data['access_token'].toString());

                            prefs.setString(
                                'access_token', data['access_token']);
                            prefs.setString(
                                'profile_pic', data['profile_pic'] ?? '');
                            prefs.setString('vehicle_no', _type.toString());

                            Map<String, String> headers = {
                              'Accept': 'application/json',
                              'Authorization': 'Bearer ' + data['access_token'],
                            };
                            var uri = Uri.parse(
                                    URL + '/checklist/is-checklist-display')
                                .replace(query: "vehicle_id=$_type");
                            var response = await http.get(
                              uri,
                              headers: headers,
                            );
                            // print(response.body.toString() + " testttt");
                            var data1 = json.decode(response.body);
                            // print(data1['isDisplay']);
                            if (data1['isDisplay'] == true) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('firstShow', false);
                              Navigator.pushNamed(context, '/checklist-screen');
                            } else {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('firstShow', true);
                              Navigator.pushNamed(context, '/jobs-pagination');
                            }
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
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please select vehicle no.",
                          toastLength: Toast.LENGTH_LONG);
                    }
                  },
                  child: Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    _vehicleData = _getVehicleCategories();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ModalProgressHUD(
            inAsyncCall: _loading,
            child: ListView(children: <Widget>[
              Container(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/login.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Image.asset("assets/images/logo.png"),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: BorderedText(
                          strokeWidth: 2.0,
                          strokeColor: Color(0xfffbefa7),
                          child: Text('WLO Driver App', style: normalText),
                        ),
                      ),
                      _loginContent(),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['vehicle_id'].toString(),
        THIRD_LEVEL_NAME: json['vehicle_registration_number']);
  }
}
