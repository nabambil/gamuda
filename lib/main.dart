import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:settle_assessment/authentication.dart';
import 'package:settle_assessment/bloc/blocConfiguration.dart';
import 'package:settle_assessment/bloc/blocMap.dart';
import 'package:settle_assessment/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'bloc/blocMonitor.dart';
import 'widgets/CustomTile.dart';
import 'package:latlong/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: fontName),
      debugShowCheckedModeBanner: false,
      home: AuthenticationPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BlocConfiguration _bloc;
  BlocMap _map;
  DateTime selectedDate = DateTime.now();

  final MapController _controller = MapController();
  @override
  void initState() {
    super.initState();

    _bloc = BlocConfiguration(context: context);
    _map = BlocMap();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowBright,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: yellowMid,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24),
            Text("${selectedDate.toLocal()}".split(' ')[0]),
            IconButton(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app, color: white),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
      drawer: _SideMenu(_bloc),
      body: StreamBuilder<List<LatLng>>(
          stream: _map.location,
          builder: (context, snapshot) {
            List<LatLng> list = List<LatLng>();
            if (snapshot.data != null) list.addAll(snapshot.data);
            return StreamBuilder<LatLng>(
                stream: _map.current$,
                builder: (context, snapshot) {
                  LatLng center = LatLng(51.5, -0.09);
                  if (snapshot.data != null) center = snapshot.data;
                  return FlutterMap(
                    mapController: _controller,
                    //   options: MapOptions(
                    //     center: LatLng(51.5, -0.09),
                    //     zoom: 13.0,
                    //   ),
                    //   layers: [
                    //     TileLayerOptions(
                    //         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    //         subdomains: ['a', 'b', 'c']),
                    //     MarkerLayerOptions(
                    //       markers: [
                    //         Marker(
                    //           width: 80.0,
                    //           height: 80.0,
                    //           point: LatLng(51.5, -0.09),
                    //           builder: (ctx) => Container(
                    //             child: FlutterLogo(),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    options: MapOptions(
                      center: center,
                      zoom: 5.0,
                    ),
                    layers: [
                      TileLayerOptions(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c']),
                      PolylineLayerOptions(
                        polylines: [
                          Polyline(
                              points: list, strokeWidth: 4.0, color: yellowMid),
                        ],
                      ),
                    ],
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.gps_fixed, color: white),
        backgroundColor: yellowMid,
        onPressed: () =>
            _map.currentLocation.then((value) => _controller.move(value, 14.0)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        _map.updateDate(selectedDate);
        selectedDate = picked;
      });
  }
}

class _CustomTitle extends StatelessWidget {
  final String value;

  _CustomTitle(this.value);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(value, style: _style),
      ),
    );
  }

  TextStyle get _style {
    return TextStyle(
      fontWeight: FontWeight.w200,
      fontSize: 32,
      color: Colors.white,
      fontFamily: fontName,
    );
  }
}

class _SideMenu extends StatefulWidget {
  BlocConfiguration _bloc;

  _SideMenu(this._bloc);

  @override
  __SideMenuState createState() => __SideMenuState();
}

