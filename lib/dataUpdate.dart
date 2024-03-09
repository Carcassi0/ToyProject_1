import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

Future<void> downloadCSV() async {
  print('CSV 다운로드 중...');

  final now = DateTime.now();

  final ref = FirebaseStorage.instance.ref().child('${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv');
  final bytes = await ref.getData();

  final formattedDate =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

  // 앱의 로컬 저장소에 파일 저장
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$formattedDate.csv');
  await file.writeAsBytes(bytes as List<int>);

  print('다운로드 완료!');
}
