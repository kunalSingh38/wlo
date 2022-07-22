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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class ProfileView extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<ProfileView> {
  Future<dynamic> _checkList;
  var access_token;
  String vehicle_no = '';
  String profile_pic = "";
  @override
  void initState() {
    super.initState();

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

  void toggleSwitch(int id) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
      Navigator.pushNamed(
        context,
        '/profile-edit',
        arguments: <String, String>{
          'profile_id': id.toString(),
        },
      );
    } else {
      setState(() {
        isSwitched = false;
      });
    }
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
              const SizedBox(height: 15.0),
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
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Edit", style: normalText1),
                      Transform.scale(
                          scale: 1,
                          child: Switch(
                            onChanged: (c) {
                              toggleSwitch(response['id']);
                            },
                            value: isSwitched,
                            activeColor: Color(0xffb5322f),
                            activeTrackColor: Colors.grey,
                            inactiveThumbColor: Color(0xfffbefa7),
                            inactiveTrackColor: Colors.grey,
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    initialValue: response['first_name'],
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    enabled: false,
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
                        filled: true)),
              ),
              const SizedBox(height: 15.0),
              Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    initialValue: response['last_name'],
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    enabled: false,
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
                        filled: true)),
              ),
              const SizedBox(height: 15.0),
              Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    initialValue: response['empcode'],
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    enabled: false,
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
                        filled: true)),
              ),
              const SizedBox(height: 15.0),
              Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    initialValue: response['phone'],
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    enabled: false,
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
                        filled: true)),
              ),
              const SizedBox(height: 15.0),
              Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    initialValue: response['email'],
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    enabled: false,
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
                        filled: true)),
              ),
              const SizedBox(height: 15.0),
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
                  child: Text('View Profile', style: normalText),
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
              child: quizList()),
        ));
  }
}
