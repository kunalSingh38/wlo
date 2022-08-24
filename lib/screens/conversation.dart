// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wlo_master/constants.dart';

class Conversation extends StatefulWidget {
  String jobId;
  String jobName;
  Conversation({this.jobId, this.jobName});
  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  bool isLoading = true;
  Map chat = {};
  List conversion = [];
  String customer_id;

  Future<void> getChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(URL + "/messages/job/" + widget.jobId.toString()),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + prefs.getString('access_token').toString(),
      },
    );
    setState(() {
      isLoading = false;
    });
    print(response.body);
    if (jsonDecode(response.body)["status"] == 200) {
      setState(() {
        conversion.clear();
        conversion.addAll(jsonDecode(response.body)["data"]["messages"]);
        customer_id = jsonDecode(response.body)["data"]["customer"]
                ["customer_id"]
            .toString();
      });
    }
  }

  TextEditingController message = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: true,
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
        title: FittedBox(child: Text(widget.jobName.toString())),
        flexibleSpace: Container(
          height: 100,
          color: Color(0xfffbefa7),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: ListView(
              reverse: true,
              scrollDirection: Axis.vertical,
              // padding:EdgeInsets.only(
              //     bottom: MediaQuery.of(context).size.height / 2.2),
              children: conversion.reversed
                  .map((e) => Column(
                        children: [
                          Align(
                            alignment: e['ping'].toString() == "outbound-api"
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                              child: Container(
                                decoration: BoxDecoration(
                                    color:
                                        e['ping'].toString() == "outbound-api"
                                            ? Colors.green[500]
                                            : Colors.grey[200],
                                    borderRadius: e['ping'].toString() ==
                                            "outbound-api"
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(0))
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(10))),
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    e['message'].toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2, right: 8),
                            child: Align(
                                alignment:
                                    e['ping'].toString() == "outbound-api"
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Text(
                                    DateFormat.jm().add_yMMMMd().format(
                                        DateTime.parse(e['created_at'])),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10))),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      bottomSheet: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0), topRight: Radius.circular(0)),
        child: Container(
          color: Colors.grey[300],
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
                controller: message,
                // scrollPadding: EdgeInsets.only(bottom: 60),
                decoration: InputDecoration(
                    suffixIcon: TextButton(
                      child: Text(
                        "SEND",
                        style: TextStyle(color: Colors.green),
                      ),
                      style: ButtonStyle(),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();

                        Map<String, String> headers = {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          'Authorization': 'Bearer ' +
                              pref.getString("access_token").toString(),
                        };
                        var response =
                            await http.post(Uri.parse(URL + "/message/create"),
                                headers: headers,
                                body: jsonEncode({
                                  "customer_id": customer_id.toString(),
                                  "event_id": widget.jobId.toString(),
                                  "event": "job.create",
                                  "message": message.text.toString()
                                }));
                        print(response.body);
                        setState(() {
                          isLoading = false;
                        });
                        if (jsonDecode(response.body)["status"] == 201) {
                          getChat();
                          setState(() {
                            message.clear();
                          });
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)))),
          ),
        ),
      ),
    );
  }
}
