import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlo_master/screens/inbox_messages.dart';

class Preference {
  Future<SharedPreferences> getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
