import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

void downloadCSV() async {
  // Firebase Storage에서 파일 다운로드
  final ref = FirebaseStorage.instance.ref().child('your_file.csv');
  final bytes = await ref.getData();

  // 앱의 로컬 저장소에 파일 저장
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/your_file.csv');
  await file.writeAsBytes(bytes);

  // CSV 파일 읽기
  final csvFile = await File(file.path).openRead();
  final fields = await csvFile.transform(utf8.decoder).transform(CsvToListConverter()).toList();

  // 이제 'fields' 변수를 사용하여 CSV 데이터를 사용할 수 있습니다.
}
