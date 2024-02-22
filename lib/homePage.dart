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
    List<String> menu = ['지도', '업무관리', '사진 등록', '기타'];
    List<IconData> menuIcon = [
      Icons.map, Icons.list, Icons.cloud_upload, Icons.my_library_books
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
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 100),
                  FutureBuilder(
                              future: _getUserName(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                  '사용자: ${snapshot.data} 님',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                              );
                            }
                            },
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text(
                '설정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const settingPage()),
                );
              },
            )
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
                padding: const EdgeInsets.only(top: 55, left: 20, right: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Icon(Icons.output, size: 35),
                    )
                  ],
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
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 35,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
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
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                      ),
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('사진 등록'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        GestureDetector(
                                          child: const Text("갤러리에서 사진 선택"),
                                          onTap: () async {
                                            XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                            if(image == null) return;
                                            final temporaryPath = join(
                                                (await getTemporaryDirectory()).path,
                                              '${DateTime.now()}.png',
                                            );
                                            Navigator.pop(context);

                                            final selectedImage = image;
                                            await selectedImage?.saveTo(temporaryPath);

                                            final uploadedImagePath = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DisplayPictureScreen(imagePath: temporaryPath),
                                              ),
                                            );
                                          },
                                        ),
                                        const Padding(padding: EdgeInsets.all(8.0)),
                                        GestureDetector(
                                          child: const Text("카메라로 사진 찍기"),
                                          onTap: () async {
                                            XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                            if(image == null) return;
                                            final temporaryPath = join(
                                              (await getTemporaryDirectory()).path,
                                              '${DateTime.now()}.png',
                                            );
                                            Navigator.pop(context);

                                            final selectedImage = image;
                                            await selectedImage?.saveTo(temporaryPath);

                                            final uploadedImagePath = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DisplayPictureScreen(imagePath: temporaryPath),
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
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
                              Text(menu[index], style: const TextStyle(fontSize: 20)),
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


















