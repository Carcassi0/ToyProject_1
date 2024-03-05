import 'package:camera/camera.dart';
import 'package:doitflutter/map/mapScreen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';





class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('이미지 업로드', style: GoogleFonts.bebasNeue(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {

              // 이미지 업로드 진행 출력
              final overlay = Overlay.of(context);
              final indicator = OverlayEntry(
                builder: (context) => Center(child: CircularProgressIndicator()),
              );
              overlay.insert(indicator);

              final imageUrl = await uploadImageToFirebaseStorage(imagePath);

              saveImageUrlToFirestore(imageUrl, imagePath);

              indicator.remove();

              Navigator.pop(context, imageUrl);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(File(imagePath)),
          ],
        ),
      ),
    );
  }




  Future<String> uploadImageToFirebaseStorage(String imagePath) async {
    // 이미지를 압축합니다.
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      imagePath.replaceFirst('.png', '_compressed.jpg'),  // 파일 이름을 .jpg로 변경합니다.
      quality: 20,  // 품질을 20%로 설정합니다.
    );

    // Firebase Storage에 압축된 이미지를 업로드합니다.
    final fileName = p.basename(compressedImage!.path);  // 파일 이름을 가져옵니다.
    final ref = firebase_storage.FirebaseStorage.instance.ref().child('images/$fileName');    // 파일 이름을 .jpg로 변경합니다.
    final uploadTask = ref.putFile(File(compressedImage!.path));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void saveImageUrlToFirestore(String imageUrl, String imagePath) {
    final fileName = p.withoutExtension(p.basename(imagePath));
    final now = DateTime.now();
    // Firebase Firestore에 이미지 URL을 저장합니다.
    FirebaseFirestore.instance.collection('images').add({
      'storeName' : fileName,
      'imageUrl': imageUrl,
      'uploadDate': '${now.month.toString().padLeft(2, '0')}월 ${now.day.toString().padLeft(2, '0')}일 ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      'uploadUser': '위의종'
      // 다른 필드에 대한 추가 정보를 저장할 수 있습니다.
    });
  }
}


class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraPreviewScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카메라 미리보기'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final path = p.join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            final image = await _controller.takePicture();

            // 이미지를 path에 저장.
            await image.saveTo(path);

            // 이미지 업로드 화면으로 이동하여 이미지 업로드 처리
            final uploadedImagePath = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );

            // 이미지가 업로드된 경로가 반환되면 Firebase Firestore에 저장.
            if (uploadedImagePath != null) {
              await _uploadImageToFirebaseStorage(uploadedImagePath);
              AlertDialog(
                title: Text('이미지가 업로드 되었습니다'),
                content: GestureDetector(
                  child: Text('닫기'),
                  onTap: (){Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MyMapScreen()));
                  }
                ),
              );
            }
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

  }
  // 이미지를 Firebase Storage에 업로드하고 Firestore에 이미지 URL을 저장합니다.
  Future<void> _uploadImageToFirebaseStorage(String imagePath) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
      final uploadTask = ref.putFile(File(imagePath));
      await uploadTask.whenComplete(() => null);
      final downloadUrl = await ref.getDownloadURL();

      // Firestore에 이미지 URL을 저장합니다.
      await FirebaseFirestore.instance.collection('images').add({
        'imageUrl': downloadUrl,
      });

    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }
}

