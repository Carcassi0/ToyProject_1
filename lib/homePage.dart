import 'dart:core';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:doitflutter/myPage.dart';
import 'package:doitflutter/settingPage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'camera.dart';
import 'map/mapScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show join;
import 'package:google_fonts/google_fonts.dart';

import 'newLocationAdd.dart';






class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ImagePicker _picker = ImagePicker();
  XFile? _image;
  final LatLng _center = const LatLng(37.285172, 127.065014);
  late List<StoreInfo> todayStoreInfos = [];

  final dir = getApplicationDocumentsDirectory();
  final fileformattedDate =
      '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    initPath();
  }

  void initPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileformattedDate.csv';
    // 파일 존재 여부 확인
    while (!await File(filePath).exists()) {
      await Future.delayed(Duration(seconds: 1));
      print('파일이 존재하지 않습니다. 1초 후 다시 확인합니다.');
    }

    await _readStoreInfoFromCSV(filePath);
  }


  Future<void> _readStoreInfoFromCSV(String filePath) async {
    print('csv 불러오는 중');
    final csvContent = await rootBundle.loadString(filePath);
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvContent);
    final List<List<dynamic>> coordinates = csvData.skip(1).toList();
    final now = DateTime.now();
    DateTime twoDaysAgo = now.subtract(Duration(days: 2));
    String formattedDate = DateFormat('yyyy.M.d').format(twoDaysAgo);

    for (final coordinate in coordinates) {
      final id = coordinate[0].toString();
      final closingDate = coordinate[1].toString();
      final name = coordinate[2].toString();
      final latitude = double.parse(coordinate[4].toString());
      final longitude = double.parse(coordinate[3].toString());
      final description = coordinate[5].toString();

      final storeInfo = StoreInfo(
        id: id,
        closingDate: closingDate,
        name: name,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );


      final markerPosition = LatLng(storeInfo.latitude, storeInfo.longitude);
      final distance = haversineDistance(_center, markerPosition);

      if(distance<=1000 && closingDate == formattedDate){
        todayStoreInfos.add(storeInfo);
      }
    }
    print('csv 불러오기 완료');

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    List<String> menu = ['지도', '장소 추가', '알림', '요약'];
    List<IconData> menuIcon = [
      Icons.map_rounded, Icons.edit_location_alt_rounded, Icons.notification_important_rounded, Icons.my_library_books_rounded
    ];

    final user = FirebaseAuth.instance.currentUser!;

    // 시간
    final now = DateTime.now();
    DateTime twoDaysAgo = now.subtract(Duration(days: 2));
    String sformattedDate = DateFormat('yyyy.M.d').format(twoDaysAgo);

    // 기기 대응
    double height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    Future<String> _getUserName() async {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty){
        final lastName = snapshot.docs.first['last name'];
        final firstName = snapshot.docs.first['first name'];
        return '$lastName$firstName';
      } else {
        return 'Unknown User';
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        width: width * 0.75,
        child: Stack(
          children: <Widget>[
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: FutureBuilder(
                    future: _getUserName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                            '사용자: ${snapshot.data} 님',
                            style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w500)
                        );
                      }
                    },
                  ),
                  accountEmail: null, // 이메일 주소가 없는 경우 null을 전달합니다.

                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                      '마이페이지',
                      style: GoogleFonts.notoSans()
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const myPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(
                      '설정',
                      style: GoogleFonts.notoSans()
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const settingPage()),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: height * 0.08,
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                    '로그아웃',
                    style: GoogleFonts.notoSans()
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
      ),



      body: SafeArea(
        top: true, bottom: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.04, left: width * 0.03),
                    child: InkWell(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: const Icon(
                        Icons.menu_rounded,
                        size: 45,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: height * 0.08, left: width * 0.04),
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: _getUserName(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                '환영합니다, ${snapshot.data} 님',
                                style: GoogleFonts.notoSans(
                                  fontSize: width * 0.09,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                )
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.046),
                    child: Column(
                      children: [
                        Text(
                          user.email!,
                          style: GoogleFonts.notoSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          )
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.06),

                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: height * 0.07,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${sformattedDate} 기준 신규 폐업 사업장 ', style: GoogleFonts.notoSans(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500), ),
                          Icon(Icons.store_rounded, size: 25,color: Colors.white),
                          Text(': ${todayStoreInfos.length}', style: GoogleFonts.notoSans(fontSize: 23, color: Colors.white, fontWeight: FontWeight.w500), )
                          // 오늘 날짜 기준 이틀 전의 데이터 개수로 대입
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.01),

                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: height * 0.75,
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          mainAxisSpacing: 20,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (index == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MyMapScreen()),
                                );
                              }
                              if (index == 1) {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const newLocationAdd()));
                              }
                              if (index == 2) {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const csvPage()));
                              }
                              if (index == 3) {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const csvPage()));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(menuIcon[index], size: 55, color: Colors.white,),
                                  Text(menu[index], style: GoogleFonts.notoSans(
                                      fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}




class csvPage extends StatefulWidget {
  const csvPage({super.key});

  @override
  State<csvPage> createState() => _csvPageState();
}

class _csvPageState extends State<csvPage> {
  List<List<dynamic>> _data = [];

  void _loadCSV() async {
    final _rawdata = await rootBundle.loadString("asset/mycsv.csv");
    List<List<dynamic>> _listData = const CsvToListConverter().convert(_rawdata);
    setState(() {
      _data = _listData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (_, index){
          return Card(
            margin: const EdgeInsets.all(3),
            color: index == 0 ? Colors.amber : Colors.white, // 첫번째 줄은 인덱스 줄이니까 다른 색으로 설정
            child: ListTile(
              leading: Text(_data[index][0].toString()),
              title: Text(_data[index][1]),
              trailing: Text(_data[index][2].toString()),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _loadCSV,
          child: const Icon(Icons.add)
      ),
    );
  }
}


















