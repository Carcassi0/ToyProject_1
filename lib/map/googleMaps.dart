
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';
import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import '../theme/themeProvider.dart';
import 'package:location/location.dart';
import 'mapScreen.dart';


class GoogleMaps extends StatefulWidget {
  final Function(String) scrollToItem; // 콜백 함수 정의
  final List<StoreInfo> storeInfos;

  GoogleMaps({required this.scrollToItem, required this.storeInfos, Key? key}) : super(key: key);

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.285172, 127.065014);
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final now = DateTime.now();
  double _currentZoom = 13.0;
  String? _darkMapStyle;
  final fileformattedDate =
      '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';


  Set<Marker> _buildMarkers() {
    // 마커 생성 코드 작성
    // 마커를 클릭하면 해당하는 ListView 항목을 스크롤하는 기능 추가
    return Set<Marker>.from(widget.storeInfos.map((storeInfo) {
      final markerPosition = LatLng(storeInfo.latitude, storeInfo.longitude);
      final distance = haversineDistance(_center, markerPosition);

      return Marker(
        markerId: MarkerId(storeInfo.id),
        position: markerPosition,
        onTap: () {
          // 마커 클릭 시 scrollToItem 콜백 함수 호출하여 해당하는 ListView 항목 스크롤
          widget.scrollToItem(storeInfo.id);
        },
      );
    }));
  }



  BitmapDescriptor getMarkerIcon(dateFromNow){
    if(dateFromNow>14)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    else if(dateFromNow<=14 && dateFromNow>7)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    else if(dateFromNow<=7 && dateFromNow>=0)
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    else
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  int calculateDays(String dateString) {
    // 주어진 문자열 형식의 날짜를 DateTime 객체로 변환
    List<String> dateParts = dateString.split('-');
    DateTime specifiedDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));

    DateTime today = DateTime.now();

    Duration difference = today.difference(specifiedDate);

    // 일 수 반환
    return difference.inDays;
  }
  // List<String> dateParts = dateString.split('-'); 에서 에러 발생한 이유.....
  // 파이어스토어는 날짜 형식을 저장할 때 일반적으로 ISO 8601 형식을 사용합니다. 이 형식은 "YYYY-MM-DD"로 표현됩니다.
  // 따라서 파이어스토어에 데이터를 업로드할 때 "2024.2.29"와 같은 형식은 자동으로 ISO 8601 형식으로 변환됩니다.
  // 이렇게 함으로써 데이터의 일관성과 통일성을 유지할 수 있습니다.

  // 따라서 Reffi 앱을 통해 파이어스토어에 업로드할 때 날짜 형식이 자동으로 변환된 것입니다.
  // 만약 특정 형식으로 날짜를 저장하고 싶다면, 데이터를 업로드하기 전에 날짜 형식을 해당 형식으로 변환하여야 합니다.
  // 이렇게 하면 파이어스토어에서 자동으로 형식을 변환하지 않습니다.




  @override
  void initState() {
    super.initState();
    _loadMarkersFromCSV();
    _loadMapStyles();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/darkModeStyle.json');
  }


  Future<void> _loadMarkersFromCSV() async {
    try {
      setState(() {
        //_markers.clear();
        _circles.clear();
        for (final coord in widget.storeInfos) {
          final markerPosition = LatLng(coord.latitude, coord.longitude);
          final distance = haversineDistance(_center, markerPosition);
          if (distance <= 1000) {
            final marker = Marker(
              onTap: (){
                final storeId = '${coord.name.toString()}'; // 마커에 대한 고유한 식별자 (storeInfos의 id와 동일해야 함)
                widget.scrollToItem(storeId);
              },
              markerId: MarkerId(coord.name.toString()),
              position: markerPosition,
              infoWindow: InfoWindow(
                title: coord.name.toString(),
                snippet: "폐업일자:${coord.closingDate.toString()}\n${coord.description.toString()}",
              ),
              visible: true,
              icon: getMarkerIcon(calculateDays(coord.closingDate.toString()))//BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: <Widget>[GoogleMap(
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.0,
          ),
          myLocationEnabled: true,
          markers: _markers,
          circles: _circles,
          onCameraIdle: (){
            mapController.getZoomLevel().then((value){
              setState(() {
                if (themeProvider.isDarkMode()) {
                  // 다크 모드일 경우 darkMapStyle 적용
                  mapController!.setMapStyle(_darkMapStyle);
                } else {
                  // 다크 모드가 아닐 경우 기본 스타일 적용
                  mapController!.setMapStyle(null); // 또는 다른 기본 스타일로 변경
                }
                _currentZoom = value;
                if(_currentZoom >= 12.0){
                  _loadMarkersFromCSV();
                }
              });
            });
          },
        ),
          Positioned(
            top: height*0.1,right: width*0.06,
            child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                onPressed: (){_locateUser();},
            child: Icon(Icons.location_searching_outlined, size: 30, color: Theme.of(context).colorScheme.outline,)),
          )
      ]
      ),
    );
  }

  void _locateUser() async {
    Location location = Location();
    LocationData? currentLocation;

    try {
      currentLocation = await location.getLocation();

      if (currentLocation != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 14.4746,
          ),
        ));
      } else {
        print("Failed to get current location.");
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }


}
