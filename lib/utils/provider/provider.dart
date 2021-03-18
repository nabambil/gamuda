import 'package:intl/intl.dart';
import 'package:device_info/device_info.dart';

import '../network.dart';

class Provider {
  static Future<String> deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final result = await deviceInfo.androidInfo;
    return result.androidId;
  }

  static Future<Map<String, dynamic>> getRoute(DateTime currentDate) async {
    final f = new DateFormat('yyyy-MM-dd');
    final date = f.format(currentDate);
    final device = await Provider.deviceID();

    try {
      final map = {
        "deviceId": device,
        "date": date,
      };

      final network = Network(map);

      final result = await network.getting();
      return result['data'];
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<String, dynamic>> postRoute(List<String> values) async {
    final device = await Provider.deviceID();
    final map = {
      "deviceId": device,
      "location": values,
    };

    try {
      final network = Network(map);
      final result = await network.posting();

      return result["data"];
    } catch (err) {
      throw err;
    }
  }
}
