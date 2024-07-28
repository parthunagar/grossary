import 'dart:ffi';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor/Auth/login_navigator.dart';
import 'package:vendor/Drawer/new_orders_drawer.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/style.dart';
import 'package:vendor/language_cubit.dart';
//TODO: LOGIN : ganesh@yopmail.com 123456
// NotificationAppLaunchDetails notificationAppLaunchDetails;
// test push
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  Firebase.initializeApp().then((value){
    setFirebase();
  });
  // setFirebase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('islogin');

  runApp(Phoenix(child: (result!=null && result)?GroceryStoreHome():GroceryStoreLogin()));
}

@override
void initState() {
  // super.initState();

}
// if (Platform.isIOS) iosPermission(firebaseMessaging);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void setFirebase() async {
  FirebaseMessaging messaging = FirebaseMessaging();
  iosPermission(messaging);
  print('token: ' + 'firebase');

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
  AndroidInitializationSettings('icon');
  var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  messaging.getToken().then((value) {
    print('token: ' + value);
  });
  messaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      _showNotification(flutterLocalNotificationsPlugin, '${message['notification']['title']}', '${message['notification']['body']}');
    },
    onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
    // onBackgroundMessage: myBackgroundMessageHandler,
    onLaunch: (Map<String, dynamic> message) async {},
    onResume: (Map<String, dynamic> message) async {});
}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
  _showNotification(flutterLocalNotificationsPlugin, '${title}', '${body}');
}

Future<void> _showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, dynamic title, dynamic body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('1232', 'Notify', 'Notify On Shopping', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
  IOSNotificationDetails(presentSound: false);
  IOSNotificationDetails iosDetail = IOSNotificationDetails(presentAlert: true);
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, '${title}', '${body}', platformChannelSpecifics, payload: 'item x');
}

Future selectNotification(String payload) async {
  if (payload != null) {}
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  _showNotification(flutterLocalNotificationsPlugin, '${message['notification']['title']}', '${message['notification']['body']}');
}

void iosPermission(firebaseMessaging) {
  firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
  firebaseMessaging.onIosSettingsRegistered.listen((event) {
    print('${event.provisional}');
  });
}


class GroceryStoreLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          saveLanguage(locale.toString());
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ar'),
              const Locale('pt'),
              const Locale('fr'),
              const Locale('id'),
              const Locale('es'),
            ],
            locale: locale,
            theme: appTheme,
            home: SignInNavigator(),
            routes: PageRoutes().routes(),
          );
        },
      ),
    );
  }
}
void saveLanguage(String s)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("language", s);
}
class GroceryStoreHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          saveLanguage(locale.toString());
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ar'),
              const Locale('pt'),
              const Locale('fr'),
              const Locale('id'),
              const Locale('es'),
            ],
            locale: locale,
            theme: appTheme,
            home: NewOrdersDrawer(),
            routes: PageRoutes().routes(),
          );
        },
      ),
    );
  }
}
// post_install do |installer|
// installer.pods_project.targets.each do |target|
// flutter_additional_ios_build_settings(target)
// end
// end