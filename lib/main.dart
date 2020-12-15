import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Views/Head/BottomNavigationController.dart';
import 'package:spica/Views/Main/LoginView.dart';

void main() {
  runApp(SpicaApp());
}

class SpicaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Spica',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginProcessorView());
  }
}

class LoginProcessorView extends StatefulWidget {
  LoginProcessorView({Key key}) : super(key: key);

  @override
  _LoginProcessorViewState createState() => _LoginProcessorViewState();
}

class _LoginProcessorViewState extends State<LoginProcessorView> {
  @override
  void initState() {
    super.initState();
    loadSignedInStatus();
  }

  void loadSignedInStatus() async {
    final token = await MicroAPI.shared.loadAuthKey();
    final id = await MicroAPI.shared.loadSignedInID();
    if (token == null || token == "" || id == null || id == "") {
      Get.off(LoginView());
    } else {
      Get.off(BottomNavigationController(signedinid: id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}
