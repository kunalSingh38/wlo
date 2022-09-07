import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlo_master/screens/add_customer.dart';

import 'package:wlo_master/screens/add_newjob.dart';
import 'package:wlo_master/screens/change_password.dart';
import 'package:wlo_master/screens/checklist_screen.dart';
import 'package:wlo_master/screens/collection_details.dart';
import 'package:wlo_master/screens/collection_list.dart';
import 'package:wlo_master/screens/create_tip.dart';
import 'package:wlo_master/screens/customer.dart';
import 'package:wlo_master/screens/customer_pagination.dart';
import 'package:wlo_master/screens/edit_customer.dart';
import 'package:wlo_master/screens/inbox_messages.dart';
import 'package:wlo_master/screens/job_complete.dart';
import 'package:wlo_master/screens/job_details.dart';
import 'package:wlo_master/screens/job_pagination.dart';
import 'package:wlo_master/screens/jobs_homepage.dart';
import 'package:wlo_master/screens/login.dart';
import 'package:wlo_master/screens/payment_page.dart';
import 'package:wlo_master/screens/profile_edit.dart';
import 'package:wlo_master/screens/profile_show.dart';
import 'package:wlo_master/screens/profile_view.dart';
import 'package:wlo_master/screens/splash_screen.dart';
import 'package:wlo_master/screens/square_pay.dart';
import 'package:wlo_master/screens/successful_screen.dart';
import 'package:wlo_master/screens/view_checklist.dart';
import 'package:wlo_master/screens/view_single_checklist.dart';
import 'package:wlo_master/services/PushNotificationService.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); //for app
  await PushNotificationService().setupInteractedMessage(navigatorKey);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
  RemoteMessage initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;
  int id = 0;
  void initState() {
    super.initState();

    _checkLoggedIn();
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _isLoggedIn = prefs.getBool('logged_in');
    if (_isLoggedIn == true) {
      setState(() {
        _loggedIn = _isLoggedIn;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WLO',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(0xfffbefa7)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return PageTransition(
              child: SplashScreen(),
              type: null,
              settings: settings,
            );
            break;
          case '/login':
            return PageTransition(
              child: LoginScreen(),
              type: null,
              settings: settings,
            );
            break;

          case '/checklist-screen':
            return PageTransition(
              child: VehicleChecklists(),
              type: null,
              settings: settings,
            );
            break;

          case '/view-checklist':
            return PageTransition(
              child: VehicleChecklistsView(),
              type: null,
              settings: settings,
            );
            break;

          case '/view-single-checklist':
            var obj = settings.arguments;
            return PageTransition(
              child: VehicleSingleChecklist(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/jobs-homepage':
            return PageTransition(
              child: JobsScreen(),
              type: null,
              settings: settings,
            );
            break;
          case '/collection-list':
            return PageTransition(
              child: JobsCollectionScreen(),
              type: null,
              settings: settings,
            );
            break;
          case '/job-pagination':
            return PageTransition(
              child: JobsScreen11(),
              type: null,
              settings: settings,
            );
            break;
          case '/job-details':
            var obj = settings.arguments;
            return PageTransition(
              child: JobsDetails(argument: obj),
              type: null,
              settings: settings,
            );
          case '/successful-screen':
            var obj = settings.arguments;
            return PageTransition(
              child: SuccessfulCompletePage(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/job-complete':
            var obj = settings.arguments;
            return PageTransition(
              child: JobCollection(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/add-newjob':
            var obj = settings.arguments;
            return PageTransition(
              child: AddNewJob(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/customer':
            return PageTransition(
              child: CustomerList(),
              type: null,
              settings: settings,
            );
            break;
          case '/add-customer':
            return PageTransition(
              child: AddCustomers(),
              type: null,
              settings: settings,
            );
            break;
          case '/profile-show':
            return PageTransition(
              child: ProfileShow(),
              type: null,
              settings: settings,
            );
            break;
          case '/profile-view':
            return PageTransition(
              child: ProfileView(),
              type: null,
              settings: settings,
            );
            break;

          case '/change-password':
            return PageTransition(
              child: ChangePasswordScreen(),
              type: null,
              settings: settings,
            );
            break;

          case '/profile-edit':
            var obj = settings.arguments;
            return PageTransition(
              child: ProfileEdit(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          case '/create-tip':
            var obj = settings.arguments;
            return PageTransition(
              child: CreateTip(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/collection-details':
            var obj = settings.arguments;
            return PageTransition(
              child: CollectionDetails(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/customer-pagination':
            return PageTransition(
              child: CustomerList11(),
              type: null,
              settings: settings,
            );
            break;

          case '/jobs-pagination':
            return PageTransition(
              child: JobsScreen11(),
              type: null,
              settings: settings,
            );
            break;
          case '/payment-page':
            var obj = settings.arguments;
            return PageTransition(
              child: Payment(argument: obj),
              type: null,
              settings: settings,
            );
            break;

          // case '/square-pay':
          //   var obj = settings.arguments;
          //   return PageTransition(
          //     child: SquarePay(argument: obj),
          //     type: null,
          //     settings: settings,
          //   );
          //   break;

          case '/edit-customer':
            var obj = settings.arguments;
            return PageTransition(
              child: EditCustomers(argument: obj),
              type: null,
              settings: settings,
            );
            break;
          case '/inbox-message':
            return PageTransition(
              child: InboxMessages(),
              type: null,
              settings: settings,
            );
            break;
          default:
            return null;
        }
      },
      home: Scaffold(
        body: homeOrLog(),
      ),
    );
  }

  Widget homeOrLog() {
    /* if(this._loggedIn){
      return Dashboard();
    }
    else{*/
    return SplashScreen();
    //}
  }
}
