import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:location/location.dart' as lo;

import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wlo_master/constants.dart';
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
import 'package:http/http.dart' as http;

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

lo.Location location = new lo.Location();
// bool _serviceEnabled;
// PermissionStatus _permissionGranted;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // _serviceEnabled = await location.serviceEnabled();
  // if (!_serviceEnabled) {
  //   _serviceEnabled = await location.requestService();
  //   if (!_serviceEnabled) {
  //     return;
  //   }
  // }

  await initializeService();
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

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,
      foregroundServiceNotificationTitle: "Service Running",
      initialNotificationTitle: "Service Running",
      // auto start service
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  // service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  int time = 0;
  Map<String, String> headers = {
    'Accept': 'application/json',
  };
  var response = await http.get(Uri.parse(URL + "/config"), headers: headers);

  if (jsonDecode(response.body)['status'] == 200) {
    time = int.parse(jsonDecode(response.body)['data']
            ['background_delay_interval']
        .toString());
  }

  Fluttertoast.showToast(msg: "Service starts");
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  submitData();

  Timer.periodic(Duration(seconds: time), (timer) async {
    submitData();
  });
}

void submitData() async {
  // Fluttertoast.showToast(msg: "Service run");

  double latitudeGet = 0;
  double longitudeGet = 0;

  bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

  if (isLocationServiceEnabled) {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitudeGet = double.parse("${position.latitude}");
    longitudeGet = double.parse("${position.longitude}");

    final bool isConnected = await InternetConnectionChecker().hasConnection;

    if (isConnected) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + pref.getString("access_token").toString(),
      };
      var response = await http
          .post(Uri.parse(URL + "/tracking"), headers: headers, body: {
        "vehicle_id": pref.getString('vehicle_no').toString(),
        "lat": latitudeGet.toString(),
        "lng": longitudeGet.toString()
      });
      print(jsonEncode({
        "vehicle_id": pref.getString('vehicle_no').toString(),
        "lat": latitudeGet.toString(),
        "lng": longitudeGet.toString()
      }));
      print(response.body);
    } else {
      Fluttertoast.showToast(
          msg: "Check your internet connection.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
    }
  } else {
    Fluttertoast.showToast(
        msg: "Please trun on location.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER);

    Geolocator.openLocationSettings();
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
    // _determinePosition();
    _checkLoggedIn();
    // _determinePosition();
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
