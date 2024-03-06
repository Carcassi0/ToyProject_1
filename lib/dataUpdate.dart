import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

void downloadCSV() async {
  // Firebase Storage에서 파일 다운로드
  // Firebase Storage에서 파일 참조할 때는 폴더명 필요 없음. 원래 폴더가 하나인 구조인데, 콘솔에서 나누어 볼 수 있는 것.
  final now = DateTime.now();

  final ref = FirebaseStorage.instance.ref().child('${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv');
  final bytes = await ref.getData();

  final formattedDate =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

  // 앱의 로컬 저장소에 파일 저장
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$formattedDate.csv');
  await file.writeAsBytes(bytes as List<int>);

}
