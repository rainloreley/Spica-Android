import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_User.dart';
import 'package:spica/Views/Head/BottomNavigationController.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginView extends StatefulWidget {
  LoginView({Key key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController _nametagEditingController;
  TextEditingController _passwordEditingController;

  @override
  void initState() {
    _nametagEditingController = TextEditingController();
    _passwordEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nametagEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }

  void login() async {
    final splitusername = _nametagEditingController.text.split("#");
    if (splitusername.length != 2 || splitusername[1].length != 4) {
      Get.dialog(AlertDialog(
        title: Text("Please enter a valid nametag"),
        actions: [
          TextButton(
              onPressed: (() {
                Get.back();
              }),
              child: Text("Close"))
        ],
      ));
    } else {
      MicroAPI.shared
          .signin(
              name: splitusername[0],
              tag: splitusername[1],
              password: _passwordEditingController.text)
          .then((id) {
        Get.off(BottomNavigationController(signedinid: id));
      }).catchError((err) {
        Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 70.0, left: 32),
                child: Text("Login",
                    style:
                        TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [Text("Nametag:"), Spacer()],
                      ),
                      TextField(
                        controller: _nametagEditingController,
                        focusNode: FocusNode(),
                        decoration: InputDecoration(hintText: "Lea#0001"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [Text("Password"), Spacer()],
                        ),
                      ),
                      TextField(
                          controller: _passwordEditingController,
                          focusNode: FocusNode(),
                          decoration: InputDecoration(hintText: "• • • • •"),
                          obscureText: true),
                      Padding(
                        padding: EdgeInsets.only(top: 32.0),
                        child: FlatButton(
                            onPressed: (() {
                              login();
                            }),
                            child: Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Text("By signing in, you agree to",
                          style: TextStyle(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (() async {
                                final url =
                                    "https://files.alles.cc/Documents/Terms%20of%20Service.txt";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              }),
                              child: Text("Alles Terms of service, ",
                                  style: TextStyle(color: Colors.blue[700])),
                            ),
                            GestureDetector(
                              onTap: (() async {
                                final url =
                                    "https://files.alles.cc/Documents/Privacy%20Policy.txt";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              }),
                              child: Text("Privacy Policy",
                                  style: TextStyle(color: Colors.blue[700])),
                            )
                          ],
                        ),
                      ),
                      Text("and", style: TextStyle(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (() async {
                                final url = "https://spica.li/privacy";
                                if (await canLaunch(url)) {
                                  await launch(url);
                                }
                              }),
                              child: Text("Spicas Privacy Policy",
                                  style: TextStyle(color: Colors.blue[700])),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
