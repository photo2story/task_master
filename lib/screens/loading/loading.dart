import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/constants/colors.dart';
import 'package:todo/constants/routes.dart';
import 'package:todo/controllers/controller.dart';
import 'package:todo/models/set-system-overlay-style.dart';
import 'package:todo/models/tasks.dart';
import 'package:todo/constants/types.dart';
import 'package:todo/models/user-name.dart';
import 'package:todo/screens/loading/components/logo.dart';
import 'package:todo/screens/loading/components/spinkit.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String nextRoute;
  bool isFirstEnter;
  @override
  void initState() {
    super.initState();
    nextRoute = home_route;
    isFirstEnter = false;
    load();
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIOverlayStyle(systemUIOverlayStyle: SystemUIOverlayStyle.LIGHT);
    return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Padding(
            padding: const EdgeInsets.only(left: 50, right: 45),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(),
                LoadingLogo(),
                SizedBox(),
                LoadingSpinkit(),
              ],
            )));
  }

  load() async {
    await check();
    pass();
  }

  check() async {
    await checkUserName().then((response) {
      Get.find<MainController>().updateMainStete(
        newFirstEnterStatus: !response,
      );
      setState(() {
        isFirstEnter = !response;
        if (isFirstEnter) {
          nextRoute = welcome_route;
        } else {
          getTasks();
          getUserName().then((response) {
            Get.find<MainController>().updateMainStete(
              newUserName: response,
            );
          });

          nextRoute = home_route;
        }
      });
    });
  }

  pass() async {
    await Future.delayed(Duration(milliseconds: 6000));
    Navigator.pushReplacementNamed(context, nextRoute);
  }
}
