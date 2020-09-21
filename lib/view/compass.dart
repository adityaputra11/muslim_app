import 'dart:async';
import 'dart:ffi';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyCompass());

class MyCompass extends StatefulWidget {
  const MyCompass({
    Key key,
  }) : super(key: key);

  @override
  _MyCompassState createState() => _MyCompassState();
}

class _MyCompassState extends State<MyCompass> {
  Completer<GoogleMapController> _controller = Completer();
  Position _post;
  bool _hasPermissions = false;
  double _lastRead = 0;
  DateTime _lastReadAt;
  LatLng _latLng = LatLng(3.595196, 98.672226);
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);



  @override
  void initState() {
    super.initState();
    _stateSetLat();
    _fetchPermissionStatus();
  }

  Future<Position> _getLat() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void _stateSetLat() {
    _getLat().then((value) => _latLng = LatLng(value.latitude, value.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (_hasPermissions) {
        return Column(
          children: <Widget>[
            _buildManualReader(),
            Expanded(child: _buildCompass()),
          ],
        );
      } else {
        return _buildPermissionSheet();
      }
    });
  }

  Widget _buildManualReader() {
    return
        Container(
          height: MediaQuery.of(context).size.height *0.8,
          width:  MediaQuery.of(context).size.width,
          child:  GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        );

//          Expanded(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.end,
//              children: <Widget>[
//                Text(
//                  '$_lastRead',
//                  style: Theme.of(context).textTheme.caption,
//                ),
//                Text(
//                  '$_lastReadAt',
//                  style: Theme.of(context).textTheme.caption,
//                ),
//              ],
//            ),
//          )
  }

  Widget _buildCompass() {
    return StreamBuilder<double>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double direction = snapshot.data;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Container(
          alignment: Alignment.center,
          child: Transform.rotate(
              angle: ((direction ?? 0) * (math.pi / 180) * -1),
              // child: Image.asset('assets/compass.jpg'),
              child: _latLng == null ? Text("wait") : Text('$_latLng')),
        );
      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          RaisedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              if (Permission.locationWhenInUse.request().isGranted != null)
                _fetchPermissionStatus();
            },
          ),
          SizedBox(height: 16),
          RaisedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((value) => null);
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
