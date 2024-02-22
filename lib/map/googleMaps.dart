import 'dart:io';
import 'dart:async';
import 'package:doitflutter/user/loginPage.dart';
import 'package:doitflutter/settingPage.dart';
import '../settingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import 'package:cp949_dart/cp949_dart.dart' as cp949;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'imageUpload.dart';
import 'package:image_picker/image_picker.dart';


class GoogleMaps extends StatefulWidget {
  const GoogleMaps({Key? key}) : super(key: key);

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.285172, 127.065014);
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  double _currentZoom = 13.0;


  @override
  void initState() {
    super.initState();
    _loadMarkersFromCSV();
  }

  Future<void> _loadMarkersFromCSV() async {
    try {
      final csvFilePath = "assets/baseData.csv";
      final coordinates = await readCoordinatesFromCSV(csvFilePath);
      print("Parsed coordinates from CSV: $coordinates"); // 데이터 파싱 확인을 위한 출력
      setState(() {
        //_markers.clear();
        _circles.clear();
        for (final coord in coordinates) {
          final markerPosition = LatLng(coord[4],coord[3]);
          final distance = haversineDistance(_center, markerPosition);
          if (distance <= 1000) {
            final marker = Marker(
              markerId: MarkerId(coord[2].toString()),
              position: markerPosition,
              infoWindow: InfoWindow(
                title: coord[2].toString(),
                snippet: "폐업일자:${coord[1].toString()}\n${coord[5].toString()}",
              ),
              visible: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );
            _markers.add(marker);
            print("Added marker: $marker"); // 마커 추가 확인을 위한 출력
          }
        }
        _circles.add(Circle(
          circleId: const CircleId('1000m_radius'),
          center: _center,
          radius: 1000,
          strokeWidth: 2,
          strokeColor: Colors.red,
          fillColor: Colors.red.withOpacity(0.1),
        ));
      });
    } catch (e) {
      print("Error loading markers: $e");
    }
  }



  Future<List<List<dynamic>>> readCoordinatesFromCSV(String filePath) async {
    final csvContent = await rootBundle.loadString(filePath);
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvContent);
    final List<List<dynamic>> coordinates = csvData.skip(1).toList();
    return coordinates;
  }


  double haversineDistance(LatLng p1, LatLng p2) {
    const radiusEarth = 6371.0; // 지구의 반지름 (킬로미터 단위)
    final lat1 = p1.latitude * (pi / 180.0);
    final lon1 = p1.longitude * (pi / 180.0);
    final lat2 = p2.latitude * (pi / 180.0);
    final lon2 = p2.longitude * (pi / 180.0);
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * asin(sqrt(a));
    final distance = radiusEarth * c; // 결과값은 킬로미터 단위
    return distance * 1000.0; // 결과값을 미터 단위로 변환
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    var height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
          children:[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 13.0,
              ),
              markers: _markers,
              circles: _circles,
              onCameraIdle: (){
                mapController.getZoomLevel().then((value){
                  setState(() {
                    _currentZoom = value;
                    if(_currentZoom >= 12.0){
                      _loadMarkersFromCSV();
                    }
                  });
                });
              },
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 30, top: height*0.73, bottom: 30),
                child: const Row(
                  children: [
                    Icon(Icons.zoom_in, size: 50),
                    Icon(Icons.zoom_out, size: 50,)
                  ],
                ))
          ]
      ),
    );
  }
}