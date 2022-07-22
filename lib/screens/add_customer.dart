import 'dart:async';
import 'dart:convert';
import 'package:bordered_text/bordered_text.dart';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';

import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

class AddCustomers extends StatefulWidget {
  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<AddCustomers> {
  Future<dynamic> _sicList;
  final businessNameController = TextEditingController();
  final groupAccountCodeController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final address3Controller = TextEditingController();
  final postCodeController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();
  final pMobileController = TextEditingController();
  final pEmailController = TextEditingController();
  final pPhoneController = TextEditingController();
  var aMobileController = TextEditingController();
  var aEmailController = TextEditingController();
  var aPhoneController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var access_token;
  List<int> arr;
  String vehicle_no = '';
  int id;

  int sent_id;

  bool valuefirst = false;
  final completeController = TextEditingController();
  List<TextEditingController> _controllers = new List();
  String job_id;
  String _dropdownValue = 'Cash';
  String name = "Cash";
  bool isEnabled1 = true;
  String selectedDealer = "";
  bool isEnabled2 = false;
  bool isEnabled3 = false;
  bool isEnabled4 = false;
  List<Region> _region = [];
  List<City> _city = [];
  Future _productData;
  String catData = "";
  String cityData = "";
  String selectedRegion;
  String default_value = "";
  String selectedCity;
  var _type = "";
  var _type1 = "";
  String radioButtonItem = "Payment On Collection";
  String latDouble;
  String longDouble;

  bool enable = false;

  Map<String, String> selectedValueMap = Map();
  @override
  void initState() {
    super.initState();
    selectedValueMap["server"] = null;
    _getUser();
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        _sicList = _sicListData();
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

  var result;
  List<String> cities = [];
  List<String> cities1 = [];
  Map<String, dynamic> formData = new Map();

  Future _sicListData() async {
    setState(() {
      _loading = true;
    });
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/sics"),
      headers: headers,
    );
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      result = data['data'];
      if (mounted) {
        setState(() {
          for (int i = 0; i < result.length; i++) {
            if (result[i]['is_default'] == "Yes") {
              default_value = result[i]['sic_name'] +
                  " - " +
                  result[i]['sic_code'].toString();
              selectedDealer = result[i]['sic_id'].toString();
            }
            cities.add(result[i]['sic_name'].toString() +
                " - " +
                result[i]['sic_code'].toString());
            cities1.add(result[i]['sic_id'].toString());
            formData = result[i];
          }
        });
      }
      _getParentAccount();
      return data;
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
        _loading = false;
      });
      throw Exception('Something went wrong');
    }
  }

  Future _getParentAccount() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/customer/parent-accounts"),
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
                _type1 = map.THIRD_LEVEL_ID;

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
      _getZoneAccount();
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _getZoneAccount() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.get(
      Uri.parse(URL + "/zones"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['data'];
      print(result);
      if (mounted) {
        setState(() {
          cityData = jsonEncode(result);

          final json = JsonDecoder().convert(cityData);
          _city = (json).map<City>((item) => City.fromJson(item)).toList();
          List<String> item = _city.map((City map) {
            for (int i = 0; i < _city.length; i++) {
              if (selectedCity == map.FOURTH_LEVEL_NAME) {
                _type = map.FOURTH_LEVEL_ID;

                print(selectedCity);
                return map.FOURTH_LEVEL_ID;
              }
            }
          }).toList();
          if (selectedCity == "") {
            selectedCity = _city[0].FOURTH_LEVEL_NAME;
          }
        });
      }

      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _getAccount(String businessName, String postCode) async {
    setState(() {
      _loading = true;
    });
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var response = await http.post(
      Uri.parse(URL + "/customer/generate-account-number"),
      body: {
        "customer_businessname": businessName,
        "customer_parentaccount": postCode
      },
      headers: headers,
    );
    var data = json.decode(response.body);
    if (response.statusCode == 201) {
      setState(() {
        _loading = false;
      });
      var result = data['data'];
      print(result);
      if (response.statusCode == 201) {
        setState(() {
          groupAccountCodeController.text =
              data['data']['customer_accountnumber'].toString();
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
      } else {
        setState(() {
          _loading = false;
        });
        var errorMessage = data['errors'][0]['message'];
        showAlertDialog(context, ALERT_DIALOG_TITLE, errorMessage);
      }

      return result;
    } else {
      setState(() {
        _loading = false;
      });
      print(data);
      throw Exception('Something went wrong');
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

  Widget _radioBuilder() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                CustomRadioWidget(
                  value: 1,
                  groupValue: id,
                  groupName: "Payment On Collection",
                  onChanged: (val) {
                    setState(() {
                      id = 1;
                      sent_id = 0;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                CustomRadioWidget(
                  value: 2,
                  groupValue: id,
                  // focusColor: Color(0xFFe7bf2e),
                  groupName: "On Account",
                  onChanged: (val) {
                    setState(() {
                      id = 2;
                      sent_id = 1;
                    });
                  },
                ),
              ])),
    );
  }

  Widget getSearchableDropdown(List<String> listData, mapKey) {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < listData.length; i++) {
      items.add(new DropdownMenuItem(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: Colors.transparent,
          ),
          child: new Text(
            listData[i],
          ),
        ),
        value: listData[i],
      ));
    }
    return new SearchableDropdown.single(
      items: items,
      value: selectedValueMap[mapKey].toString(),
      // clearIcon: Icon(Icons.clear),
      icon: Icon(
        Icons.keyboard_arrow_down_outlined,
        color: Colors.black,
        size: 20,
      ),
      underline: SizedBox.shrink(),
      isCaseSensitiveSearch: false,
      displayClearIcon: false,
      label: default_value,
      style: TextStyle(color: Colors.black, fontSize: 20),
      // hint: Container(
      //   padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(10),
      //       bottomLeft: Radius.circular(10),
      //       topRight: Radius.circular(10),
      //       bottomRight: Radius.circular(10),
      //     ),
      //     color: Colors.white,
      //   ),
      //   child: new Text(
      //     default_value,
      //     style: TextStyle(color: Colors.black, fontSize: 16),
      //   ),
      // ),
      searchHint: new Text(
        'Select',
        style: new TextStyle(fontSize: 20),
      ),
      isExpanded: true,
      selectedValueWidgetFn: (item) {
        return (Container(
          child: Container(
              child: Text(
            item.toString(),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          )),
        ));
      },
      onChanged: (value) {
        for (int i = 0; i < cities.length; i++) {
          if (value == cities[i]) {
            setState(() {
              selectedDealer = cities1[i];
              default_value = cities[i].toString();
            });
          }
        }
        print(selectedDealer);
      },
    );
  }

  Widget quizList(Size deviceSize, RegExp regex) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: deviceSize.width * 0.05,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: businessNameController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
                onSaved: (String value) {
                  businessNameController.text = value;
                },
                onChanged: (String value) {
                  if (value.length > 3) {
                    _getAccount(businessNameController.text, _type);
                    print(_type);
                  }
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
                    hintText: 'Business Name',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: groupAccountCodeController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                onSaved: (String value) {
                  groupAccountCodeController.text = value;
                },
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
                    hintText: 'Account Number',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
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
                    "Select Parent Account ",
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
                      _getAccount(businessNameController.text, _type);
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
          const SizedBox(height: 15.0),
          Row(children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: TextFormField(
                    controller: postCodeController,
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff000000),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter postcode';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      postCodeController.text = value;
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
                        hintText: 'Postcode',
                        hintStyle:
                            TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
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
                    onTap: () async {
                      if (postCodeController.text != "") {
                        setState(() {
                          _loading = true;
                        });
                        Map<String, String> headers = {
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $access_token',
                        };
                        var response = await http.post(
                          Uri.parse(URL + "/postcode/look-up"),
                          body: {"postcode": postCodeController.text},
                          headers: headers,
                        );
                        print({"postcode": postCodeController.text});
                        var data = json.decode(response.body);
                        print(data);
                        if (response.statusCode == 201) {
                          setState(() {
                            _loading = false;
                          });
                          setState(() {
                            enable = true;
                            postCodeController.text =
                                data['data']['postcode'].toString();
                            address1Controller.text =
                                data['data']['address1'].toString();
                            address2Controller.text =
                                data['data']['address2'].toString();
                            address3Controller.text =
                                data['data']['address3'].toString();
                            /*  latController.text =
                                data['data']['latitude'].toString();
                            longController.text =
                                data['data']['longitude'].toString();*/
                            latDouble = data['data']['latitude'].toString();
                            longDouble = data['data']['longitude'].toString();
                          });
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
                        } else {
                          setState(() {
                            _loading = false;
                            postCodeController.text = "";
                          });
                          var errorMessage = data['errors'][0]['message'];
                          showAlertDialog(
                              context, ALERT_DIALOG_TITLE, errorMessage);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please enter post code",
                            toastLength: Toast.LENGTH_SHORT);
                      }
                    },
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
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: address1Controller,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter first address';
                  }
                  return null;
                },
                onSaved: (String value) {
                  address1Controller.text = value;
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
                    hintText: 'Enter Address1',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: address2Controller,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.words,
                /* validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter second address';
                  }
                  return null;
                },*/
                onSaved: (String value) {
                  address2Controller.text = value;
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
                    hintText: 'Address2',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: address3Controller,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.words,
                onSaved: (String value) {
                  address3Controller.text = value;
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
                    hintText: 'Address3',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: pEmailController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                /* validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter primary consignment email';
                  } else if (!regex.hasMatch(value.trim())) {
                    return "Enter valid primary email";
                  }
                  return null;
                },*/
                onSaved: (String value) {
                  pEmailController.text = value;
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
                    hintText: 'Primary Consignment Email',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: pMobileController,
                // maxLength: 10,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter primary contact';
                  }
                  /* else if (value.length < 10) {
                      return 'Please enter 10 digit mobile number';
                    } else if (value.length > 10) {
                      return 'Please enter 10 digit mobile number';
                    }*/
                  return null;
                },
                onSaved: (String value) {
                  pMobileController.text = value;
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
                    hintText: 'Primary Contact',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: pPhoneController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter primary phone no.';
                  }

                  return null;
                },
                onSaved: (String value) {
                  pPhoneController.text = value;
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
                    hintText: 'Primary Phone',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          InkWell(
            onTap: () {
              setState(() {
                String value1 = "";
                String value2 = "";
                String value3 = "";

                value1 = pPhoneController.text;
                value2 = pEmailController.text;
                value3 = pMobileController.text;

                aPhoneController = TextEditingController(text: value1);
                aEmailController = TextEditingController(text: value2);
                aMobileController = TextEditingController(text: value3);
              });
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.only(right: 8.0, left: 8),
                child: Text("Copy primary values",
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: normalTex2),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: aEmailController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                onSaved: (String value) {
                  aEmailController.text = value;
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
                    hintText: 'Accounts Email',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: aMobileController,
                //  maxLength: 10,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                onSaved: (String value) {
                  aMobileController.text = value;
                },
                /* validator: (value) {
                    if (value.length < 10) {
                      return 'Please enter 10 digit mobile number';
                    } else if (value.length > 10) {
                      return 'Please enter 10 digit mobile number';
                    }
                    return null;
                  },*/
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
                    hintText: 'Accounts Contact',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
          Container(
            margin: const EdgeInsets.only(right: 8.0, left: 8),
            child: TextFormField(
                controller: aPhoneController,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xff000000),
                textCapitalization: TextCapitalization.sentences,
                onSaved: (String value) {
                  aPhoneController.text = value;
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
                    hintText: 'Accounts Phone',
                    hintStyle:
                        TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                    fillColor: Color(0xffffffff),
                    filled: true)),
          ),
          const SizedBox(height: 15.0),
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
                    "Select Zone ",
                    style: TextStyle(color: Color(0xffcdcbcb), fontSize: 16),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                  value: selectedCity,
                  isDense: true,
                  autofocus: true,
                  onChanged: (String newValue) {
                    setState(() {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      selectedCity = newValue;
                      List<String> item = _city.map((City map) {
                        for (int i = 0; i < _city.length; i++) {
                          if (selectedCity == map.FOURTH_LEVEL_NAME) {
                            _type1 = map.FOURTH_LEVEL_ID;
                            return map.FOURTH_LEVEL_ID;
                          }
                        }
                      }).toList();
                    });
                  },
                  items: _city.map((City map) {
                    return new DropdownMenuItem<String>(
                      value: map.FOURTH_LEVEL_NAME,
                      child: new Text(map.FOURTH_LEVEL_NAME,
                          style: new TextStyle(
                              color: Color(0xff000000), fontSize: 16)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15.0),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                "Account Type",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xffb5322f),
                  fontSize: 14,
                  //  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          _radioBuilder(),
          const SizedBox(height: 15.0),
          // TextFormField(
          //   maxLines: 3,
          //   decoration: InputDecoration(
          //     hintText: default_value,
          //     border: OutlineInputBorder(),
          //     suffixIcon: InkWell(
          //       child: Icon(Icons.arrow_downward),
          //       onTap: () {

          //       },
          //     ),
          //   ),
          // ),
          Card(child: ListTile(title: getSearchableDropdown(cities, "local"))),
          // Container(
          //   decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius:
          //           const BorderRadius.all(const Radius.circular(25.0)),
          //       border: Border.all(
          //         color: Color(0xffcdcbcb),
          //       )),
          //   margin: const EdgeInsets.only(right: 8.0, left: 8),
          //   child: getSearchableDropdown(cities, "local"),
          // ),

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
                  boxShadow: [
                    //background color of box
                    BoxShadow(
                      color: Color(0xfffbefa7),
                      blurRadius: 0.2, // soften the shadow
                      spreadRadius: 0.2, //extend the shadow
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
                  color: enable ? Color(0xfffbefa7) : Colors.grey.shade200,
                  onPressed: () async {
                    print(sent_id);
                    if (enable) {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        if (selectedDealer != "") {
                          if (sent_id != null) {
                            setState(() {
                              _loading = true;
                            });
                            Map<String, String> headers = {
                              'Accept': 'application/json',
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $access_token',
                            };
                            /*print(jsonEncode({
                              "sic_id": int.parse(selectedDealer),
                              "customer_parentaccount":
                              _type != "" ? int.parse(_type) : null,
                              "customer_businessname":
                              businessNameController.text,
                              "customer_groupaccountcode":
                              groupAccountCodeController.text,
                              "customer_address1": address1Controller.text,
                              "customer_address2": address2Controller.text,
                              "customer_address3": address3Controller.text,
                              "postcode": postCodeController.text,
                              "zone_id":_type1==""?null: int.parse(_type1),
                              "customer_lat": double.parse(latDouble),
                              "customer_lng": double.parse(longDouble),
                              "customer_primarycontact": pMobileController.text,
                              "customer_primarycontactemail":
                              pEmailController.text,
                              "customer_primaryphone": pPhoneController.text,
                              "customer_accountcontact": aMobileController.text,
                              "customer_accountemail": aEmailController.text,
                              "customer_accountphone": aPhoneController.text,
                              "customer_accounttype": sent_id,
                            }));*/
                            var response = await http.post(
                              Uri.parse(URL + "/customer/create"),
                              body: _type1 == ""
                                  ? jsonEncode({
                                      "sic_id": int.parse(selectedDealer),
                                      "customer_parentaccount":
                                          _type != "" ? int.parse(_type) : null,
                                      "customer_businessname":
                                          businessNameController.text,
                                      "customer_groupaccountcode":
                                          groupAccountCodeController.text,
                                      "customer_address1":
                                          address1Controller.text,
                                      "customer_address2":
                                          address2Controller.text,
                                      "customer_address3":
                                          address3Controller.text,
                                      "postcode": postCodeController.text,
                                      "customer_lat": double.parse(latDouble),
                                      "customer_lng": double.parse(longDouble),
                                      "customer_primarycontact":
                                          pMobileController.text,
                                      "customer_primarycontactemail":
                                          pEmailController.text,
                                      "customer_primaryphone":
                                          pPhoneController.text,
                                      "customer_accountcontact":
                                          aMobileController.text,
                                      "customer_accountemail":
                                          aEmailController.text,
                                      "customer_accountphone":
                                          aPhoneController.text,
                                      "customer_accounttype": sent_id,
                                    })
                                  : jsonEncode({
                                      "sic_id": int.parse(selectedDealer),
                                      "customer_parentaccount":
                                          _type != "" ? int.parse(_type) : null,
                                      "customer_businessname":
                                          businessNameController.text,
                                      "customer_groupaccountcode":
                                          groupAccountCodeController.text,
                                      "customer_address1":
                                          address1Controller.text,
                                      "customer_address2":
                                          address2Controller.text,
                                      "customer_address3":
                                          address3Controller.text,
                                      "postcode": postCodeController.text,
                                      "zone_id": int.parse(_type1),
                                      "customer_lat": double.parse(latDouble),
                                      "customer_lng": double.parse(longDouble),
                                      "customer_primarycontact":
                                          pMobileController.text,
                                      "customer_primarycontactemail":
                                          pEmailController.text,
                                      "customer_primaryphone":
                                          pPhoneController.text,
                                      "customer_accountcontact":
                                          aMobileController.text,
                                      "customer_accountemail":
                                          aEmailController.text,
                                      "customer_accountphone":
                                          aPhoneController.text,
                                      "customer_accounttype": sent_id,
                                    }),
                              headers: headers,
                            );

                            var data = json.decode(response.body);
                            print(data);
                            if (response.statusCode == 201) {
                              setState(() {
                                _loading = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Customer created successfully",
                                  toastLength: Toast.LENGTH_SHORT);

                              Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(
                                  context, '/customer-pagination');
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
                            } else {
                              setState(() {
                                _loading = false;
                              });
                              var errorMessage = data['errors'][0]['message'];
                              showAlertDialog(
                                  context, ALERT_DIALOG_TITLE, errorMessage);
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please select account type",
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please Select Sic",
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      } else {
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
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
                  child: Text("Add New Customer", style: normalText),
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
          child: ListView(children: <Widget>[
            Container(
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(child: quizList(deviceSize, regex)),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                )),
              ),
            ),
          ]),
        ));
  }
}

class Region {
  final String THIRD_LEVEL_ID;
  final String THIRD_LEVEL_NAME;

  Region({this.THIRD_LEVEL_ID, this.THIRD_LEVEL_NAME});

  factory Region.fromJson(Map<String, dynamic> json) {
    return new Region(
        THIRD_LEVEL_ID: json['customer_id'].toString(),
        THIRD_LEVEL_NAME: json['business_name']);
  }
}

class City {
  final String FOURTH_LEVEL_ID;
  final String FOURTH_LEVEL_NAME;

  City({this.FOURTH_LEVEL_ID, this.FOURTH_LEVEL_NAME});

  factory City.fromJson(Map<String, dynamic> json) {
    return new City(
        FOURTH_LEVEL_ID: json['zone_id'].toString(),
        FOURTH_LEVEL_NAME: json['zone_name']);
  }
}
