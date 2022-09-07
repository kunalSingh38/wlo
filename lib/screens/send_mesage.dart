import 'dart:convert';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wlo_master/constants.dart';

class SendMessage extends StatefulWidget {
  String messageFor;
  String jobId;
  SendMessage({this.messageFor, this.jobId});

  @override
  _SendMessageState createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  List messages = [];

  Future<void> getMessageTemplate() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + pref.getString("access_token").toString(),
    };
    var response = await http.get(
      Uri.parse(URL + "/templates"),
      headers: headers,
    );
    if (jsonDecode(response.body)['status'] == 200) {
      List temp = jsonDecode(response.body)['data'];
      setState(() {
        messages.addAll(temp);
        messages.add({"template_message": "Type your own message", "id": 0});
      });
    }
  }

  TextEditingController customMessage = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessageTemplate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          centerTitle: false,
          title: Text(widget.messageFor.toString(),
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff000000))),
          // flexibleSpace: Container(
          //   height: 100,
          //   color: Color(0xfffbefa7),
          // ),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Color(0xfffbefa7)),
      body: messages.length == 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: messages
                  .map((e) => InkWell(
                        onTap: () {
                          if (e['id'].toString() == "0") {
                            setState(() {
                              customMessage.clear();
                            });
                            showDialog(
                                context: context,
                                barrierColor: Colors.black,
                                builder: (context) => AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          children: [
                                            Container(
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: Color(0xfffbefa7),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5))),
                                                child: Center(
                                                    child: Text(
                                                  "Type Own Message",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red[800]),
                                                ))),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                maxLines: 6,
                                                controller: customMessage,
                                                decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    hintText: "Type your text"),
                                              ),
                                            ),
                                            Center(
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (customMessage.text
                                                            .toString() ==
                                                        "") {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Please enter your message");
                                                    } else {
                                                      showLaoding(context);
                                                      SharedPreferences pref =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      Map<String, String>
                                                          headers = {
                                                        'Content-Type':
                                                            'application/json',
                                                        'Accept':
                                                            'application/json',
                                                        'Authorization': 'Bearer ' +
                                                            pref
                                                                .getString(
                                                                    "access_token")
                                                                .toString(),
                                                      };
                                                      var response = await http.post(
                                                          Uri.parse(URL +
                                                              "/templates/sent/" +
                                                              widget.jobId
                                                                  .toString()),
                                                          headers: headers,
                                                          body: jsonEncode({
                                                            "template_id": null,
                                                            "body":
                                                                customMessage
                                                                    .text
                                                                    .toString()
                                                          }));
                                                      print(response.body);
                                                      if (jsonDecode(response
                                                                  .body)[
                                                              'status'] ==
                                                          201) {
                                                        Fluttertoast.showToast(
                                                            msg: jsonDecode(
                                                                        response
                                                                            .body)[
                                                                    'message']
                                                                .toString(),
                                                            toastLength: Toast
                                                                .LENGTH_LONG);
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg: jsonDecode(
                                                                        response
                                                                            .body)[
                                                                    'message']
                                                                .toString());
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty
                                                          .all(
                                                              RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                      )),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Color(
                                                                  0xffb5322f))),
                                                  child: Text(
                                                    "Send Message",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white),
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                    ));
                          } else {
                            showDialog(
                                context: context,
                                barrierColor: Colors.black,
                                builder: (context) => AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          children: [
                                            Container(
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: Color(0xfffbefa7),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5))),
                                                child: Center(
                                                    child: Text(
                                                  "Send Message",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red[800]),
                                                ))),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                  child: Text(
                                                      e['template_message']
                                                          .toString())),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ButtonStyle(
                                                        shape: MaterialStateProperty
                                                            .all(
                                                                RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      18.0),
                                                        )),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Color(
                                                                    0xffb5322f))),
                                                    child: Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white),
                                                    )),
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      print(e);
                                                      showLaoding(context);
                                                      SharedPreferences pref =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      Map<String, String>
                                                          headers = {
                                                        'Content-Type':
                                                            'application/json',
                                                        'Accept':
                                                            'application/json',
                                                        'Authorization': 'Bearer ' +
                                                            pref
                                                                .getString(
                                                                    "access_token")
                                                                .toString(),
                                                      };
                                                      var response = await http.post(
                                                          Uri.parse(URL +
                                                              "/templates/sent/" +
                                                              widget.jobId
                                                                  .toString()),
                                                          headers: headers,
                                                          body: jsonEncode({
                                                            "template_id":
                                                                e['id']
                                                                    .toString(),
                                                            "body":
                                                                e['template_message']
                                                                    .toString()
                                                          }));
                                                      print(response.body);
                                                      if (jsonDecode(response
                                                                  .body)[
                                                              'status'] ==
                                                          201) {
                                                        Fluttertoast.showToast(
                                                            msg: jsonDecode(
                                                                        response
                                                                            .body)[
                                                                    'message']
                                                                .toString(),
                                                            toastLength: Toast
                                                                .LENGTH_LONG);
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg: jsonDecode(
                                                                        response
                                                                            .body)[
                                                                    'message']
                                                                .toString(),
                                                            toastLength: Toast
                                                                .LENGTH_LONG);
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    style: ButtonStyle(
                                                        shape: MaterialStateProperty
                                                            .all(
                                                                RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      18.0),
                                                        )),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Color(
                                                                    0xffb5322f))),
                                                    child: Text(
                                                      "Send",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                          child: Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(e['template_message'].toString()),
                              trailing:
                                  messages.length - 1 == messages.indexOf(e)
                                      ? Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: Colors.black,
                                        )
                                      : Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.black,
                                        ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
