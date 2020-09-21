import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:muslim_app/component/itemPray.dart';
import 'package:muslim_app/model/dataPray.dart';
import 'package:muslim_app/util/CountDowntTimer.dart';
import 'package:muslim_app/viewModel/ApiClient.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences prefs;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(countKey)) {
    await prefs.setInt(countKey, 0);
  }
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ReceivePort receivePort = ReceivePort();
  Future<DataPray> futurePray;
  static const headStyle = TextStyle(fontSize: 20, color: Colors.white);
  static const subHeadStyle =
      TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold);
  int _selectedIndex = 1;
  bool _isImsakActive = false;
  int _counter = 0;

  var _format = new HijriCalendar.now();

  DateTime birthday = DateTime.now();
  DateTime date2 = DateTime(2020, 08, 30, 15, 26, 00);

  void _onSwitchImsak(bool b) {
    setState(() {
      _isImsakActive = b;
    });
  }

  startTimer() async {
    print("Running");
    await AndroidAlarmManager.oneShot(
      Duration(seconds: date2.difference(birthday).inSeconds),
      // Ensure we have a unique alarm ID.
      Random().nextInt(pow(2, 31)),
      callback,
      exact: true,
      wakeup: true,
    );
  }

  @override
  void initState() {
    super.initState();
    futurePray = fetchPray();
    AndroidAlarmManager.initialize();
    startTimer();
    // port.listen((_) async => await _incrementCounter());
    // port.listen((v) {
    //   print('idono $v');
    // });
  }

  Future<void> _incrementCounter() async {
    print('Increment counter!');

    // Ensure we've loaded the updated count from the background isolate.
    await prefs.reload();

    setState(() {
      _counter++;
    });
  }

  // The background
  static SendPort uiSendPort;

  // The callback for our alarm
  static Future<void> callback() async {
    print('Alarm fired!');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Subuh', 'Waktu subuh Telah masuk', platformChannelSpecifics,
        payload: 'item x');

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Assalamu'alaikum",
                    style: headStyle,
                    textAlign: TextAlign.start,
                  ),
                  TypewriterAnimatedTextKit(
                      totalRepeatCount: 1,
                      onTap: () {
                        print("Tap Event");
                      },
                      text: [
                        "Adi",
                        "Aditya Put",
                        "Aditya Putra Pratama",
                      ],
                      textStyle: subHeadStyle,
                      textAlign: TextAlign.start,
                      alignment:
                          AlignmentDirectional.topStart // or Alignment.topLeft
                      ),
                ],
              ),
            ),
            Flexible(
                fit: FlexFit.loose,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.3),
                            spreadRadius: 20,
                            blurRadius: 20,
                            offset: Offset(0, 5),
                          ),
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Colors.white, Colors.grey[100]])),
                    child: SingleChildScrollView(
                        padding: EdgeInsets.all(10.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.2),
                                        spreadRadius: 10,
                                        blurRadius: 20,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.white,
                                          Colors.grey[100]
                                        ])),
                                padding: EdgeInsets.all(20.0),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: FutureBuilder(
                                          future: futurePray,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Ashar ",
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w200),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Text(
                                                    snapshot
                                                        .data.jadwal.data.ashar,
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30.0),
                                                  ),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  CountDownTimer(
                                                    countDownTimerStyle:
                                                        TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    secondsRemaining: date2
                                                        .difference(birthday)
                                                        .inSeconds,
                                                    // secondsRemaining: 30,
                                                  ),
                                                ],
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text("${snapshot.error}");
                                            }

                                            // By default, show a loading spinner.
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Image.network(
                                          'https://picsum.photos/250?image=9',
                                          width: 100,
                                          height: 100,
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.2),
                                        spreadRadius: 10,
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.white,
                                          Colors.grey[100]
                                        ])),
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 20.0),
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Builder(
                                        builder: (context) => Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30.0)),
                                                splashColor: Colors.red,
                                                child: Icon(Icons.arrow_left),
                                                onTap: () {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              Text("prev")));
                                                },
                                              ),
                                            )),
                                    Text("${_format.fullDate()}"),
                                    Builder(
                                        builder: (context) => Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                  splashColor: Colors.red,
                                                  child:
                                                      Icon(Icons.arrow_right),
                                                  key: ValueKey(
                                                      'RegisterOneShotAlarm'),
                                                  onTap: () async {
                                                    // await _showNotification();
                                                  }),
                                            )),
                                  ],
                                ),
                              ),
                              FutureBuilder(
                                  future: futurePray,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green
                                                    .withOpacity(0.2),
                                                spreadRadius: 10,
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                            gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  Colors.white,
                                                  Colors.grey[100]
                                                ])),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.only(top: 20.0),
                                        padding: EdgeInsets.all(20.0),
                                        child: Column(
                                          children: <Widget>[
                                            CustomItemPray(
                                              title: 'Imsak',
                                              time: snapshot
                                                  .data.jadwal.data.imsak,
                                              active: _isImsakActive,
                                              onSwitch: (bool b) =>
                                                  _onSwitchImsak(b),
                                            ),
                                            CustomItemPray(
                                                title: 'Subuh',
                                                time: snapshot
                                                    .data.jadwal.data.subuh,
                                                active: true,
                                                onSwitch: null),
                                            CustomItemPray(
                                                title: 'Terbit',
                                                time: snapshot
                                                    .data.jadwal.data.terbit,
                                                active: true,
                                                onSwitch: null),
                                            CustomItemPray(
                                                title: 'Dzuhur',
                                                time: snapshot
                                                    .data.jadwal.data.dzuhur,
                                                active: true,
                                                onSwitch: null),
                                            CustomItemPray(
                                                title: 'Ashar',
                                                time: snapshot
                                                    .data.jadwal.data.ashar,
                                                active: true,
                                                onSwitch: null),
                                            CustomItemPray(
                                                title: 'Maghrib',
                                                time: snapshot
                                                    .data.jadwal.data.maghrib,
                                                active: false,
                                                onSwitch: null),
                                            CustomItemPray(
                                                title: 'Isya',
                                                time: snapshot
                                                    .data.jadwal.data.isya,
                                                active: true,
                                                onSwitch: null),
                                          ],
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("${snapshot.error}");
                                    }

                                    // By default, show a loading spinner.
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }),
                            ],
                          ),
                        ))))
          ]),
    );
  }
}
