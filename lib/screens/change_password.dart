import 'dart:async';
import 'dart:convert';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/services/shared_preferences.dart';
import '../constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<ChangePasswordScreen> {
  final oldController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  var _type = "";
  bool _autoValidate = false;
  var access_token;
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black);
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 38, fontWeight: FontWeight.w500, color: Colors.black);
  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        print(access_token);
      });
    });
  }

  Widget _loginContent() {
    return Container(
      margin: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: oldController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter old password';
                  }
                  return null;
                },
                onSaved: (String value) {
                  oldController.text = value;
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
                    hintText: 'Enter old password',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 25.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: passController,
                obscureText: true,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter new password';
                  }
                  return null;
                },
                onSaved: (String value) {
                  passController.text = value;
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
                    hintText: 'Enter new password',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 25.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please confirm password';
                  } else if (value != passController.text) {
                    return 'Password not matched';
                  }
                  return null;
                },
                onSaved: (String value) {
                  confirmController.text = value;
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
                    hintText: 'Confirm Password',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
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
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      setState(() {
                        _loading = true;
                      });

                      Map<String, String> headers = {
                        'Accept': 'application/json',
                        'Authorization': 'Bearer $access_token',
                      };
                      var response = await http.post(
                        Uri.parse(URL + "/profile/change-password"),
                        body: {
                          "oldPassword": oldController.text,
                          "password": passController.text,
                          "confirmPassword": confirmController.text,
                        },
                        headers: headers,
                      );
                      print({
                        "oldPassword": oldController.text,
                        "password": passController.text,
                        "confirmPassword": confirmController.text,
                      });
                      var data = json.decode(response.body);
                      print(data);
                      if (response.statusCode == 201) {
                        setState(() {
                          _loading = false;
                        });
                        var errorMessage = data['message'];

                        Fluttertoast.showToast(
                            msg: errorMessage, toastLength: Toast.LENGTH_SHORT);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.clear();
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/login');
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
                        Navigator.pushReplacementNamed(context, '/login');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                child: Text('Change Password', style: normalText),
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
        child: ListView(children: <Widget>[
          Container(
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                children: <Widget>[
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
                      child: Text('Change Password', style: normalText1),
                    ),
                  ),
                  _loginContent(),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
