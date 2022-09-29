import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:http_parser/http_parser.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as I;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:super_tooltip/super_tooltip.dart';

import 'package:wlo_master/components/CustomRadioWidget.dart';
import 'package:wlo_master/components/general.dart';
import 'package:wlo_master/models/xml_json.dart';
import 'package:wlo_master/services/shared_preferences.dart';

import '../constants.dart';

const directoryName = 'Signature';

class VehicleSingleChecklist extends StatefulWidget {
  final Object argument;

  const VehicleSingleChecklist({Key key, this.argument}) : super(key: key);

  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<VehicleSingleChecklist> {
  Future<dynamic> _checkList;
  final rectifiedController = TextEditingController();
  final remarksController = TextEditingController();
  File fileImg;
  File fileImg1;

  Future<File> f;
  bool _loading = false;
  var access_token;
  int arr;
  String vehicle_no;
  int id = 0;
  bool valuefirst = false;
  final completeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  List<XMLJSON> xmlList = new List();
  var dataResponse;
  final _controllers = TextEditingController();
  bool proceed = false;
  bool proceed2 = false;
  String formattedDate1 = "";
  var checklist_id;
  ByteData _img = ByteData(0);
  ByteData _img1 = ByteData(0);
  var color = Colors.red;
  var color1 = Colors.blue;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();
  final _sign2 = GlobalKey<SignatureState>();

  String status;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    checklist_id = data['checklist_id'];
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

  void writeFile(String encoded, String encoded1) async {}

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));

  Future _checkListData() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    var uri = Uri.parse(URL + '/vehicle-check-list/$checklist_id');
    var response = await http.get(
      uri,
      headers: headers,
    );
    dataResponse = json.decode(response.body);
    print(dataResponse);

    if (response.statusCode == 200) {
      if (dataResponse['data']['status'] == "Pass") {
        setState(() {
          arr = 1;
          status = "Pass";
        });
      } else {
        setState(() {
          arr = 2;
          status = "Fail";
          // _controllers = TextEditingController(text: dataResponse['data']['failed_reason']);
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
        style: TextStyle(fontSize: 20, letterSpacing: 1, color: Colors.white),
      )),
    );
  }

  Widget _radioBuilder() {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Row(children: <Widget>[
          CustomRadioWidget(
            value: 1,
            groupValue: arr,
            groupName: "Pass",
            onChanged: (val) {
              print("value is $val");
              setState(() {
                arr = 1;
                status = "Pass";
              });
            },
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: CustomRadioWidget(
              value: 2,
              groupValue: arr,
              // focusColor: Color(0xFFe7bf2e),
              groupName: "Fail",
              onChanged: (val) {
                setState(() {
                  arr = 2;
                  status = "Fail";
                });
                //  selectedRadio(val, index);
              },
            ),
          ),
        ]));
  }

  selectedRadio(int val, int ind) {
    setState(() {
      arr = val;
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
      right: 20.0,
      left: 100.0,
      maxHeight: 200,
      minHeight: 200,
      arrowLength: 0,
      showCloseButton: ShowCloseButton.inside,
      hasShadow: false,
      content: new Material(
          child: Padding(
        padding: const EdgeInsets.only(top: 20),
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
                return Column(children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '1. ',
                            textAlign: TextAlign.left,
                            style: normalText1,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            response['checklist']['checklist_name'],
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
                            onTap(response['checklist']['checklist_desc']);
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
                  _radioBuilder(),
                  SizedBox(
                    height: 10,
                  ),
                  arr == 2
                      ? Container(
                          margin: const EdgeInsets.only(right: 30.0, left: 8),
                          child: TextFormField(
                              initialValue: response['failed_reason'],
                              keyboardType: TextInputType.text,
                              cursorColor: Color(0xff000000),
                              textCapitalization: TextCapitalization.sentences,
                              onSaved: (String value) {
                                _controllers.text = value;
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
                                  hintText: 'What is Reason?',
                                  hintStyle: TextStyle(
                                      color: Color(0xffcdcbcb), fontSize: 16),
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
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 30.0, left: 8),
                    child: TextFormField(
                        controller: rectifiedController,
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff000000),
                        textCapitalization: TextCapitalization.sentences,
                        onSaved: (String value) {
                          rectifiedController.text = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter remarks';
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
                            hintText: 'Rectify by',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(right: 15.0, left: 15),
                      child: Text(
                        "Driver Signature",
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: normalText1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Stack(children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(right: 15.0, left: 15),
                        height: 200,
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Signature(
                            color: color1,
                            key: _sign,
                            onSign: () {
                              final sign = _sign.currentState;
                              debugPrint(
                                  '${sign.points.length} points in the signature');
                            },
                            strokeWidth: strokeWidth,
                          ),
                        )),
                    InkWell(
                      onTap: () {
                        final sign = _sign.currentState;
                        sign.clear();
                        setState(() {
                          _img = ByteData(0);
                        });
                        debugPrint("cleared");
                      },
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 20.0, top: 5),
                            child: Text("Clear",
                                style: TextStyle(color: Color(0xffb5322f))),
                          )),
                    )
                  ]),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 15.0, left: 15),
                    child: TextFormField(
                        controller: remarksController,
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff000000),
                        minLines: 6,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSaved: (String value) {
                          remarksController.text = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter remarks';
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
                            hintText: 'Remarks',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(right: 15.0, left: 15),
                        child: Text(
                          "Rectified Signature",
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          style: normalText1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Stack(children: <Widget>[
                    Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.only(right: 15.0, left: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Signature(
                            color: color,
                            key: _sign2,
                            onSign: () {
                              final sign1 = _sign2.currentState;
                              debugPrint(
                                  '${sign1.points.length} points in the signature');
                            },
                            strokeWidth: strokeWidth,
                          ),
                        )),
                    InkWell(
                      onTap: () {
                        final sign = _sign2.currentState;
                        sign.clear();
                        setState(() {
                          _img1 = ByteData(0);
                        });
                        debugPrint("cleared");
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            margin: const EdgeInsets.only(right: 20.0, top: 5),
                            child: Text(
                              "Clear",
                              style: TextStyle(color: Color(0xffb5322f)),
                            )),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: 30,
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
                                0.0,
                                // Move to right 10  horizontally
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

                              final sign = _sign.currentState;
                              //retrieve image data, do whatever you want with it (send to server, save locally...)
                              final image = await sign.getData();
                              var data = await image.toByteData(
                                  format: ui.ImageByteFormat.png);
                              final encoded =
                                  base64.encode(data.buffer.asUint8List());
                              setState(() {
                                _img = data;
                              });
                              //debugPrint("onPressed " + encoded);

                              final sign1 = _sign2.currentState;
                              //retrieve image data, do whatever you want with it (send to server, save locally...)
                              final image1 = await sign1.getData();
                              var data1 = await image1.toByteData(
                                  format: ui.ImageByteFormat.png);
                              final encoded1 =
                                  base64.encode(data1.buffer.asUint8List());
                              setState(() {
                                _img1 = data;
                              });
                              // log("onPressed " + encoded);
                              final decodedBytes = base64Decode(encoded);
                              final decodedBytes1 = base64Decode(encoded1);
                              final directory =
                                  await getApplicationDocumentsDirectory();
                              fileImg = File('${directory.path}/testImage.png');
                              fileImg1 =
                                  File('${directory.path}/testImage1.png');
                              print(fileImg.path);
                              print(fileImg1.path);
                              fileImg.writeAsBytesSync(List.from(decodedBytes));
                              fileImg1
                                  .writeAsBytesSync(List.from(decodedBytes1));

                              if (sign.points.length != 0 &&
                                  sign1.points.length != 0) {
                                print(sign.points.length);
                                print(sign1.points.length);
                                setState(() {
                                  _loading = true;
                                });

                                Map<String, String> headers = {
                                  'Accept': 'application/json',
                                  'Authorization': 'Bearer $access_token',
                                };
                                final mimeTypeData = lookupMimeType(
                                    fileImg.path,
                                    headerBytes: [0xFF, 0xD8]).split('/');
                                final mimeTypeData1 = lookupMimeType(
                                    fileImg1.path,
                                    headerBytes: [0xFF, 0xD8]).split('/');

                                var uri = Uri.parse(URL +
                                    "/vehicle-check-list/" +
                                    checklist_id +
                                    "/update");
                                print(uri);
                                final uploadRequest =
                                    http.MultipartRequest('PUT', uri);
                                final file = await http.MultipartFile.fromPath(
                                    'driver_signature', fileImg.path,
                                    contentType: MediaType(
                                        mimeTypeData[0], mimeTypeData[1]));
                                final file1 = await http.MultipartFile.fromPath(
                                    'rectified_signature', fileImg1.path,
                                    contentType: MediaType(
                                        mimeTypeData1[0], mimeTypeData1[1]));

                                uploadRequest.headers.addAll(headers);
                                /* uploadRequest.fields['vehicle_id'] =
                                      vehicle_no;*/
                                uploadRequest.fields['status'] = status;
                                uploadRequest.fields['failed_reason'] =
                                    _controllers.text;
                                uploadRequest.fields['remarks'] =
                                    remarksController.text;
                                uploadRequest.fields['rectified_by'] =
                                    rectifiedController.text;
                                uploadRequest.files.add(file);
                                uploadRequest.files.add(file1);

                                final streamedResponse =
                                    await uploadRequest.send();
                                final response = await http.Response.fromStream(
                                    streamedResponse);

                                try {
                                  print("><>>>>>>>>>>>" +
                                      response.statusCode.toString());
                                  print("><>>>>>>>>>>>" + response.body);
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      _loading = false;
                                    });
                                    var data = json.decode(response.body);
                                    Fluttertoast.showToast(
                                        msg: 'Updated Successfully');
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(
                                      context,
                                      '/view-checklist',
                                    );
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
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
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
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  } else {
                                    setState(() {
                                      _loading = false;
                                    });
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Signatures can't be empty",
                                    toastLength: Toast.LENGTH_SHORT);
                              }
                            } else {
                              setState(() {
                                _autoValidate = true;
                              });
                            }
                          },
                          child: Text(
                            "Update",
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
                ]);
              } else {
                return _emptyOrders();
              }
            } else {
              return Text("No DAta");
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
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Container(
              child: ListView(children: <Widget>[
                Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: deviceSize.width * 0.03,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(child: quizList()),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    )),
              ]),
            ),
          ),
        ));
  }
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8,
        Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WatermarkPaint &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}
