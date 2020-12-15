import 'package:flutter/foundation.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spica/Structs/Status.dart';

extension MicroAPI_Status on MicroAPI {
  Future<Status> loadUserStatus({@required String id}) async {
    try {
      final response = await http.get("https://wassup.alles.cc/$id");

      if (response.statusCode == 200) {
        return Status.fromJson(jsonDecode(response.body));
      } else {
        return Future.error(MicroAPI.shared.getError(response: response));
      }
    } catch (err) {
      return Future.error(MicroError(
          isError: true,
          name: err.toString(),
          humanDescription: err.toString()));
    }
  }
}
