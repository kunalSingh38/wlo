import 'package:flutter/material.dart';

const String ALERT_DIALOG_TITLE = "Alert";
const String BASE_URL = "wloapp.crowdrcrm.com";
// const String BASE_URL = "webapp.wastelubricatingoils.co.uk";
const String API_PATH = "/v1";
const String URL = "https://wloapp.crowdrcrm.com/v1";
// const String URL = "https://webapp.wastelubricatingoils.co.uk/v1";

final String path = 'assets/images/';

class Draw {
  final String title;
  final String icon;
  Draw({this.title, this.icon});
}

final List<Draw> drawerItems = [
  Draw(title: 'Home', icon: path + 'home.png'),
  Draw(title: 'My Account', icon: path + 'user_home.png'),
  Draw(title: 'View Checklist', icon: path + 'checklist.png'),
  Draw(title: 'Change Password', icon: path + 'change_pass.png'),
  Draw(title: 'Inbox', icon: path + 'message.png'),
];

showLaoding(context) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SizedBox(
              height: 40,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading...")
                ],
              ),
            ),
          ));
}
