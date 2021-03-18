import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:settle_assessment/utils/constant.dart';

class Network {
  final Map<String, dynamic> param;

  Network(this.param);

  Future<Map<String, dynamic>> getting() async {
    print("get");
    try {
      final _url = url + "/${param['deviceId']}/${param['date']}";
      final result = await http.get(_url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      return json.decode(result.body);
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> posting() async {
    print("post");
    try {
      final _param = json.encode(param);
      final result = await http.post(url, body: _param, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      return json.decode(result.body);
    } catch (e) {
      throw e;
    }
  }
}
