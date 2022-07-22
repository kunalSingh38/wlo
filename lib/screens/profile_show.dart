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

class ProfileShow extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<ProfileShow> {
  Future<dynamic> _checkList;
  var access_token;
  String vehicle_no = '';
  String profile_pic = "";
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
        profile_pic = prefs.getString('profile_pic').toString();
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

  bool isSwitched = false;
  bool isSwitched2 = false;

  Widget quizList() {
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var errorCode = snapshot.data['status'];
          var response = snapshot.data['data'];
          if (errorCode == 200) {
            return Column(children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 50.0),
                height: 260.0,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          top: 50.0, left: 10.0, right: 10.0, bottom: 10.0),
                      child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 5.0,
                        color: Color(0xffff3f3f3),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 50.0,
                            ),
                            Text(
                              response['first_name'] +
                                  " " +
                                  response['last_name'],
                              style: normalText,
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              response['email'],
                              style: normalText4,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Center(
                              child: ButtonTheme(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.50,
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
                                        borderRadius:
                                            BorderRadius.circular(25.0)),
                                    textColor: Color(0xffb5322f),
                                    color: Color(0xfffbefa7),
                                    onPressed: () async {
                                      Navigator.pushNamed(
                                          context, '/profile-view');
                                    },
                                    child: Text(
                                      "View Profile",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              new Container(
                  child: Divider(
                color: Colors.black,
                thickness: 1,
              )),
              SizedBox(
                height: 15.0,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/view-checklist');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text("View Checklist", style: normalText1)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              new Container(
                  child: Divider(
                color: Colors.grey,
                thickness: 1,
              )),
              SizedBox(
                height: 15.0,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/change-password');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text("Change Password", style: normalText1)),
                    ],
                  ),
                ),
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
                  child: Text('Profile', style: normalText),
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
        body: Container(
          child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: deviceSize.width * 0.05,
              ),
              child: quizList()),
        ));
  }
}
