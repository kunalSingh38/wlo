import 'dart:convert';
import 'package:bordered_text/bordered_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:wlo_master/services/shared_preferences.dart';



class Payment extends StatefulWidget {
  final Object argument;

  const Payment({Key key, this.argument}) : super(key: key);

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<Payment> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  var link="";
  num position = 1;
  final key = UniqueKey();
  var _userId;
  Future<dynamic> _contest;
  String job_id="";
  String amount="";
  var access_token="";
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    job_id = data['job_id'];
    amount = data['amount'];
    print("https://webapp.wastelubricatingoils.co.uk/admin/sage?token=96898bb8544fa56b03c08cdc09886c6c&job_id=$job_id&amount=$amount");
    _getUser();
  }
  _getUser() async {
    Preference().getPreferences().then((prefs) {
      setState(() {
        access_token = prefs.getString('access_token').toString();

      });
    });
  }
  TextStyle normalText = GoogleFonts.montserrat(
      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff000000));

  doneLoading(String value) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String value) {
    setState(() {
      position = 1;
    });
  }


  Widget htmlList(Size deviceSize) {

    return IndexedStack(
      index: position,
      children: <Widget>[

      Container(
            margin: EdgeInsets.only(bottom: 10),
            child: WebView(
              initialUrl: "https://webapp.wastelubricatingoils.co.uk/admin/sage?token=96898bb8544fa56b03c08cdc09886c6c&job_id=$job_id&amount=$amount",
              javascriptMode: JavascriptMode.unrestricted,
              key: key,
              onPageFinished: doneLoading,
              onPageStarted: startLoading,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
            ),
          ),



        Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(
          "Are you sure",
        ),
        content: new Text("Do you want to cancel the payment?"),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              "No",
              style: TextStyle(
                color: Color(0xff2E2A4A),
              ),
            ),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
            new Text("Yes", style: TextStyle(color: Color(0xff2E2A4A))),
          ),
        ],
      ),
    )) ??
        false;
  }
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          //resizeToAvoidBottomInset: false,
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
                    child: Text('Payment', style: normalText),
                  ),
                ),
              ]),
            ),
            flexibleSpace: Container(
              height: 100,
              color: Color(0xfffbefa7),
            ),
            actions: <Widget>[

            ],
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Colors.transparent,
          ),
          body: Column(
              children: <Widget>[
                Expanded(child: Container(child: htmlList( deviceSize))),
                Center(
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: Container(
                      child: RaisedButton(
                        splashColor: Color(0xffb5322f),

                        textColor: Color(0xfffbefa7),
                        color: Color(0xffb5322f),
                        onPressed: () async {

                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ]

      )
      ),
    );
  }
}




