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

class CustomerList11 extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<CustomerList11> {
  Future<dynamic> _checkList;

  int count = 0;

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

  bool isLoading = false;
  ScrollController _sc = new ScrollController();
  int page = 1;
  int page1;
  int current_page = 1;

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
        _myProfileData("", page);

        _sc.addListener(() {
          if (_sc.position.pixels == _sc.position.maxScrollExtent) {
            _myProfileData("", page1);
          }
        });
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

  int t2 = 1;
  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  List users = new List();
  void _myProfileData(String query, int page) async {
    if (page <= t2) {
      _searchResult.clear();
      _userDetails.clear();
      completeController.text = "";
      if (page == 1) {
        setState(() {
          isLoading = true;
        });
      }
      if (!_loading) {
        setState(() {
          _loading = true;
        });
      }
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $access_token',
      };
      var uri;
      if (query == "") {
        uri = Uri.parse(URL + '/customers').replace(query: "page=$page");
      } else {
        uri = Uri.parse(URL + '/customers').replace(query: query);
      }

      print(uri);
      var response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        var data = json.decode(response.body);
        var result1 = data['data'];
        totalCount = data['__meta']['totalCount'];
        current_page = data['__meta']['currentPage'];
        pageCount = pageCount + data['data'].length;
        setState(() {
          for (Map user in result1) {
            _userDetails.add(UserDetails.fromJson(user));
          }
        });
        List tList = new List();
        setState(() {
          t2 = data['__meta']['pageCount'];
          print(t2);
        });
        for (int i = 0; i < result1.length; i++) {
          tList.add(result1[i]);
        }
        setState(() {
          _loading = false;
          users.addAll(tList);
          page1 = page + 1;
        });
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
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "No Records Found");
      }
    }
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
                          users.clear();
                        });
                        Navigator.pop(context);
                        _myProfileData("", 1);
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
                                  users.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=-customer_id",
                                      current_page);
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
                                  users.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=customer_id",
                                      current_page);
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
                                  users.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=-customer_businessname",
                                      current_page);
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
                                  users.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=customer_businessname",
                                      current_page);
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
                                  users.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=-postcode",
                                      current_page);
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
                                  users.clear();
                                  _myProfileData(
                                      "page=$current_page&sort=postcode",
                                      current_page);
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
            return SingleChildScrollView(
              child: AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Container(
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
                                postCodeController.text = "";
                                bNameController.text = "";
                                accountNoController.text = "";
                                users.clear();
                                t2 = 1;
                              });
                              print("dfbfdb");
                              Navigator.pop(context);
                              _myProfileData("", 1);
                              print("dfbfdb");
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
                              ),
                              margin:
                                  const EdgeInsets.only(right: 8.0, left: 8),
                              child: TextFormField(
                                  controller: postCodeController,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Color(0xff000000),
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                                      hintText: 'PostCode...',
                                      hintStyle: TextStyle(
                                          color: Color(0xffcdcbcb),
                                          fontSize: 16),
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
                              ),
                              margin:
                                  const EdgeInsets.only(right: 8.0, left: 8),
                              child: TextFormField(
                                  controller: accountNoController,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Color(0xff000000),
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                                      hintText: 'Account No...',
                                      hintStyle: TextStyle(
                                          color: Color(0xffcdcbcb),
                                          fontSize: 16),
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
                              margin:
                                  const EdgeInsets.only(right: 8.0, left: 8),
                              child: TextFormField(
                                  controller: bNameController,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Color(0xff000000),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (String value) {
                                    text3 = true;
                                  },
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 30, 30, 0),
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
                                      hintText: 'Business name...',
                                      hintStyle: TextStyle(
                                          color: Color(0xffcdcbcb),
                                          fontSize: 16),
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
                                  users.clear();
                                  Navigator.pop(context);
                                  if (text1) {
                                    _myProfileData(
                                        "page=$current_page&postcode=${postCodeController.text}",
                                        current_page);

                                    if (text2) {
                                      _myProfileData(
                                          "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}",
                                          current_page);

                                      if (text3) {
                                        _myProfileData(
                                            "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                            current_page);
                                      }
                                    } else if (text3) {
                                      _myProfileData(
                                          "page=$current_page&postcode=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                          current_page);

                                      if (text2) {
                                        _myProfileData(
                                            "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                            current_page);
                                      }
                                    }
                                  } else if (text2) {
                                    _myProfileData(
                                        "page=$current_page&customer_accountnumber=${accountNoController.text}",
                                        current_page);

                                    if (text1) {
                                      _myProfileData(
                                          "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${accountNoController.text}",
                                          current_page);

                                      if (text3) {
                                        _myProfileData(
                                            "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                            current_page);
                                      }
                                    } else if (text3) {
                                      _myProfileData(
                                          "page=$current_page&customer_accountnumber=${bNameController.text}&customer_accountnumber=${accountNoController.text}",
                                          current_page);

                                      if (text1) {
                                        _myProfileData(
                                            "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}&customer_businessname=${postCodeController.text}",
                                            current_page);
                                      }
                                    }
                                  } else if (text3) {
                                    _myProfileData(
                                        "page=$current_page&customer_businessname=${bNameController.text}",
                                        current_page);

                                    if (text2) {
                                      _myProfileData(
                                          "page=$current_page&customer_businessname=${postCodeController.text}&customer_accountnumber=${accountNoController.text}",
                                          current_page);

                                      if (text1) {
                                        _myProfileData(
                                            "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${postCodeController.text}&customer_businessname=${bNameController.text}",
                                            current_page);
                                      }
                                    } else if (text1) {
                                      _myProfileData(
                                          "page=$current_page&customer_businessname=${bNameController.text}&postcode=${postCodeController.text}",
                                          current_page);

                                      if (text1) {
                                        _myProfileData(
                                            "page=$current_page&postcode=${postCodeController.text}&customer_accountnumber=${accountNoController.text}&customer_businessname=${bNameController.text}",
                                            current_page);
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _loading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  TextStyle normalText6 = GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Color(0xff000000),
      decoration: TextDecoration.underline);

  Widget _contentBuilder(Size deviceSize) {
    if (users.length != 0) {
      return _searchResult.length != 0 || completeController.text.isNotEmpty
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFe3e3e3)),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: Column(children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-customer',
                            arguments: <String, String>{
                              'customer_id':
                                  _searchResult[index].customer_id.toString()
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Edit", style: normalText6),
                              Container(),
                            ],
                          ),
                        ),
                      ),
                      Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: BorderedText(
                              strokeWidth: 1.0,
                              strokeColor: Color(0xfffbefa7),
                              child: Text(
                                  _searchResult[index].customer_businessname,
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
                      Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
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
                                        _searchResult[index].customer_address1 +
                                            ", " +
                                            _searchResult[index]
                                                .customer_address2,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                          image: AssetImage("assets/images/right.png"),
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
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == users.length) {
                      return _buildProgressIndicator();
                    } else {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/add-newjob',
                            arguments: <String, String>{
                              'cust_id': users[index]['customer_id'].toString(),
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 5, top: 7, bottom: 7),
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Color(0xFFe3e3e3)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0))),
                          child: Column(children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit-customer',
                                  arguments: <String, String>{
                                    'customer_id':
                                        users[index]['customer_id'].toString()
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Edit", style: normalText6),
                                    Container(),
                                  ],
                                ),
                              ),
                            ),
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
                                            users[index]
                                                ['customer_businessname'],
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
                                    child: Text(users[index]['postcode'],
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
                                                  users[index]
                                                      ['customer_address1'] +
                                                  ", " +
                                                  users[index]
                                                      ['customer_address2'],
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: normalText2),
                                        ),
                                      ),
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
                    }
                  }),
            );
    } else {
      _emptyOrders();
    }
  }

  Future<void> _pullRefresh() async {
    setState(() {
      page1 = 0;
      isEnabled3 = false;
      isEnabled4 = false;
      postCodeController.text = "";
      bNameController.text = "";
      accountNoController.text = "";
      users.clear();
    });
    _myProfileData("", 1);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextStyle normalTex2 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: Scaffold(
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
              IconButton(
                icon: Image(
                  image: AssetImage("assets/images/refresh.png"),
                  color: Color(0xffb5322f),
                  height: 26.0,
                  width: 26.0,
                ),
                onPressed: () async {
                  setState(() {
                    page1 = 0;
                    isEnabled3 = false;
                    isEnabled4 = false;
                    postCodeController.text = "";
                    bNameController.text = "";
                    accountNoController.text = "";
                    users.clear();
                  });
                  _myProfileData("", 1);
                },
              ),
            ],
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Colors.transparent,
          ),
          body: ModalProgressHUD(
            inAsyncCall: isLoading,
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
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                            color:
                                isEnabled3 ? Color(0xffb5322f) : Colors.white,
                            onPressed: () async {
                              setState(() {
                                isEnabled3 = true;
                                isEnabled4 = false;
                                _sc = null;
                                displayModalBottomSheet(context);
                              });
                            },
                            child: Row(children: [
                              Image(
                                image: AssetImage("assets/images/shortby.png"),
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
                            color:
                                isEnabled4 ? Color(0xffb5322f) : Colors.white,
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
                                color: isEnabled4
                                    ? Colors.white
                                    : Color(0xffb5322f),
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
                        /*     Align(
                              alignment: Alignment.topRight,
                              child:  Text(
                                  "Displaying- "+pageCount.toString()+" of "+totalCount.toString(),
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:normalTex2
                              ),

                            ),*/
                      ]),
                      SizedBox(
                        height: 5.0,
                      ),
                      Expanded(
                          child: ListView(
                              shrinkWrap: true,
                              controller: _sc,
                              children: <Widget>[
                            Center(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                child: _contentBuilder(deviceSize),
                              ),
                            ),
                          ])),
                      // Expanded(child: Container(child: quizList())),
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
                                  blurRadius: 1.0, // soften the shadow
                                  spreadRadius: 1.0, //extend the shadow
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
          )),
    );
  }

  onSearchTextChanged(String text) async {
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
