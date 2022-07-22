import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/models/xml_json.dart';
import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class VehicleChecklists extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<VehicleChecklists> {
  Future<dynamic> _checkList;
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  List<XMLJSON> xmlList = new List();
  var dataResponse;
  bool proceed = false;
  bool proceed2 = false;
  String formattedDate1 = "";

  String odometer = "";
  @override
  void initState() {
    super.initState();
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MMM-yyyy');
    formattedDate1 = formatter.format(now);
    _getUser();
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();

        _checkList = _checkListData();
        showDialog(
          barrierDismissible: false,
          context: context,
          useSafeArea: true,
          useRootNavigator: true,
          builder: (BuildContext context) => CustomDialog(
            title: "Odometer Reading",
            description: "Enter Odometer Reading",
            applyButtonText: "Add",
          ),
        );
      });
    });
  }

  Widget CustomDialog(
      {String title, String description, String applyButtonText}) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, title, description, applyButtonText),
    );
  }

  final nameController = TextEditingController();
  TextStyle normalText11 = GoogleFonts.montserrat(
      fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black);
  dialogContent(BuildContext context, String title, String description,
      String applyButtonText) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 4.0 * 8,
            bottom: 30.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 10.0),
          decoration: new BoxDecoration(
            color: Colors.white, //Colors.black.withOpacity(0.3),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Center(
                child: BorderedText(
                  strokeWidth: 2.0,
                  strokeColor: Color(0xfffbefa7),
                  child: Text(title, style: normalText),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    controller: nameController,
                    //  maxLength: 10,
                    keyboardType: TextInputType.number,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    onSaved: (value) {
                      nameController.text = value;
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 30, 30, 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color(0xfff9f9fb),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color(0xfff9f9fb),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color(0xfff9f9fb),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color(0xfff9f9fb),
                          ),
                        ),
                        counterText: "",
                        hintText: description,
                        hintStyle:
                            TextStyle(color: Color(0xffBBBFC3), fontSize: 16),
                        fillColor: Color(0xfff9f9fb),
                        filled: true)),
              ),
              SizedBox(height: 24.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          color: Color(0xffb5322f),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          onPressed: () async {
                            setState(() {
                              odometer = nameController.text;
                              print(odometer);
                            });
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            applyButtonText,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
        /*  Positioned(
          left: 16.0,
          right: 16.0,
          child: Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/login.png',
            ),
          ),
        ),*/
      ],
    );
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText2 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));

  Future _checkListData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/checklists"),
      headers: headers,
    );
    dataResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print(dataResponse);
      arr = new List(dataResponse['data'].length);
      for (int i = 0; i < dataResponse['data'].length; i++) {
        setState(() {
          arr[i] = null;
        });
      }
      print(arr);
      return dataResponse;
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
    /*else{
      _showCompulsoryUpdateDialog(
        context,
        "Please refresh again",
      );
    }*/
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

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text(
        'NO RECORDS FOUND!',
        style: TextStyle(fontSize: 20, letterSpacing: 1, color: Colors.white),
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
                    color: Color(0xff0347FD),
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
                    new Text("Yes", style: TextStyle(color: Color(0xff0347FD))),
              ),
            ],
          ),
        )) ??
        false;
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

  Widget _radioBuilder(int index) {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Row(children: <Widget>[
          CustomRadioWidget(
            value: 1,
            groupValue: arr[index],
            groupName: "Pass",
            onChanged: (val) {
              print("value is $val");
              selectedRadio(val, index);
            },
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: CustomRadioWidget(
              value: 2,
              groupValue: arr[index],
              // focusColor: Color(0xFFe7bf2e),
              groupName: "Fail",
              onChanged: (val) {
                print("value is $val");
                print("value is $index");
                selectedRadio(val, index);
              },
            ),
          ),
        ]));
  }

  selectedRadio(int val, int ind) {
    setState(() {
      arr[ind] = val;
      valuefirst = false;
    });
  }

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
      popupDirection: TooltipDirection.down,
      top: 100.0,
      right: 20.0,
      left: 100.0,
      // maxHeight: 200,
      minHeight: 200,
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
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: Container(child: CircularProgressIndicator()));
        } else {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            if (snapshot.hasData) {
              var errorCode = snapshot.data['status'];
              var response = snapshot.data['data'];
              if (errorCode == 200) {
                if (response.length != 0) {
                  return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: response.length,
                      itemBuilder: (context, index) {
                        _controllers.add(new TextEditingController());
                        return Container(
                            child: Column(children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    (index + 1).toString() + '. ',
                                    textAlign: TextAlign.left,
                                    style: normalText1,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    response[index]['checklist_name'],
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: normalText1,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    onTap(response[index]['checklist_desc']);
                                  },
                                  child: Image(
                                    image: AssetImage("assets/images/tool.png"),
                                    height: 15.0,
                                    width: 15.0,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          _radioBuilder(index),
                          SizedBox(
                            height: 10,
                          ),
                          arr[index] == 2
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25.0),
                                    boxShadow: [
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
                                    ],
                                  ),
                                  margin: const EdgeInsets.only(
                                      right: 30.0, left: 8),
                                  child: TextFormField(
                                      controller: _controllers[index],
                                      keyboardType: TextInputType.text,
                                      cursorColor: Color(0xff000000),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onSaved: (String value) {
                                        _controllers[index].text = value;
                                      },
                                      decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              15, 30, 30, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Color(0xffcdcbcb),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Color(0xffcdcbcb),
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Color(0xffcdcbcb),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Color(0xffcdcbcb),
                                            ),
                                          ),
                                          counterText: "",
                                          hintText: 'What is Reason?',
                                          hintStyle: TextStyle(
                                              color: Color(0xffcdcbcb),
                                              fontSize: 16),
                                          fillColor: Color(0xffffffff),
                                          filled: true)),
                                )
                              : Container(),
                          SizedBox(
                            height: 6,
                          ),
                          new Container(
                              child: Divider(
                            color: Color(0xfffbefa7),
                            thickness: 1,
                          )),
                          SizedBox(
                            height: 10,
                          ),
                        ]));
                      });
                } else {
                  return _emptyOrders();
                }
              } else {
                return _emptyOrders();
              }
            } else {
              return _emptyOrders();
            }
          }
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
        /*  drawer: Drawer(
          child: Column(
            children: <Widget>[
              */ /*buildUserInfo(context),
              buildDrawerItem(),*/ /*
            ],
          ),
        ),*/
        appBar: AppBar(
          leading: Container(),
          centerTitle: true,
          title: Container(
            child: Row(children: <Widget>[
              Center(
                child: BorderedText(
                  strokeWidth: 2.0,
                  strokeColor: Color(0xfffbefa7),
                  child: Text('Vehicle Checklist', style: normalText),
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
              icon: const Icon(
                Icons.power_settings_new,
                color: Color(0xffb5322f),
              ),
              onPressed: () async {
                _logoutPop();
              },
            ),
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
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Container(
            child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: deviceSize.width * 0.03,
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
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Color(0xffb5322f),
                                value: this.valuefirst,
                                onChanged: (bool value) {
                                  setState(() {
                                    this.valuefirst = value;
                                    if (valuefirst) {
                                      for (int i = 0; i < arr.length; i++) {
                                        arr[i] = 1;
                                      }
                                    } else {
                                      for (int i = 0; i < arr.length; i++) {
                                        arr[i] = null;
                                      }
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Pass All",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
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
                      height: 20.0,
                    ),
                    Expanded(child: Container(child: quizList())),
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width * 0.80,
                        height: 50.0,
                        child: Container(
                          child: RaisedButton(
                            splashColor: Color(0xfffbefa7),
                            padding: const EdgeInsets.only(
                                top: 2, bottom: 2, left: 20, right: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            textColor: Color(0xffb5322f),
                            color: Color(0xfffbefa7),
                            onPressed: () async {
                              if (valuefirst) {
                                for (int i = 0;
                                    i < dataResponse['data'].length;
                                    i++) {
                                  XMLJSON xmljson = new XMLJSON();
                                  xmljson.checklist_id =
                                      dataResponse['data'][i]['checklist_id'];
                                  xmljson.status = 'Pass';
                                  xmljson.failed_reason = null;

                                  xmlList.add(xmljson);
                                }
                                setState(() {
                                  _loading = true;
                                });

                                Map<String, String> headers = {
                                  'Accept': 'application/json',
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $access_token',
                                };
                                var response = await http.post(
                                  Uri.parse(URL + "/vehicle-check-list/create"),
                                  body: jsonEncode({
                                    "vehicle_id": int.parse(vehicle_no),
                                    "odometer_reading": double.parse(odometer),
                                    "VehicleChecklist": xmlList,
                                  }),
                                  headers: headers,
                                );
                                log(jsonEncode({
                                  "vehicle_id": int.parse(vehicle_no),
                                  "odometer_reading": double.parse(odometer),
                                  "VehicleChecklist": xmlList,
                                }));
                                var data = json.decode(response.body);
                                print(data);
                                if (response.statusCode == 201) {
                                  setState(() {
                                    _loading = false;
                                  });

                                  var dataRes = data['data'];
                                  print(dataRes);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('mDateKey', formattedDate1);
                                  Navigator.pushNamed(
                                      context, '/jobs-pagination');
                                } else {
                                  setState(() {
                                    _loading = false;
                                  });
                                  /* var errorMessage =
                                  data['errors'][0]['message'];
                                  showAlertDialog(context, ALERT_DIALOG_TITLE,
                                      errorMessage);*/
                                }
                              } else {
                                for (int i = 0;
                                    i < dataResponse['data'].length;
                                    i++) {
                                  if (arr[i] == 2) {
                                    if (_controllers[i].text == null) {
                                      setState(() {
                                        proceed2 = true;
                                      });
                                    }
                                  }

                                  if (arr.contains(null)) {
                                    print("<<<<<<<<<<<<<<<<<" +
                                        arr[i].toString());
                                    setState(() {
                                      proceed = false;
                                    });
                                  } else {
                                    setState(() {
                                      proceed = true;
                                    });
                                  }
                                }
                                if (proceed) {
                                  if (proceed2 != true) {
                                    for (int i = 0;
                                        i < dataResponse['data'].length;
                                        i++) {
                                      XMLJSON xmljson = new XMLJSON();
                                      xmljson.checklist_id =
                                          dataResponse['data'][i]
                                              ['checklist_id'];
                                      xmljson.status =
                                          arr[i] == 1 ? 'Pass' : 'Fail';
                                      xmljson.failed_reason = arr[i] == 2
                                          ? _controllers[i].text
                                          : null;

                                      xmlList.add(xmljson);
                                    }
                                    setState(() {
                                      _loading = true;
                                    });

                                    Map<String, String> headers = {
                                      'Accept': 'application/json',
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $access_token',
                                    };
                                    var response = await http.post(
                                      Uri.parse(
                                          URL + "/vehicle-check-list/create"),
                                      body: jsonEncode({
                                        "vehicle_id": int.parse(vehicle_no),
                                        "VehicleChecklist": xmlList,
                                      }),
                                      headers: headers,
                                    );
                                    log(jsonEncode(xmlList));
                                    var data = json.decode(response.body);
                                    print(data);
                                    if (response.statusCode == 201) {
                                      setState(() {
                                        _loading = false;
                                      });

                                      var dataRes = data['data'];
                                      print(dataRes);
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString(
                                          'mDateKey', formattedDate1);
                                      Navigator.pushNamed(
                                          context, '/jobs-pagination');
                                    } else if (response.statusCode == 401) {
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
                                      var errorMessage =
                                          data['errors'][0]['message'];
                                      showAlertDialog(context,
                                          ALERT_DIALOG_TITLE, errorMessage);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please fill fail reason",
                                        toastLength: Toast.LENGTH_SHORT);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please select all checklist",
                                      toastLength: Toast.LENGTH_SHORT);
                                }
                              }
                            },
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                )),
          ),
        ));
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
