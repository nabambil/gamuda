import 'package:rxdart/subjects.dart';

import 'package:background_location/background_location.dart';
import 'package:settle_assessment/features/geofence.dart';
import 'package:settle_assessment/utils/repository.dart';

import 'package:latlong/latlong.dart';

class BlocMap {
  final BehaviorSubject<List<LatLng>> _locations = BehaviorSubject.seeded([]);
  final BehaviorSubject<LatLng> _current =
      BehaviorSubject.seeded(LatLng(51.5, -0.09));

  Stream get location => _locations.stream;
  Stream get current$ => _current.stream;
  set locations(List<LatLng> value) => _locations.sink.add(value);
  set current(LatLng value) => _current.sink.add(value);
  BlocMap() {
    BackgroundLocation.setAndroidConfiguration(60000);

    BackgroundLocation.getPermissions(
      onGranted: () {},
      onDenied: () {
        // Show a message asking the user to reconsider or do something else
        print("Location is not enable");
      },
    );

    BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      _updateLocation(location);
    });
    BackgroundLocation.setAndroidNotification(
      title: "Tracking",
      message: "you been tracked",
      icon: "@mipmap/ic_launcher",
    );
  }

  void dispose() {
    _locations.close();
    _current.close();
  }

  void _updateLocation(Location location) {
    final latlng = "${location.latitude},${location.longitude}";
    Repository().postResponse([latlng]).then((value) {
      try {
        final List<String> list = List.castFrom(value['location']);
        final List<LatLng> latlng = List<LatLng>();
        list.forEach((e) {
          final values = e.split(",");
          latlng.add(LatLng(double.parse(values[0]), double.parse(values[1])));
        });

        locations = latlng;
      } catch (e) {
        print(e);
      }
    });
  }

  void updateDate(DateTime date) {
    if (date == DateTime.now()) {
      BackgroundLocation.startLocationService();
    } else {
      BackgroundLocation.stopLocationService();
    }

    Repository().getResponse(date).then((value) {
      final List<String> list = value['location'];
      final List<LatLng> latlng = List<LatLng>();
      list.forEach((e) {
        final values = e.split(",");
        latlng.add(LatLng(double.parse(values[0]), double.parse(values[1])));
      });

      locations = latlng;
    });
  }

  Future<LatLng> get currentLocation async {
    final location = await GeoFenceModule.currentLocation;
    final latitude = location.latitude;
    final longitude = location.longitude;

    return LatLng(latitude, longitude);
  }
}
