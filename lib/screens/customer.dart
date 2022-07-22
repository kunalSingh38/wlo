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
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/models/xml_json.dart';
import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class CustomerList extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<CustomerList> {
  Future<dynamic> _checkList;
  static int page;
  int page1 = 1;
  int count = 0;
  List users = new List();
  ScrollController _sc = new ScrollController();
  bool _loading = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  int id = 0;
  bool valuefirst = false;
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = new List();
  List<XMLJSON> xmlList = new List();
  var dataResponse;
  bool proceed = false;
  bool proceed2 = false;
  String formattedDate1 = "";
  bool isEnabled3 = false;
  bool isEnabled4 = false;
  bool isEnabled5 = true;
  bool isEnabled6 = false;

  bool isEnabled7 = true;
  bool isEnabled8 = false;
  bool isEnabled9 = true;
  bool isEnabled10 = false;
  bool isEnabled11 = false;
  bool isEnabled12 = false;
  List<UserDetails> _userDetails = [];
  List<UserDetails> _searchResult = [];

  bool lastpage = false;
  bool text1 = false;
  bool text2 = false;
  bool text3 = false;

  final completeController = TextEditingController();
  final postCodeController = TextEditingController();
  final accountNoController = TextEditingController();
  final bNameController = TextEditingController();

  // List<String> count = new List();

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
        _checkList = _checkListData("page=$page1", page1);

        /* _sc.addListener(() {
            print(page1);
            print(count);
            if (_sc.position.pixels == _sc.position.maxScrollExtent) {
              setState(() {
                _checkList = _checkListData("page=$page1&per-page=8", page1++);
              });
            }
            if (_sc.position.pixels == _sc.position.minScrollExtent) {
              setState(() {
                _checkList = _checkListData("page=$page1&per-page=8", page1--);
              });
            }
          });*/
      });
    });
  }

  TextStyle normalText0 = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xff000000));
  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText2 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalText3 = GoogleFonts.montserrat(
      fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey);
  TextStyle normalText5 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));

  int totalCount = 0;
  int pageCount = 0;
  Future _checkListData(String type, int page) async {
    _searchResult.clear();
    _userDetails.clear();
    completeController.text = "";
    if (!lastpage)
      setState(() {
        _loading = true;
      });

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var uri;
    if (page != 0) {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/customers')
          .replace(query: type);
    } else if (isEnabled4 == true) {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/customers')
          .replace(query: type);
    } else if (type == "") {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/customers');
    } else {
      uri = Uri.parse('https://wloapp.crowdrcrm.com/v1/customers');
    }
    print(uri);
    var response = await http.get(
      uri,
      headers: headers,
    );
    print(access_token);
    dataResponse = json.decode(response.body);
    print(dataResponse['__meta']);

    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      if (dataResponse['data'] != 0) {
        var result = dataResponse['data'];
        totalCount = dataResponse['__meta']['totalCount'];
        pageCount = dataResponse['data'].length;

        setState(() {
          for (Map user in result) {
            _userDetails.add(UserDetails.fromJson(user));
          }
        });
      }

      setState(() {
        page1 = page1++;
      });
      /* if (page1<=dataResponse['__meta']['pageCount']) {
        setState(() {
          count=dataResponse['__meta']['pageCount'];
          page1 = page1 + dataResponse['__meta']['pageCount'];
        });
      }
      else{
       // print(",,,,,,,,,,,,,,,,,");
        setState(() {
          lastpage=true;
        });

       */ /* Fluttertoast.showToast(
            msg: "Last Page", toastLength: Toast
            .LENGTH_SHORT);*/ /*
      }*/

      return dataResponse;
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
    }

    /* else {
      setState(() {
        _loading = false;
      });
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
      //   _checkList = _checkListData("");
    });
  }

  Widget _emptyOrders() {
    return Center(
      child: Container(
          child: Text(
        'NO RECORDS FOUND!',
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
                          page1 = 0;
                          isEnabled3 = false;
                          isEnabled4 = false;
                          isEnabled7 = true;
                          isEnabled8 = false;
                          isEnabled9 = true;
                          isEnabled10 = false;
                          isEnabled5 = true;
                          isEnabled6 = false;
                        });
                        print(page1);
                        Navigator.pop(context);
                        _checkList = _checkListData("", page1);
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
                                  _checkList = _checkListData(
                                      "page=$page&sort=-customer_id", page);
                                });
                              },
                              child: Text(
                                "Dsc",
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
                                  _checkList = _checkListData(
                                      "page=$page&sort=customer_id", page);
                                });
                              },
                              child: Text(
                                "Asc",
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
                        child: Text("Customer Id",
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
                                  _checkList = _checkListData(
                                      "page=$page&sort=-customer_businessname",
                                      page);
                                });
                              },
                              child: Text(
                                "Dsc",
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
                                  _checkList = _checkListData(
                                      "page=$page&sort=customer_businessname",
                                      page);
                                });
                              },
                              child: Text(
                                "Asc",
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
                        child: Text("Business name",
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
                              color: isEnabled9
                                  ? Color(0xffb5322f)
                                  : Color(0xfffbefa7),
                              onPressed: () async {
                                setState(() {
                                  isEnabled9 = true;
                                  isEnabled10 = false;
                                  _checkList = _checkListData(
                                      "page=$page&sort=-postcode", page);
                                });
                              },
                              child: Text(
                                "Dsc",
                                style: TextStyle(
                                  color: isEnabled9
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
                              color: isEnabled10
                                  ? Color(0xffb5322f)
                                  : Color(0xfffbefa7),
                              onPressed: () async {
                                setState(() {
                                  isEnabled10 = true;
                                  isEnabled9 = false;
                                  _checkList = _checkListData(
                                      "page=$page&sort=postcode", page);
                                });
                              },
                              child: Text(
                                "Asc",
                                style: TextStyle(
                                  color: isEnabled10
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
                        child: Text("Post code",
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

  bool isSwitched = false;

  void toggleSwitch() {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
      _checkList = _checkListData("page=$page1", page1);
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  TextStyle normalTex4 = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

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
                            page1 = 0;
                            isEnabled3 = false;
                            isEnabled4 = false;
                            /*  isEnabled5=false;
                                  isEnabled6=false;*/
                            /*  isEnabled7=false;
                                  isEnabled8=false;
                                  isEnabled9=false;
                                  isEnabled10=false;
                                  isEnabled11=false;
                                  isEnabled12=false;*/
                            postCodeController.text = "";
                            bNameController.text = "";
                            accountNoController.text = "";
                          });
                          print(page1);
                          Navigator.pop(context);
                          _checkList = _checkListData("", page1);
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
                            /*boxShadow: [
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
                            child: Text("Account no.",
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
                              controller: accountNoController,
                              keyboardType: TextInputType.text,
                              cursorColor: Color(0xff000000),
                              textCapitalization: TextCapitalization.sentences,
                              onSaved: (String value) {
                                accountNoController.text = value;
                              },
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
                                  hintText: 'Account No...',
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
                              controller: bNameController,
                              keyboardType: TextInputType.text,
                              cursorColor: Color(0xff000000),
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (String value) {
                                text3 = true;
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
                            /* boxShadow: [
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
                              ],*/
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
                                    "postcode=${postCodeController.text}",
                                    page);

                                if (text2) {
                                  _checkList = _checkListData(
                                      "postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}",
                                      page);
                                  if (text3) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                        page);
                                  }
                                } else if (text3) {
                                  _checkList = _checkListData(
                                      "postcode=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                      page);
                                  if (text2) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                        page);
                                  }
                                }
                              } else if (text2) {
                                _checkList = _checkListData(
                                    "customer_accountnumber=${accountNoController.text}",
                                    page);

                                if (text1) {
                                  _checkList = _checkListData(
                                      "postcode=${postCodeController.text}&customer_accountnumber=${accountNoController.text}",
                                      page);
                                  if (text3) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                        page);
                                  }
                                } else if (text3) {
                                  _checkList = _checkListData(
                                      "customer_accountnumber=${bNameController.text}&customer_accountnumber=${accountNoController.text}",
                                      page);
                                  if (text1) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                        page);
                                  }
                                }
                              } else if (text3) {
                                _checkList = _checkListData(
                                    "customer_businessname=${bNameController.text}",
                                    page);

                                if (text2) {
                                  _checkList = _checkListData(
                                      "customer_businessname=${postCodeController.text}&customer_accountnumber=${accountNoController.text}",
                                      page);
                                  if (text1) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                        page);
                                  }
                                } else if (text1) {
                                  _checkList = _checkListData(
                                      "customer_businessname=${bNameController.text}&postcode=${postCodeController.text}",
                                      page);
                                  if (text1) {
                                    _checkList = _checkListData(
                                        "postcode=${postCodeController.text}"
                                        "&customer_accountnumber=${accountNoController.text}&customer_businessname=${bNameController.text}",
                                        page);
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

  Widget quizList() {
    return FutureBuilder(
      future: _checkList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var errorCode = snapshot.data['status'];
          var response = snapshot.data['data'];
          if (errorCode == 200) {
            if (response.length != 0) {
              return _searchResult.length != 0 ||
                      completeController.text.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _searchResult.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/add-newjob',
                              arguments: <String, String>{
                                'cust_id': _searchResult[index].customer_id,
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xFFe3e3e3)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
                            child: Column(children: <Widget>[
                              Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: BorderedText(
                                          strokeWidth: 1.0,
                                          strokeColor: Color(0xfffbefa7),
                                          child: Text(
                                              _searchResult[index]
                                                  .customer_businessname,
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: normalText),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Container(
                                      child: Text(_searchResult[index].postcode,
                                          softWrap: true,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: normalText3),
                                    ),
                                  ]),
                              SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(children: <Widget>[
                                          BorderedText(
                                            strokeWidth: 1.0,
                                            strokeColor: Color(0xfffbefa7),
                                            child: Text("Address:- ",
                                                softWrap: true,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: normalText1),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: BorderedText(
                                                strokeWidth: 1.0,
                                                strokeColor: Color(0xfffbefa7),
                                                child: Text(
                                                    _searchResult[index]
                                                            .customer_address1 +
                                                        ", " +
                                                        _searchResult[index]
                                                            .customer_address2,
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: normalText2),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Image(
                                      image:
                                          AssetImage("assets/images/right.png"),
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ]),
                            ]),
                          ),
                        );
                      })
                  : Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          controller: _sc,
                          itemCount: response.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/add-newjob',
                                  arguments: <String, String>{
                                    'cust_id': response[index]['customer_id']
                                        .toString(),
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Color(0xFFe3e3e3)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0))),
                                child: Column(children: <Widget>[
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: BorderedText(
                                              strokeWidth: 1.0,
                                              strokeColor: Color(0xfffbefa7),
                                              child: Text(
                                                  response[index]
                                                      ['customer_businessname'],
                                                  softWrap: true,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: normalText),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Container(
                                          child: Text(
                                              response[index]['postcode'],
                                              softWrap: true,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: normalText3),
                                        ),
                                      ]),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: BorderedText(
                                                strokeWidth: 1.0,
                                                strokeColor: Color(0xfffbefa7),
                                                child: Text(
                                                    "Address:- " +
                                                        response[index][
                                                            'customer_address1'] +
                                                        ", " +
                                                        response[index][
                                                            'customer_address2'],
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: normalText2),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Image(
                                          image: AssetImage(
                                              "assets/images/right.png"),
                                          height: 30.0,
                                          width: 30.0,
                                        ),
                                      ]),
                                ]),
                              ),
                            );
                          }),
                    );
            } else {
              return _emptyOrders();
            }
          } else {
            return _emptyOrders();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container());
        } else {
          return Center(child: Container());
        }
      },
    );
  }

  Future<void> _pullRefresh() async {
    print("svddd");
    _checkList = _checkListData("", 0);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: Scaffold(
        //  key: _scaffoldKey,
        // resizeToAvoidBottomInset: false,

        /* appBar: AppBar(
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
                      child: Text('Customer', style: normalText),
                    ),
                  ),
                ]),
              ),
              flexibleSpace: Container(
                height: 100,
                color: Color(0xfffbefa7),
              ),
              actions: <Widget>[
               */ /* IconButton(
                  icon: Image(
                    image: AssetImage("assets/images/notifications.png"),
                    height: 30.0,
                    width: 30.0,
                  ),
                  onPressed: () async {},
                ),*/ /*
              ],
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              backgroundColor: Colors.transparent,
            ),*/
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
                      height: 5.0,
                    ),
                    Row(children: <Widget>[
                      Expanded(
                        child: Container(
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
                          margin: const EdgeInsets.only(right: 8.0, left: 8),
                          child: TextFormField(
                              controller: completeController,
                              keyboardType: TextInputType.text,
                              cursorColor: Color(0xff000000),
                              textCapitalization: TextCapitalization.sentences,
                              onSaved: (String value) {
                                completeController.text = value;
                              },
                              onChanged: onSearchTextChanged,
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
                                  hintText: 'Search Name, PostCode...',
                                  hintStyle: TextStyle(
                                      color: Color(0xffcdcbcb), fontSize: 16),
                                  fillColor: Color(0xffffffff),
                                  filled: true)),
                        ),
                      ),
                      ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xfffbefa7),
                            boxShadow: [
                              //background color of box
                              BoxShadow(
                                color: Color(0xfffbefa7),
                                blurRadius: 3.0, // soften the shadow
                                spreadRadius: 3.0, //extend the shadow
                                offset: Offset(
                                  0.0, // Move to right 10  horizontally
                                  0.0, // Move to bottom 10 Vertically
                                ),
                              )
                            ],
                          ),
                          child: Material(
                            color: Color(0xfffbefa7), // Button color
                            child: InkWell(
                              splashColor: Color(0xfffbefa7),
                              // Splash color
                              onTap: () {},
                              child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.search,
                                    color: Color(0xffb5322f),
                                  )),
                            ),
                          ),
                        ),
                      )
                    ]),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      ButtonTheme(
                        //  minWidth: 50.0,
                        height: 30.0,
                        child: RaisedButton(
                          padding: const EdgeInsets.only(
                              top: 2, bottom: 2, left: 10, right: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  bottomLeft: Radius.circular(25))),
                          color: isEnabled3 ? Color(0xffb5322f) : Colors.white,
                          onPressed: () async {
                            setState(() {
                              isEnabled3 = true;
                              isEnabled4 = false;
                              displayModalBottomSheet(context);
                            });
                          },
                          child: Row(children: [
                            Image(
                              image: AssetImage("assets/images/shortby.png"),
                              height: 17.0,
                              width: 17.0,
                              color:
                                  isEnabled3 ? Colors.white : Color(0xffb5322f),
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
                      ButtonTheme(
                        // minWidth: 50.0,
                        height: 30.0,
                        child: RaisedButton(
                          padding: const EdgeInsets.only(
                              top: 2, bottom: 2, left: 10, right: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25))),
                          color: isEnabled4 ? Color(0xffb5322f) : Colors.white,
                          onPressed: () async {
                            setState(() {
                              isEnabled4 = true;
                              isEnabled3 = false;
                              displayModalBottomSheet2(context);
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
                              image: AssetImage("assets/images/filter.png"),
                              height: 17.0,
                              width: 17.0,
                              color:
                                  isEnabled4 ? Colors.white : Color(0xffb5322f),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                    new Container(
                        child: Divider(
                      color: Color(0xfffbefa7),
                      thickness: 1,
                    )),
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
                            child: Text("Customers",
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: normalText0),
                          ),
                        ),
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
                    ]),
                    SizedBox(
                      height: 5.0,
                    ),
                    Expanded(child: Container(child: quizList())),
                    SizedBox(
                      height: 5.0,
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
                                top: 2, bottom: 2, left: 20, right: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            textColor: Color(0xffb5322f),
                            color: Color(0xfffbefa7),
                            onPressed: () {
                              Navigator.pushNamed(context, '/add-customer');
                            },
                            child: Text(
                              "Add Customer",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
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
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    print(text);
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.customer_businessname
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()) ||
          userDetail.postcode
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });
    print(_searchResult);

    setState(() {});
  }
}

class UserDetails {
  final String customer_id,
      customer_businessname,
      postcode,
      customer_address1,
      customer_address2;

  UserDetails({
    this.customer_id,
    this.customer_businessname,
    this.postcode,
    this.customer_address1,
    this.customer_address2,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
      customer_id: json['customer_id'].toString(),
      customer_businessname: json['customer_businessname'],
      postcode: json['postcode'],
      customer_address1: json['customer_address1'],
      customer_address2: json['customer_address2'],
    );
  }
}