class __SideMenuState extends State<_SideMenu> {
  BlocMonitor _monitor;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return Text('loading');
                return Column(children: [
                  Text(
                    "Hi " + snapshot.data.getString(kUsername) + " !",
                    style: TextStyle(color: yellowDark),
                  ),
                  SizedBox(height: 8),
                  Image.asset(
                    "assets/placeholder.png",
                    height: 100,
                    width: 100,
                  )
                ]);
              },
            ),
            decoration: BoxDecoration(
              color: yellowBright,
            ),
          ),
          if (_monitor == null)
            CustomTile(
              title: 'Radius of Zone ',
              firstOption: 'Default : 500 meter',
              secondOption: 'Configure :',
              type: FieldRequire.single,
              firstLabel: 'Radius (meter)',
              onChangeOption: widget._bloc.changeRadiusOption,
              onChangeFirstText: widget._bloc.insertRadius,
              result$: widget._bloc.optRadius,
              isNumber: true,
            ),
          if (_monitor == null)
            CustomTile(
              title: 'Geolocation of Zone ',
              firstOption: 'Default : Current ',
              secondOption: 'Configure :',
              type: FieldRequire.dual,
              firstLabel: 'latitude (decimal)',
              secondLabel: 'longitude (decimal)',
              onChangeOption: widget._bloc.changeGeoOption,
              onChangeFirstText: widget._bloc.insertLatitude,
              onChangeSecondText: widget._bloc.insertLongitude,
              result$: widget._bloc.optGeo,
              isNumber: true,
            ),
          if (_monitor == null)
            CustomTile(
              title: 'Wifi Name ',
              firstOption: 'Default : Any ',
              secondOption: 'Configure :',
              type: FieldRequire.single,
              firstLabel: 'Wifi ssid',
              onChangeOption: widget._bloc.changeWifiOption,
              onChangeFirstText: widget._bloc.insertWifi,
              result$: widget._bloc.optWifi,
            ),
          if (_monitor != null)
            _CustomInfo(
              title: 'Geo Point',
              subTitle:
                  '** ${widget._bloc.latitude} | ${widget._bloc.longitude}',
              iconEnabled: Icons.location_on,
              iconDisabled: Icons.location_off,
              status: _monitor.statZone,
            ),
          if (_monitor != null)
            _CustomInfo(
              title: 'Radius Fence',
              subTitle: '** ${widget._bloc.radius} meter',
              iconEnabled: Icons.filter_center_focus,
              iconDisabled: Icons.center_focus_weak,
              status: _monitor.statZone,
            ),
          if (_monitor != null)
            StreamBuilder<String>(
                stream: _monitor.wifiName,
                builder: (context, snapshot) {
                  return _CustomInfo(
                    title: 'Wifi Name',
                    subTitle: '** ${snapshot.data}',
                    iconEnabled: Icons.wifi,
                    iconDisabled: Icons.signal_wifi_off,
                    status: _monitor.statConnection,
                  );
                }),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FloatingActionButton.extended(
              backgroundColor: yellowDark,
              label: Text(_monitor == null
                  ? 'Begin Configuration'
                  : "Stop Configuration"),
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                if (_monitor == null) {
                  if (widget._bloc.enableSubmit() == false) {
                    Navigator.pop(context);
                    Toast.show('Check Configure Field', context);
                  } else {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ));
                    widget._bloc
                        .submit()
                        .then((value) => setState(() => _monitor = value))
                        .whenComplete(() => Navigator.pop(context));
                  }
                } else {
                  _monitor.dispose();
                  setState(() => _monitor = null);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomInfo<T> extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData iconEnabled;
  final IconData iconDisabled;
  final Stream<T> status;

  _CustomInfo({
    @required this.title,
    @required this.subTitle,
    @required this.iconEnabled,
    @required this.iconDisabled,
    @required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: status,
      builder: (ctx, snapshot) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        title: Text(title),
        subtitle: Text(subTitle),
        leading: IgnorePointer(
          child: FloatingActionButton(
            heroTag: null,
            child: Icon(getIcon(snapshot.data)),
            onPressed: () {},
            backgroundColor: getColor(snapshot.data),
          ),
        ),
      ),
    );
  }

  Color getColor(T value) {
    if (value is ZoneStatus) {
      switch (value) {
        case ZoneStatus.outside:
          return Colors.grey;
        case ZoneStatus.inside:
          return yellowBright;
      }
    } else if (value is ConnectionStatus) {
      switch (value) {
        case ConnectionStatus.great:
          return yellowBright;
        case ConnectionStatus.good:
          return yellowMid;
        case ConnectionStatus.poor:
          return yellowDark;
        case ConnectionStatus.disconnected:
          return Colors.grey;
      }
    }

    return Colors.greenAccent;
  }

  IconData getIcon(T value) {
    if (value is ZoneStatus) {
      switch (value) {
        case ZoneStatus.outside:
          return iconDisabled;
        case ZoneStatus.inside:
          return iconEnabled;
      }
    } else if (value is ConnectionStatus) {
      switch (value) {
        case ConnectionStatus.great:
          return iconEnabled;
        case ConnectionStatus.good:
          return iconEnabled;
        case ConnectionStatus.poor:
          return iconEnabled;
        case ConnectionStatus.disconnected:
          return iconDisabled;
      }
    }

    return iconEnabled;
  }
}
