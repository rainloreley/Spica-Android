import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:http/http.dart' as http;

class MicroAPI {
  static final shared = MicroAPI();
  Future<String> loadAuthKey() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: "dev.abmgrt.spica.user.token");
    return token;
  }

  Future<String> loadSignedInID() async {
    final storage = FlutterSecureStorage();
    final id = await storage.read(key: "dev.abmgrt.spica.user.id");
    return id;
  }

  MicroError getError({@required http.Response response}) {
    if (response.body != null) {
      var json = jsonDecode(response.body);
      if (json["err"] != null) {
        return MicroError(
            isError: true,
            name: json["err"],
            humanDescription:
                "${json["err"]} (Status code ${response.statusCode})");
      } else {
        return MicroError(
            isError: true,
            name: "noErrorMessage",
            humanDescription:
                "The API didn't return an error message (Status code ${response.statusCode})");
      }
    } else {
      return MicroError(
          isError: true,
          name: "noDataReturned",
          humanDescription:
              "The API didn't return any data (Status code ${response.statusCode})");
    }
  }

  AlertDialog renderErrorAlertDialog({@required MicroError error}) {
    return AlertDialog(
      title: Text("An error occurred"),
      content:
          Text("The following error occurred:\n\n${error.humanDescription}"),
      actions: [
        TextButton(
            onPressed: (() {
              Get.back();
            }),
            child: Text("Close"))
      ],
    );
  }
}

class MicroError {
  bool isError;
  String name;
  String humanDescription;

  MicroError(
      {@required this.isError,
      @required this.name,
      @required this.humanDescription});
}
