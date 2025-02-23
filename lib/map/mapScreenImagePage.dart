import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../camera.dart';
import 'mapScreen.dart';

class ImageUploadPage extends StatefulWidget {
  final List<StoreInfo> storeInfos;

  ImageUploadPage({required this.storeInfos});
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  String? get docId => '02cA590Y5VJmUMNhHHuj';

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


  Future<void> _uploadImage(ImageSource source, StoreInfo storeInfo) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final now = DateTime.now();
    final formattedDate = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final temporaryPath = join((await getTemporaryDirectory()).path, '${storeInfo.name}_$formattedDate.png');

    final selectedImage = image;
    await selectedImage?.saveTo(temporaryPath);

    // 이미지 업로드 후의 작업 수행
    // 예를 들어, 업로드된 이미지 경로를 다른 페이지에 전달하는 등의 작업을 수행할 수 있습니다.

    Navigator.pushReplacement(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: temporaryPath, selectedImage: selectedImage)),
    );
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('사진 등록 이력', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            FutureBuilder<QuerySnapshot>(

              future: FirebaseFirestore.instance
                    .collection('images')
                    .where('storeName', isGreaterThanOrEqualTo: '${widget.storeInfos.first.name}_')
                    .where('storeName', isLessThan: '${widget.storeInfos.first.name}_\uf8ff')
                    .get(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Image.asset('assets/non.png'); // 에러 발생 시 아무것도 반환하지 않습니다.
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Image.asset('assets/non.png'); // 데이터 없을 때 아무것도 반환하지 않습니다.
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final imageUrl = doc.get('imageUrl') as String?;
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return Image.network(imageUrl); // 이미지를 보여줍니다.
                      } else {
                        return Image.asset('assets/non.png'); // 이미지가 없는 경우 빈 SizedBox를 반환합니다.
                      }
                    }).toList(),
                  );
                }
                return CircularProgressIndicator(); // 데이터를 가져오는 동안 로딩 표시기를 표시합니다.
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

}
// 왜 이렇게 할 생각을 못 했을까.... 리스트뷰 객체 생성.
