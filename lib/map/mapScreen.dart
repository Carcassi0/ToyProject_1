import 'dart:async';
import 'package:doitflutter/map/setUserLocation.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:intl/intl.dart';
import 'dart:io';

class MyMapScreen extends StatefulWidget {
  const MyMapScreen({Key? key});

  @override
  State<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  String? get docId => '02cA590Y5VJmUMNhHHuj';

  late List<StoreInfo> storeInfos = [];
  final fileformattedDate =
      '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';


  LatLng? _center;
  late CameraController _controller;
  late ScrollController _scrollController = ScrollController();
  late ImagePicker _picker = ImagePicker();
  XFile? _image;
  late String _filePath = '';



  @override
  void initState() {
    super.initState();
    _initializeCenter().then((_) {
      initPath();
      getStoreInfoFromFirestore();
    });
    _picker = ImagePicker();
  }

  Future<void> initPath() async {
    storeInfos.clear(); // 캐시된 데이터를 가져올 수도 있기에 비우는 작업
    await getStoreInfoFromFirestore();
    setState(() {}); // 파일 가져온 이후에 상태 업데이트
  }

  Future<void> _initializeCenter() async {
    setState(() {
      _center = null; // 캐시된 데이터를 가져올 수도 있기에 비우는 작업
    });
    final LatLng center = await setUserLocation(); // setUserLocation 함수를 호출하여 사용자의 위치를 가져옴
    setState(() {
      _center = center; // 사용자의 위치를 _center에 설정
    });
  }

  Future<void> getStoreInfoFromFirestore() async {
    // Firestore 인스턴스 생성
    final firestoreInstance = FirebaseFirestore.instance;

    // storeInfo 컬렉션의 모든 문서 가져오기
    final QuerySnapshot querySnapshot = await firestoreInstance.collection('storeInfo').get();

    // 가져온 문서를 StoreInfo 객체로 변환하여 리스트에 저장
    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final storeInfo = StoreInfo(
        id: data['영업상태명'] as String? ?? '',
        closingDate: data['폐업일자'] as String? ?? '',
        name: data['사업장명'] as String? ?? '',
        latitude: data['좌표정보(y)'] as double? ?? 0.0,
        longitude: data['좌표정보(x)'] as double? ?? 0.0,
        description: data['도로명전체주소'] as String? ?? '',
      );

      final markerPosition = LatLng(storeInfo.latitude, storeInfo.longitude);
      final distance = haversineDistance(_center!, markerPosition);
      if (distance <= 1000) {
        storeInfos.add(storeInfo);
      }
    });
  }


  Future<void> deleteImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('images')
          .where('imageUrl', isEqualTo: '${imageUrl}')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
      Navigator.pop(context);
      Navigator.pop(context);
      showDialog(context: context, builder: (builder) => AlertDialog(
        title: Text('알림', style: GoogleFonts.notoSans(fontSize: 16),),
        content: Text('사진이 삭제되었습니다',style: GoogleFonts.notoSans(fontSize: 13)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      ));
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('삭제 중 에러가 발생했습니다: $error'),
          );
        },
      );
      // 오류 처리 로직 추가 가능
    }
  }




  Widget build(BuildContext context) {
    var height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    void _scrollToListItem(String storeId) {
      // storeInfos에서 storeId에 해당하는 항목을 찾음
      final storeInfo = storeInfos.firstWhere((info) => info.name == storeId);
      final index = storeInfos.indexOf(storeInfo);
      // 스크롤 위치 계산 (항목의 높이 * 인덱스)
      final double scrollPosition = index * height * 0.125;
      _scrollController.jumpTo(scrollPosition);
    }


    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: height,
              width: width,
              child: GoogleMaps(
                  scrollToItem: _scrollToListItem, storeInfos: storeInfos,
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: height * 0.001 * 0.44,
              minChildSize: height * 0.001 * 0.44,
              maxChildSize: height * 0.001 * 0.7,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
      
                  ),
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child:
                          ListView.builder(
                            controller: _scrollController,
                            itemCount: storeInfos.length,
                            itemBuilder: (BuildContext context, int index) {
                              final storeInfo = storeInfos[index];
                              final markerPosition = LatLng(storeInfo.latitude, storeInfo.longitude);
                              final distance = haversineDistance(_center!, markerPosition);

                              if(distance <= 1000) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: ListTile(// 메모 및 영업 이력 확인할 수 있는 페이지로 이동
                                    title: Text(storeInfo.name, style: GoogleFonts.notoSans(),),
                                    subtitle: storeInfo.id == '폐업'
                                      ? Text('폐업일자: ${storeInfo.closingDate}\n${storeInfo.description}',style: GoogleFonts.notoSans())
                                      : Text('등록일자: ${storeInfo.closingDate}\n${storeInfo.description}',style: GoogleFonts.notoSans()),

                                    tileColor: Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    trailing: GestureDetector(
                                      child: const Icon(Icons.image_outlined, size: 35),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3),
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              backgroundColor: Theme.of(context).colorScheme.background,
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 25, bottom: 25),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Column(
                                                  children: <Widget>[

                                                    const SizedBox(height: 20),

                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Text(
                                                        '사진 등록 이력',
                                                        style: GoogleFonts.notoSans(fontSize: 30, fontWeight: FontWeight.w500),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 15),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context).colorScheme.background,
                                                            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
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
                                                            color: Theme.of(context).colorScheme.background,
                                                            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
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
                                                            return Image.asset('assets/non.png', height: 300,width: 300,); // 데이터 없을 때 아무것도 반환하지 않습니다.
                                                          }
                                                          // 그리드뷰로 이미지를 출력합니다.
                                                          return GridView.count(
                                                            physics: NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            childAspectRatio: 1.0,
                                                            crossAxisCount: 2,
                                                            crossAxisSpacing: 2,
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
                                                                          shape: RoundedRectangleBorder(
                                                                              side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3),
                                                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                                                          ),
                                                                          backgroundColor: Theme.of(context).colorScheme.background,
                                                                          content: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                                child: Image.network(
                                                                                  imageUrl,
                                                                                  height: 550,
                                                                                  fit: BoxFit.contain
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 5),
                                                                              Card(
                                                                                color: Theme.of(context).colorScheme.onPrimary,
                                                                                shape: RoundedRectangleBorder(
                                                                                    side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                ),
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

                                                                              SizedBox(height: 2),

                                                                              MaterialButton(
                                                                                  shape: RoundedRectangleBorder(
                                                                                      side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                  ),
                                                                                  onPressed: () async {
                                                                                    await deleteImage(imageUrl);
                                                                                    setState(() {});
                                                                                  },
                                                                                child: Text('사진 삭제',style: TextStyle(fontSize: 18)),
                                                                                color: Theme.of(context).colorScheme.background),

                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    child: Container(

                                                                      height: 200,
                                                                      child: Image.network(
                                                                        imageUrl,
                                                                        fit: BoxFit.cover,
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
                                                    const SizedBox(height: 30)]
                                                    ),
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
                          ),

                  ),
                );
              },
            ),
          ],
        ),
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


