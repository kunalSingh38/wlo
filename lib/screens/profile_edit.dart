import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';

import 'package:flutter/cupertino.dart';
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

class ProfileEdit extends StatefulWidget {
  final Object argument;

  const ProfileEdit({Key key, this.argument}) : super(key: key);
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<ProfileEdit> {
  Future<dynamic> _checkList;
  var access_token;
  String vehicle_no = '';
  bool _autoValidate = false;
  final firstController = TextEditingController();
  final lastController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  var profile_id = "";
  String profile_pic = "";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    profile_id = data['profile_id'];
    _getUser();
  }

  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff000000));

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        profile_pic = prefs.getString('profile_pic').toString();
        _checkList = _checkListData();
      });
    });
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff000000));

  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalTex3 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));

  TextStyle normalText4 = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: Color(0xff000000),
    decoration: TextDecoration.underline,
  );

  double lat = 0.0;
  double lng = 0.0;
  Future _checkListData() async {
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
      return data;
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
  }

  void dispose() {
    firstController.dispose();
    lastController.dispose();
    phoneController.dispose();
    emailController.dispose();

    super.dispose();
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

  bool isSwitched = false;
  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  Widget _fNameTextBox(_initialValue) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0, left: 8),
      child: TextFormField(
          initialValue: _initialValue,
          keyboardType: TextInputType.text,
          cursorColor: Color(0xff000000),
          textCapitalization: TextCapitalization.sentences,
          onSaved: (String value) {
            firstController.text = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter first name';
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
              fillColor: Color(0xffffffff),
              filled: true)),
    );
  }

  Widget _lNameTextBox(_initialValue) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0, left: 8),
      child: TextFormField(
          initialValue: _initialValue,
          keyboardType: TextInputType.text,
          cursorColor: Color(0xff000000),
          textCapitalization: TextCapitalization.sentences,
          onSaved: (String value) {
            lastController.text = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter first name';
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
              fillColor: Color(0xffffffff),
              filled: true)),
    );
  }

  Widget _emailBox(_initialValue) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0, left: 8),
      child: TextFormField(
          initialValue: _initialValue,
          keyboardType: TextInputType.text,
          cursorColor: Color(0xff000000),
          textCapitalization: TextCapitalization.sentences,
          onSaved: (String value) {
            emailController.text = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter email';
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
              fillColor: Color(0xffffffff),
              filled: true)),
    );
  }

  Widget _phoneBox(_initialValue) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0, left: 8),
      child: TextFormField(
          initialValue: _initialValue,
          keyboardType: TextInputType.text,
          cursorColor: Color(0xff000000),
          textCapitalization: TextCapitalization.sentences,
          onSaved: (String value) {
            phoneController.text = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter phone no.';
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
              fillColor: Color(0xffffffff),
              filled: true)),
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
            return Column(children: [
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
              const SizedBox(height: 15.0),
              _fNameTextBox(response['first_name']),
              const SizedBox(height: 15.0),
              _lNameTextBox(response['last_name']),
              const SizedBox(height: 15.0),
              _emailBox(response['email']),
              const SizedBox(height: 15.0),
              _phoneBox(response['phone']),
              const SizedBox(height: 15.0),
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
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $access_token',
                          };
                          var response = await http.put(
                            Uri.parse(URL +
                                "/profile/${int.parse(profile_id)}/update"),
                            body: jsonEncode({
                              "first_name": firstController.text,
                              "last_name": lastController.text,
                              "email": emailController.text,
                              "phone": phoneController.text,
                              "status": 1,
                            }),
                            headers: headers,
                          );
                          print(jsonEncode({
                            "first_name": firstController.text,
                            "last_name": lastController.text,
                            "email": emailController.text,
                            "phone": phoneController.text,
                            "status": 1,
                          }));
                          var data = json.decode(response.body);
                          print(data);
                          if (response.statusCode == 200) {
                            setState(() {
                              _loading = false;
                            });
                            Fluttertoast.showToast(
                                msg: "Profile edit successfully",
                                toastLength: Toast.LENGTH_SHORT);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              prefs.setString(
                                  'driverName',
                                  data['data']['first_name'] +
                                      " " +
                                      data['data']['last_name']);
                            });

                            Navigator.of(context).pop();
                            Navigator.pushReplacementNamed(
                                context, '/profile-view');
                          } else if (response.statusCode == 401) {
                            setState(() {
                              _loading = false;
                            });
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.getKeys();
                            for (String key in preferences.getKeys()) {
                              if (key != "mDateKey") {
                                preferences.remove(key);
                              }
                            }
                            Navigator.pushReplacementNamed(context, '/login');
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
                        "Update ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
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
                  child: Text('Edit Profile', style: normalText),
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
          child: Container(
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: deviceSize.width * 0.05,
                  ),
                  child: quizList()),
            ),
          ),
        ));
  }
}
