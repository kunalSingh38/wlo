import 'dart:convert';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wlo_master/constants.dart';
import 'dart:math' as math;

TextStyle normalText = GoogleFonts.montserrat(
    fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff000000));

class InboxMessages extends StatefulWidget {
  @override
  _InboxMessagesState createState() => _InboxMessagesState();
}

class _InboxMessagesState extends State<InboxMessages> {
  TextEditingController searchCont = TextEditingController();

  @override
  List inboxMessages = [];
  bool isLoading = true;

  Future<void> getAllInboxMessages() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + pref.getString('access_token').toString(),
      'Accept': 'application/json',
    };
    var response = await http.get(
      Uri.parse(URL + "/messages"),
      headers: headers,
    );
    if (jsonDecode(response.body)['status'] == 200) {
      setState(() {
        inboxMessages.clear();
        inboxMessages.addAll(jsonDecode(response.body)['data']);

        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllInboxMessages();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                child: Text('Your Inbox', style: normalText),
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
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 30),
              child: TextFormField(
                controller: searchCont,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.all(0),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue),
                      borderRadius: BorderRadius.circular(10)),
                  hintText: "Search for contacts",
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                  prefixIcon: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 35,
                      )),
                ),
              ),
            ),
            Expanded(
                flex: 6,
                child: ListView.separated(
                  itemCount: inboxMessages.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    indent: 20,
                    endIndent: 20,
                    color: Color.fromARGB(255, 105, 12, 5),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullDetailMessage(
                                      m: inboxMessages[index])));
                        },
                        title: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                  inboxMessages[index]['customer']
                                          ['customer_businessname']
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red[800])),
                            ),
                            Expanded(
                                child: Text(
                              inboxMessages[index]['created_at']
                                  .toString()
                                  .replaceAll(" ", "\n"),
                              style: TextStyle(fontSize: 12),
                            ))
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            inboxMessages[index]['message'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ))
          ]),
        ),
      ),
    );
  }
}

class FullDetailMessage extends StatefulWidget {
  Map m = {};
  FullDetailMessage({this.m});

  @override
  _FullDetailMessageState createState() => _FullDetailMessageState();
}

class _FullDetailMessageState extends State<FullDetailMessage> {
  List messages = [];
  bool isLoading = true;
  Map customerDetails = {};

  TextEditingController customMessage = TextEditingController();

  Future<void> getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + pref.getString('access_token').toString(),
      'Accept': 'application/json',
    };
    var response = await http.get(
      Uri.parse(
          URL + "/messages/customer/" + widget.m['customer_id'].toString()),
      headers: headers,
    );
    print(URL + "/messages/customer/" + widget.m['customer_id'].toString());
    if (jsonDecode(response.body)['status'] == 200) {
      setState(() {
        messages.clear();
        messages.addAll(jsonDecode(response.body)['data']['messages']);
        customerDetails = jsonDecode(response.body)['data']['customer'];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        title: FittedBox(
          child: Text(
            widget.m['customer']['customer_businessname'].toString(),
          ),
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
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(
                      indent: 20,
                      endIndent: 20,
                      color: Color.fromARGB(255, 105, 12, 5),
                    ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Color(int.parse(messages[index]['event']['color']
                        .toString()
                        .replaceAll("#", "0xFF"))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messages[index]['event']['object']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.red[800],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  messages[index]['event']['resource']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      // color: Color(int.parse(
                                      //     messages[index]['event']['color']))
                                      color: Colors.black),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "DATE",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.red[800]),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  DateFormat.yMMMMd("en_US").add_jm().format(
                                      DateTime.parse(messages[index]
                                              ['created_at']
                                          .toString())),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      // color: Color(int.parse(
                                      //     messages[index]['event']['color']))
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messages[index]['message'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    // color: Color(int.parse(
                                    //     messages[index]['event']['color']))
                                    color: Colors.black),
                              ),
                              InkWell(
                                onTap: () {
                                  print(customerDetails);
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            contentPadding: EdgeInsets.zero,
                                            content: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Column(
                                                children: [
                                                  Container(
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xfffbefa7),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Center(
                                                          child: Text(
                                                        "Type Own Message",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .red[800]),
                                                      ))),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      maxLines: 6,
                                                      controller: customMessage,
                                                      decoration: InputDecoration(
                                                          fillColor:
                                                              Colors.white,
                                                          filled: true,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          hintText:
                                                              "Type your text"),
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
                                                            showLaoding(
                                                                context);
                                                            SharedPreferences
                                                                pref =
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
                                                            var response =
                                                                await http.post(
                                                                    Uri.parse(URL +
                                                                        "/message/create"),
                                                                    headers:
                                                                        headers,
                                                                    body:
                                                                        jsonEncode({
                                                                      "customer_id":
                                                                          customerDetails['customer_id']
                                                                              .toString(),
                                                                      "event_id":
                                                                          messages[index]['event_id']
                                                                              .toString(),
                                                                      "event":
                                                                          "job.create",
                                                                      "message": customMessage
                                                                          .text
                                                                          .toString()
                                                                    }));
                                                            print(
                                                                response.body);
                                                            if (jsonDecode(response
                                                                        .body)[
                                                                    'status'] ==
                                                                201) {
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          "Message sent successfully");
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              getData();
                                                            }
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
                                                          "Send Message",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ));
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      color: Colors.red[800],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Transform(
                                            alignment: Alignment.center,
                                            transform:
                                                Matrix4.rotationY(math.pi),
                                            child: Icon(
                                              Icons.reply_all_outlined,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          )),
    );
  }
}
