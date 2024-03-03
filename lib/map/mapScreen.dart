import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'googleMaps.dart';
import 'package:camera/camera.dart';
import 'package:doitflutter/camera.dart';
import 'package:path/path.dart' show join;

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({Key? key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  String? get docId => '02cA590Y5VJmUMNhHHuj';

  late List<StoreInfo> storeInfos = [];

  Future<List<List<dynamic>>> readCoordinatesFromCSV(String filePath) async {
    final csvContent = await rootBundle.loadString(filePath);
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvContent);
    final List<List<dynamic>> coordinates = csvData.skip(1).toList();
    return coordinates;
  }

  final LatLng _center = const LatLng(37.285172, 127.065014);
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late ImagePicker _picker;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _picker = ImagePicker();
    _readStoreInfoFromCSV("assets/baseData.csv");
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      print('No cameras available');
      return;
    }

    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _readStoreInfoFromCSV(String filePath) async {
    final csvContent = await rootBundle.loadString(filePath);
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvContent);
    final List<List<dynamic>> coordinates = csvData.skip(1).toList();

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

      storeInfos.add(storeInfo);
    }
  }

  Widget build(BuildContext context) {
    var height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            child: const GoogleMaps(),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 0.69,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),

                ),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: FutureBuilder<List<List<dynamic>>>(
                    future: readCoordinatesFromCSV("assets/baseData.csv"), // 여기에 파일 경로 입력
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final coordinates = snapshot.data!;
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: storeInfos.length,
                          itemBuilder: (BuildContext context, int index) {
                            final storeInfo = storeInfos[index];
                            final markerPosition = LatLng(storeInfo.latitude, storeInfo.longitude);
                            final distance = haversineDistance(_center, markerPosition);

                            if(distance <= 1000) {
                              return Card(
                                child: ListTile(
                                  onTap: () async {}, // 메모 및 영업 이력 확인할 수 있는 페이지로 이동
                                  title: Text(storeInfo.name),
                                  subtitle: Text('폐업일자: ${storeInfo.closingDate}\n${storeInfo.description}'),
                                  trailing: GestureDetector(
                                    child: const Icon(Icons.image_rounded, size: 35),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                          child: SingleChildScrollView(
                                            physics: NeverScrollableScrollPhysics(),
                                            child: Column(
                                            mainAxisSize: MainAxisSize.min, // 컨텐츠에 맞게 다이얼로그 크기 조정
                                              children: <Widget>[

                                                const SizedBox(height: 30),

                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '사진 등록 이력',
                                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),

                                                const SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        border: Border.all(color: Colors.black, width: 2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: GestureDetector(
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Text(
                                                            '갤러리에서 등록',
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                                          if (image == null) return;
                                                          final now = DateTime.now();
                                                          final formattedDate =
                                                              '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
                                                              '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
                                                          final temporaryPath = join((await getTemporaryDirectory()).path, '${storeInfo.name}_$formattedDate.png');

                                                          Navigator.pop(context);


                                                          final selectedImage = image;
                                                          await selectedImage?.saveTo(temporaryPath);

                                                          final uploadedImagePath = await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => DisplayPictureScreen(imagePath: temporaryPath)
                                                              )
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    const SizedBox(width: 10),

                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        border: Border.all(color: Colors.black, width: 2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: GestureDetector(
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Text(
                                                            '카메라',
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                                          if (image == null) return;
                                                          final now = DateTime.now();
                                                          final formattedDate =
                                                              '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
                                                              '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
                                                          final temporaryPath = join((await getTemporaryDirectory()).path, '${storeInfo.name}_$formattedDate.png');
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
                                                    )
                                                  ],
                                                ),

                                                const SizedBox(height: 20),

                                                ListBody(
                                                  children: <Widget>[
                                                    FutureBuilder<QuerySnapshot>(
                                                      future: FirebaseFirestore.instance
                                                          .collection('images')
                                                          .where('storeName', isGreaterThanOrEqualTo: '${storeInfo.name}_')
                                                          .where('storeName', isLessThan: '${storeInfo.name}_\uf8ff')
                                                          .get(),
                                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                        if (snapshot.hasError) {
                                                          return Image.asset('assets/non.png'); // 에러 발생 시 아무것도 반환하지 않습니다.
                                                        }
                                                        if (snapshot.connectionState == ConnectionState.done) {
                                                          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                                                            return Image.asset('assets/non.png'); // 데이터 없을 때 아무것도 반환하지 않습니다.
                                                          }
                                                          // 그리드뷰로 이미지를 출력합니다.
                                                          return GridView.count(
                                                            scrollDirection: Axis.vertical,
                                                            shrinkWrap: true,
                                                            crossAxisCount: 2,
                                                            crossAxisSpacing: 10,
                                                            mainAxisSpacing: 10,
                                                            children: snapshot.data!.docs.map((doc) {
                                                              final imageUrl = doc.get('imageUrl') as String?;
                                                              final uploadDate = doc.get('uploadDate') as String?;
                                                              final uploadUser = doc.get('uploadUser') as String?;
                                                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          content: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                                child: Container(
                                                                                  child: Image.network(
                                                                                    imageUrl,
                                                                                    fit: BoxFit.contain
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 10),
                                                                              Card(

                                                                                color: Colors.grey.shade500,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(10.0),
                                                                                  child: Center(
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text('${uploadUser} :', style: TextStyle(fontSize: 20)),
                                                                                        SizedBox(width: 10),
                                                                                        Text(' ${uploadDate}', style: TextStyle(fontSize: 20))
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 10),
                                                                              // MaterialButton(onPressed: )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                    child: Container(
                                                                      width: MediaQuery.of(context).size.width * 0.4,
                                                                      height: 200,
                                                                      child: Image.network(
                                                                        imageUrl,
                                                                        fit: BoxFit.contain,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return Image.asset('assets/non.png');
                                                              }
                                                            }).toList(),
                                                          );

                                                        }
                                                        return Center(child: CircularProgressIndicator());
                                                      },
                                                    ),


                                                    ],
                                                  ),
                                                const SizedBox(height: 30)]
                                                ),
                                          ),);
                                        },
                                      );
                                    }, // onTap시 화면 중앙에 이미지 출력
                                  ),
                                  // 다른 정보를 표시하려면 여기에 추가
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 이미지를 리스트에 어떻게 대응시킬건지 생각필요.
  Future<String?> getImageUrlForStore(StoreInfo storeInfo) async {
    try {
      // 이미지가 저장된 경로를 파이어베이스 스토리지에서 가져와서 이미지를 다운로드합니다.
      final ref = firebase_storage.FirebaseStorage.instance.ref('images/${storeInfo.id}.png');

      // 다운로드 URL을 가져옵니다.
      final imageUrl = await ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
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


}
// 왜 이렇게 할 생각을 못 했을까.... 리스트뷰 객체 생성.
class StoreInfo {
  final String id;
  final String closingDate;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  String? imagePath;

  StoreInfo({
    required this.id,
    required this.closingDate,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.imagePath
  });
}
