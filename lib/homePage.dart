import 'dart:core';
import 'dart:async';
import 'package:doitflutter/settingPage.dart';
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



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    List<String> menu = ['지도', '업무관리', '알림', '요약'];
    List<IconData> menuIcon = [
      Icons.map, Icons.list, Icons.notifications, Icons.my_library_books
    ];

    final user = FirebaseAuth.instance.currentUser!;

    var height, width;
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
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(254, 213, 188, 1),
        width: width * 0.75,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
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
                      style: GoogleFonts.notoSans(fontSize: 20, color: Colors.black)
                    );
                  }
                },
              ),
              accountEmail: null, // 이메일 주소가 없는 경우 null을 전달합니다.
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
                backgroundColor: Colors.grey,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                '마이페이지',
                style: GoogleFonts.notoSans(color: Colors.black)
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const settingPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                '설정',
                style: GoogleFonts.notoSans(color: Colors.black)
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const settingPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                '로그아웃',
                style: GoogleFonts.notoSans(color: Colors.black)
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),


      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          color: const Color.fromRGBO(254, 213, 188, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 55, left: 10, right: 20),
                child: InkWell(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 45,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 75, left: 20, right: 15),
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
                              fontSize: 35,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            )
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 22, right: 15),
                child: Column(
                  children: [
                    Text(
                      user.email!,
                      style: GoogleFonts.notoSans(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      )
                    )
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(),
                height: height * 0.14,
                width: width,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 190, 152, 1),
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
                                context, MaterialPageRoute(builder: (context) => const csvPage()));
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
                            color: const Color.fromRGBO(254, 213, 188, 1),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(menuIcon[index], size: 55),
                              Text(menu[index], style: GoogleFonts.notoSans(
                                  fontSize: 19, fontWeight: FontWeight.w500)),
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
    );
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


















