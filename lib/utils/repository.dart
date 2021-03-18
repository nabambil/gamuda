import 'package:settle_assessment/utils/provider/provider.dart';

class Repository {
  Future<Map<String, dynamic>> getResponse(DateTime date) =>
      Provider.getRoute(date);
  Future<Map<String, dynamic>> postResponse(List<String> result) =>
      Provider.postRoute(result);
}
