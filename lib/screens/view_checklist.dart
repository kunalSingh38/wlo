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
import 'package:wlo_master/components/CustomRadioWidget2.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/models/xml_json.dart';
import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class VehicleChecklistsView extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<VehicleChecklistsView> {
  Future<dynamic> _checkList;
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no;
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  var dataResponse;
  bool proceed = false;
  bool proceed2 = false;
  String formattedDate1 = "";
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
        print("<<<<<<<<<<<<<<<<" + vehicle_no);
        _checkList = _checkListData();
      });
    });
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));

  Future _checkListData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var uri = Uri.parse(URL + '/vehicle-check-list')
        .replace(query: 'vehicle_id=' + vehicle_no);
    var response = await http.get(
      uri,
      headers: headers,
    );
    print(uri);
    dataResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      print(dataResponse);
      arr = new List(dataResponse['data'].length);
      for (int i = 0; i < dataResponse['data'].length; i++) {
        if (dataResponse['data'][i]['status'] == "Pass") {
          setState(() {
            arr[i] = 1;
          });
        } else {
          setState(() {
            arr[i] = 2;

            // _controllers.add( TextEditingController(text: dataResponse['data'][i]['failed_reason']));
          });
        }
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
      _checkList = _checkListData();
    });
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text(
        'NO RECORDS FOUND!',
        style: TextStyle(fontSize: 20, letterSpacing: 1, color: Colors.black),
      )),
    );
  }

  Widget _radioBuilder(int index) {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Row(children: <Widget>[
          CustomRadioWidget2(
            value: 1,
            groupValue: arr[index],
            groupName: "Pass",
            onChanged: (val) {
              print("value is $val");
              // selectedRadio(val, index);
            },
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: CustomRadioWidget2(
              value: 2,
              groupValue: arr[index],
              // focusColor: Color(0xFFe7bf2e),
              groupName: "Fail",
              onChanged: (val) {
                print("value is $val");
                print("value is $index");
                //  selectedRadio(val, index);
              },
            ),
          ),
        ]));
  }

  selectedRadio(int val, int ind) {
    setState(() {
      arr[ind] = val;
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
      popupDirection: TooltipDirection.up,
      top: 50.0,
      right: 5.0,
      left: 100.0,
      showCloseButton: ShowCloseButton.outside,
      hasShadow: false,
      content: new Material(
          child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text(
          response,
          softWrap: true,
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
                        // _controllers.add(new TextEditingController());
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/view-single-checklist',
                              arguments: <String, String>{
                                'checklist_id':
                                    response[index]['id'].toString(),
                              },
                            );
                          },
                          child: Column(children: <Widget>[
                            Row(children: <Widget>[
                              Expanded(
                                child: Container(
                                    child: Column(children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
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
                                            response[index]['checklist']
                                                ['checklist_name'],
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                            style: normalText1,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        /* InkWell(
                                              onTap: () {
                                                onTap(response[index]['checklist']['checklist_desc']);
                                              },
                                              child: Image(
                                                image: AssetImage("assets/images/tool.png"),
                                                height: 12.0,
                                                width: 12.0,
                                              ),
                                            ),*/
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
                                  /* arr[index] == 2
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
                                        margin: const EdgeInsets.only(right: 30.0, left: 8),
                                        child: TextFormField(
                                            controller: _controllers[index],
                                            keyboardType: TextInputType.text,
                                            cursorColor: Color(0xff000000),
                                            textCapitalization:
                                            TextCapitalization.sentences,
                                            onSaved: (String value) {
                                              _controllers[index].text = value;
                                            },
                                            enabled: false,
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
                                                hintText: 'What is Reason?',
                                                hintStyle: TextStyle(
                                                    color: Color(0xffcdcbcb), fontSize: 16),
                                                fillColor: Color(0xffffffff),
                                                filled: true)),
                                      )
                                          : Container(),
                                      SizedBox(
                                        height: 6,
                                      ),*/
                                ])),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  child: Image(
                                    image: AssetImage(
                                      "assets/images/draw.png",
                                    ),
                                    color: Color(0xffb5322f),
                                    height: 14.0,
                                  ),
                                ),
                              ),
                            ]),
                            new Container(
                                child: Divider(
                              color: Color(0xfffbefa7),
                              thickness: 1,
                            )),
                            SizedBox(
                              height: 10,
                            ),
                          ]),
                        );
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
                  child: Text('View Checklist', style: normalText),
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
                      height: 20.0,
                    ),
                    Expanded(child: Container(child: quizList())),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                )),
          ),
        ));
  }
}
