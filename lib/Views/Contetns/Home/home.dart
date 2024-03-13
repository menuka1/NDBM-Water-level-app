import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:waterlevel/Models/Strings/app.dart';
import 'package:waterlevel/Models/Utils/Colors.dart';
import 'package:waterlevel/Models/Utils/Common.dart';
import 'package:waterlevel/Models/Utils/FirebaseStructure.dart';
import 'package:waterlevel/Models/Utils/Images.dart';
import 'package:waterlevel/Views/Contetns/Home/drawer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  double progress = 0.0;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      getData();
      initNotifications();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: color7,
        drawer: HomeDrawer(),
        body: SafeArea(
          child: SizedBox(
              width: displaySize.width,
              height: displaySize.height,
              child: Column(
                children: [
                  Expanded(
                      flex: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0))),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 18.0, bottom: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => (_scaffoldKey
                                        .currentState!.isDrawerOpen)
                                    ? _scaffoldKey.currentState!.openEndDrawer()
                                    : _scaffoldKey.currentState!.openDrawer(),
                                child: Icon(
                                  Icons.menu_rounded,
                                  color: colorWhite,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: BorderRadius.circular(20.0)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: displaySize.width * 0.08,
                                      child: Image.asset(logo),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        app_name,
                                        style: TextStyle(
                                            fontSize: 16.0, color: colorBlack),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  getData();
                                },
                                child: Icon(
                                  Icons.refresh,
                                  color: colorWhite,
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: LiquidLinearProgressIndicator(
                        value: progress / 100,
                        valueColor: AlwaysStoppedAnimation(colorPrimary),
                        backgroundColor: colorBlack,
                        borderColor: colorWhite,
                        borderWidth: 5.0,
                        borderRadius: 10.0,
                        direction: Axis.vertical,
                        center: Text(
                          "Water Level $progress%",
                          style: TextStyle(
                              color: (progress > 50) ? colorBlack : colorWhite),
                        ),
                      ))
                ],
              )),
        ));
  }

  void getData() {
    _databaseReference
        .child(FirebaseStructure.LIVEDATA)
        .onValue
        .listen((DatabaseEvent data) async {
      dynamic obj = data.snapshot.value;
      setState(() {
        progress = double.parse(obj['value'].toString());
      });
    });
  }

  void initNotifications() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        _databaseReference
            .child(FirebaseStructure.NOTIFY)
            .onValue
            .listen((DatabaseEvent data) async {
          dynamic noti = data.snapshot.value;
          if (noti['istrue'] == true) {
            AwesomeNotifications().createNotification(
                content: NotificationContent(
                    id: -1,
                    channelKey: 'emergency_waterlevel',
                    title: 'Notification',
                    body: noti['title'].toString()));

            await _databaseReference
                .child(FirebaseStructure.NOTIFY)
                .child('istrue')
                .set(false);
          }
        });
      }
    });
  }
}
