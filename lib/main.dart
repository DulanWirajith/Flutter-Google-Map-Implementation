import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Google Maps Implementation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController _controller;
  Position myPosition;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: 300,
          width: MediaQuery.of(context).size.width - 50,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(6.164918, 80.153512),
              zoom: 14.4746,
              bearing: 45.0,
              tilt: 45.0,
            ),
            markers: Set.from(setOfMarlers()),
            onMapCreated: mapCreated,
            myLocationEnabled: true,
            // myLocationButtonEnabled: true,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // GeolocationStatus geolocationStatus = await Geolocator()
          //     .checkGeolocationPermissionStatus(
          //         locationPermission: GeolocationPermission.locationAlways);
          // Geolocator geolocator = Geolocator()
          //   ..forceAndroidLocationManager = true;
          // print(geolocator);

          // GeolocationStatus geolocationStatus =
          //     await Geolocator().checkGeolocationPermissionStatus();
          // print(geolocationStatus);
          bool isLocationEnabled =
              await Geolocator().isLocationServiceEnabled();
          if (isLocationEnabled) {
            debugPrint("GPS is Enabled");
            final Geolocator geolocator = Geolocator()
              ..forceAndroidLocationManager;

            geolocator
                .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                .then((Position position) {
              myPosition = position;
              print('hey +  $position');
            }).catchError((e) {
              print(e);
            });

            print(myPosition);
          } else {
            debugPrint("GPS is Dissabled.. please enable gps..");
          }
          //
        },
        tooltip: 'Live Location',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void mapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  List<Marker> setOfMarlers() {
    List<Marker> allMarkers = [
      Marker(
        markerId: MarkerId("MyLocation"),
        draggable: true,
        position: LatLng(6.193328523608434, 80.1425026729703),
        onDragEnd: (value) async {
          _controller.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: value, zoom: 14.0),
            ),
          );
          debugPrint(value.toString());
          try {
            List<Placemark> placemark = await Geolocator()
                .placemarkFromCoordinates(value.latitude, value.longitude);
            Placemark place = placemark[0];
            debugPrint(place.locality);
          } catch (e) {
            print(e);
          }
          // final coordinates=new Coordinates(value.latitude, value.longitude);
          // var address= await Geocoder.local.findAddressesFromCoordinates(coordinates);
          // var first=address.first;
          // print(first.locality);
        },
      ),
    ];
    return allMarkers;
  }
}
