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

class CreateTip extends StatefulWidget {
  final Object argument;

  const CreateTip({Key key, this.argument}) : super(key: key);

  @override
  _ChangePageState createState() => _ChangePageState();
}

class _ChangePageState extends State<CreateTip> {
  List collections_list = new List();
  final signatoryController = TextEditingController();
  final codeController = TextEditingController();
  final tipTextController = TextEditingController();
  File fileImg;
  File fileImg1;
  var qtyController;
  var actualqtyController;

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
  String _dropdownValue = 'Cash';
  List<XMLJSON> xmlList = new List();
  var dataResponse;
  bool proceed = false;
  bool proceed2 = false;
  String formattedDate1 = "";
  var checklist_id;
  ByteData _img = ByteData(0);
  ByteData _img1 = ByteData(0);
  double _total = 0.0;
  var color1 = Colors.blue;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();
  String formatter = "";
  String tipping_tnc = "";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    collections_list = data['collections_list'];
    print(collections_list);
    final now = new DateTime.now();
    formatter = DateFormat('yMd').format(now); // 28/03/2020
    for (int i = 0; i < collections_list.length; i++) {
      _total = _total +
          (double.parse(collections_list[i]['collection_qty'].toString()));
    }
    qtyController =
        TextEditingController(text: _total.toStringAsFixed(2).toString());
    actualqtyController =
        TextEditingController(text: _total.toStringAsFixed(2).toString());
    _getUser();
  }

  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();
        vehicle_no = prefs.getString('vehicle_no').toString();
        tipping_tnc = prefs.getString('tipping_tnc').toString();
      });
    });
  }

  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText1 = GoogleFonts.montserrat(
      fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xff000000));
  TextStyle normalText2 = GoogleFonts.montserrat(
      fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff000000));
  TextStyle normalText3 = GoogleFonts.montserrat(
      fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff000000));

  Widget quizList() {
    return Column(children: <Widget>[
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin:
            const EdgeInsets.only(right: 10.0, left: 10, bottom: 10, top: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFe3e3e3)),
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        child: Column(children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text("Weight" + "  :- ",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalText1),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: TextFormField(
                        // inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        enabled: false,
                        cursorColor: Color(0xff000000),
                        textCapitalization: TextCapitalization.sentences,
                        /* validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please enter emp code';
                                                    }
                                                    return null;
                                                  },*/
                        onSaved: (String value) {
                          qtyController.text = value;
                        },
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                            hintText: '',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  width: MediaQuery.of(context).size.width * 0.10,
                  child: Text("Kgs",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalText2),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text("Actual Weight" + "  :- ",
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalText1),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: TextFormField(
                        // inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                        controller: actualqtyController,
                        keyboardType: TextInputType.number,
                        // enabled: false,
                        cursorColor: Color(0xff000000),
                        textCapitalization: TextCapitalization.sentences,
                        /* validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please enter emp code';
                                                    }
                                                    return null;
                                                  },*/
                        onSaved: (String value) {
                          actualqtyController.text = value;
                        },
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                            hintText: '',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  width: MediaQuery.of(context).size.width * 0.10,
                  child: Text("Kgs",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalText2),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text("Operation(R or D Code)" + "  :- ",
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalText1),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 15.0, left: 5),
                    child: TextFormField(
                        controller: codeController,
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff000000),
                        textCapitalization: TextCapitalization.sentences,
                        onSaved: (String value) {
                          codeController.text = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter code';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                            hintText: 'Operation Code',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text("Signatory" + "  :- ",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalText1),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 15.0, left: 5),
                    child: TextFormField(
                        controller: signatoryController,
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff000000),
                        textCapitalization: TextCapitalization.sentences,
                        onSaved: (String value) {
                          signatoryController.text = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter signatory name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                            hintText: 'Name of Signatory',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Row(children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text("Notes" + "  :- ",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalText1),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 15.0, left: 5),
                    child: TextFormField(
                        controller: tipTextController,
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff000000),
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 4,
                        // any number you need (It works as the rows for the textarea)
                        // keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onSaved: (String value) {
                          tipTextController.text = value;
                        },
                        /* validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter tipping text';
                          }
                          return null;
                        },*/
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(15, 20, 30, 0),
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
                            hintText: '',
                            hintStyle: TextStyle(
                                color: Color(0xffcdcbcb), fontSize: 16),
                            fillColor: Color(0xffffffff),
                            filled: true)),
                  ),
                )
              ]),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ]),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(right: 10.0, left: 10, bottom: 15),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Color(0xFFe3e3e3)),
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        child: Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: Container(
                child: RichText(
              softWrap: true,
              textAlign: TextAlign.justify,
              text: TextSpan(style: normalText3, text: tipping_tnc),
            )),
          ),
          SizedBox(
            height: 10,
          ),
        ]),
      ),
      SizedBox(
        height: 15.0,
      ),
      InkWell(
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(right: 10.0, left: 10),
            child: Text(
              "Signature",
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
            margin: const EdgeInsets.only(right: 10.0, left: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Signature(
                color: color1,
                key: _sign,
                onSign: () {
                  final sign1 = _sign.currentState;
                  debugPrint('${sign1.points.length} points in the signature');
                },
                strokeWidth: strokeWidth,
              ),
            )),
        InkWell(
          onTap: () {
            final sign = _sign.currentState;
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
                  blurRadius: 0.5, // soften the shadow
                  spreadRadius: 0.5, //extend the shadow
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
              padding:
                  const EdgeInsets.only(top: 2, bottom: 2, left: 20, right: 20),
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
                  var data =
                      await image.toByteData(format: ui.ImageByteFormat.png);
                  final encoded = base64.encode(data.buffer.asUint8List());
                  setState(() {
                    _img = data;
                  });

                  final decodedBytes = base64Decode(encoded);
                  final directory = await getApplicationDocumentsDirectory();
                  fileImg = File('${directory.path}/testImage.png');
                  print(fileImg.path);

                  fileImg.writeAsBytesSync(List.from(decodedBytes));

                  if (sign.points.length != 0) {
                    print(sign.points.length);
                    setState(() {
                      _loading = true;
                    });

                    Map<String, String> headers = {
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $access_token',
                    };
                    final mimeTypeData =
                        lookupMimeType(fileImg.path, headerBytes: [0xFF, 0xD8])
                            .split('/');

                    var uri = Uri.parse(URL + "/tipping/create");
                    print(uri);
                    final uploadRequest = http.MultipartRequest('POST', uri);
                    final file = await http.MultipartFile.fromPath(
                        'tipping_signature', fileImg.path,
                        contentType:
                            MediaType(mimeTypeData[0], mimeTypeData[1]));

                    uploadRequest.headers.addAll(headers);

                    for (int i = 0; i < collections_list.length; i++) {
                      uploadRequest
                              .fields['TippingDetail[$i][job_collection_id]'] =
                          collections_list[i]['id'].toString();
                      uploadRequest.fields['TippingDetail[$i][job_id]'] =
                          collections_list[i]['job_id'].toString();
                      uploadRequest.fields['TippingDetail[$i][qty]'] =
                          collections_list[i]['collection_qty'].toString();
                    }
                    uploadRequest.fields['tipping_text'] =
                        tipTextController.text;
                    uploadRequest.fields['tipping_rdcode'] =
                        codeController.text;
                    uploadRequest.fields['tipping_volume'] =
                        _total.toStringAsFixed(2).toString();
                    uploadRequest.fields['tipping_actual_qty'] =
                        actualqtyController.text;
                    uploadRequest.fields['tipping_signatory'] =
                        signatoryController.text;
                    uploadRequest.files.add(file);
                    print(uploadRequest);

                    try {
                      final streamedResponse = await uploadRequest.send();
                      final response =
                          await http.Response.fromStream(streamedResponse);

                      print("><>>>>>>>>>>>" + response.statusCode.toString());
                      print("><>>>>>>>>>>>" + response.body);
                      var data11 = json.decode(response.body);
                      if (response.statusCode == 201) {
                        setState(() {
                          _loading = false;
                        });

                        Fluttertoast.showToast(
                            msg: ' Tip Created Successfully');
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/collection-list');
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
                        Fluttertoast.showToast(
                            msg: data11['errors'][0]['message'].toString(),
                            toastLength: Toast.LENGTH_SHORT);
                      }
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: "Signature can't be empty",
                        toastLength: Toast.LENGTH_SHORT);
                  }
                } else {
                  setState(() {
                    _autoValidate = true;
                  });
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
        height: 20.0,
      ),
    ]);
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
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/collection-list');
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
                  child: Text('Tip Screen', style: normalText),
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
              margin: EdgeInsets.symmetric(
                horizontal: deviceSize.width * 0.01,
              ),
              child: ListView(children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: const EdgeInsets.only(right: 10.0, left: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Color(0xFFe3e3e3)),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  child: Column(children: <Widget>[
                    Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tip Date", style: normalText1),
                            Text(formatter, style: normalText1)
                          ]),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("EWC Product", style: normalText1),
                            Text("Volume", style: normalText1)
                          ]),
                    ),
                    new Container(
                        child: Divider(
                      color: Colors.black,
                      thickness: 1,
                    )),
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: collections_list.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: Text(
                                        collections_list[index]['product']
                                                ['product_name'] +
                                            " - " +
                                            collections_list[index]['product']
                                                ['product_ewc'],
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: normalText2),
                                  ),
                                  Text(
                                      collections_list[index]['collection_qty']
                                              .toString() +
                                          " Kg",
                                      style: normalText2)
                                ]),
                          );
                        },
                      ),
                    ),
                    new Container(
                        child: Divider(
                      color: Colors.black,
                      thickness: 1,
                    )),
                    Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Volume", style: normalText1),
                            Text(_total.toStringAsFixed(2).toString() + " Kg",
                                style: normalText1)
                          ]),
                    ),
                  ]),
                ),
                Container(
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
