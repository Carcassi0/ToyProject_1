import 'package:camera/camera.dart';
import 'package:doitflutter/map/mapScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:exif/exif.dart';





class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final XFile selectedImage;


  const DisplayPictureScreen({Key? key, required this.imagePath, required this.selectedImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      appBar: AppBar(
        title: Text(
            '업로드', style: GoogleFonts.notoSans(fontWeight: FontWeight.w400)),
        leading: IconButton(
          icon: Icon(Icons.close_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check_outlined),
            onPressed: () async {
              // 이미지 업로드 진행 출력
              final overlay = Overlay.of(context);
              final indicator = OverlayEntry(
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );
              overlay.insert(indicator);

              // getExifFromFile();

              // final captureDate = await getCapturedDate(imagePath); // 에러 발생 => exif 데이터 내에 촬영날짜 데이터가 없음.


              // 이미지를 var 형으로 받아와야 하는데 현재 이미지의 경로를 저장하고 있음.

              final imageUrl = await uploadImageToFirebaseStorage(imagePath);

              saveImageUrlToFirestore(imageUrl, imagePath, getExifFromFile());

              indicator.remove();

              Navigator.pop(context, imageUrl);

              showDialog(
                context: context,
                builder: (builder) =>
                    AlertDialog(
                      title: Text(
                        '알림', style: GoogleFonts.notoSans(fontSize: 16),),
                      content: Text('사진이 정상적으로 업로드되었습니다.',
                          style: GoogleFonts.notoSans(fontSize: 13)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                    ),
              );
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
      imagePath.replaceFirst('.png', '_compressed.jpg'), // 파일 이름을 .jpg로 변경합니다.
      quality: 20, // 품질을 20%로 설정합니다.
    );

    // Firebase Storage에 압축된 이미지를 업로드합니다.
    final fileName = p.basename(compressedImage!.path); // 파일 이름을 가져옵니다.
    final ref = firebase_storage.FirebaseStorage.instance.ref().child(
        'images/$fileName'); // 파일 이름을 .jpg로 변경합니다.
    final uploadTask = ref.putFile(File(compressedImage!.path));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> saveImageUrlToFirestore(String imageUrl, String imagePath,
      Future<String> captureDate) async {
    final fileName = p.withoutExtension(p.basename(imagePath));
    final String date = await captureDate;

    // Firebase Firestore에 이미지 URL을 저장합니다.
    FirebaseFirestore.instance.collection('images').add({
      'storeName': fileName,
      'imageUrl': imageUrl,
      'uploadDate': date,
      'uploadUser': '위의종'
    });
  }

  Future<String> getExifFromFile() async{
    if(selectedImage == null){
      print("exif is empty");
      return "";
    }
    var bytes = await selectedImage!.readAsBytes();
    var tags = await readExifFromBytes(bytes);
    var sb = StringBuffer();
    tags.forEach((k,v){
      print("$k: $v\n");
      sb.write("$k: $v\n");
    });

    if (tags.containsKey('EXIF DateTimeOriginal')) {
      String dateTimeOriginal = tags['EXIF DateTimeOriginal']?.toString() ?? '';
      String formattedDateTime = _formatDateTime(dateTimeOriginal);
      print("Formatted DateTimeOriginal: $formattedDateTime");
      sb.write("Formatted DateTimeOriginal: $formattedDateTime\n");
      return formattedDateTime;
    }
    return sb.toString();
  }


  // Future<DateTime?> getCapturedDate(String temporaryPath) async {
  //   // 이미지 파일 읽기
  //   final imageFile = File(temporaryPath);
  //   final exifData = await readExifFromBytes(imageFile.readAsBytesSync());
  //
  //   // EXIF 데이터 체크
  //   exifData.forEach((key, value) {
  //     print('$key: $value');
  //   });
  //
  //   // EXIF 데이터에서 촬영 날짜 추출
  //   final dateTime = exifData['DateTimeOriginal'];
  //   if (dateTime != null) {
  //     // 사용자 정의 파서를 사용하여 날짜 문자열 파싱
  //     final parsedDateTime = parseCustomDateTime(dateTime.toString());
  //     if (parsedDateTime != null) {
  //       return parsedDateTime;
  //     } else {
  //       // 오류 처리
  //       print('Failed to parse date time.');
  //       return null;
  //     }
  //   } else {
  //     return null;
  //   }
  // }

  String _formatDateTime(String dateTime) {
    // EXIF 날짜 형식: YYYY:MM:DD HH:MM:SS
    List<String> dateTimeParts = dateTime.split(' ');
    String datePart = dateTimeParts[0];
    String timePart = dateTimeParts[1];

    // 날짜 부분을 ':'로 분할
    List<String> dateComponents = datePart.split(':');
    String year = dateComponents[0].substring(2);  // 두 자리 연도
    String month = dateComponents[1];
    String day = dateComponents[2];

    // 시간 부분을 ':'로 분할
    List<String> timeComponents = timePart.split(':');
    String hour = timeComponents[0];
    String minute = timeComponents[1];

    return "$year.$month.$day $hour:$minute";
  }

// 사용자 정의 파서
//   DateTime? parseCustomDateTime(String dateTimeString) {
//     try {
//       final parts = dateTimeString.split(' ');
//       final dateParts = parts[0].split(':');
//       final timeParts = parts[1].split(':');
//
//       final year = int.parse(dateParts[0]);
//       final month = int.parse(dateParts[1]);
//       final day = int.parse(dateParts[2]);
//       final hour = int.parse(timeParts[0]);
//       final minute = int.parse(timeParts[1]);
//       final second = int.parse(timeParts[2]);
//
//       return DateTime(year, month, day, hour, minute, second);
//     } catch (e) {
//       print('Error parsing date time: $e');
//       return null;
//     }
//   }


// Future<DateTime?> getCapturedDate(String temporaryPath) async {
  //   // 이미지 파일 읽기
  //   final imageFile = File(temporaryPath);
  //   final exifData = await readExifFromBytes(imageFile.readAsBytesSync());
  //
  //   exifData.forEach((key, value) {
  //     print('$key: $value');
  //   });
  //
  //   // EXIF 데이터에서 촬영 날짜 추출
  //   final dateTime = exifData['Image DateTime'];
  //   if (dateTime != null) {
  //     return DateTime.parse(dateTime.toString());
  //   } else {
  //     return null;
  //   }
  // }

}





