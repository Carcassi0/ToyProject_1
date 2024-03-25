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
import 'mapScreen.dart';


class imageViewer extends StatelessWidget {
  final String imageUrl;
  final String ?uploadDate;
  final String ?uploadUser;


  const imageViewer({Key? key, required this.imageUrl, required this.uploadDate, required this.uploadUser}) : super(key: key);

  @override

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
    } catch (error) {
      // 오류 처리 로직 추가 가능
    }
  }


  Widget build(BuildContext context) {
    var height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('$uploadDate ($uploadUser)', style: GoogleFonts.notoSans(fontWeight: FontWeight.w400)),
        leading: IconButton(
          icon: Icon(Icons.close_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_outline_outlined),
            onPressed: () async {

              final overlay = Overlay.of(context);
              final indicator = OverlayEntry(
                builder: (context) => Center(child: CircularProgressIndicator()),
              );
              overlay.insert(indicator);

              await deleteImage(imageUrl);

              indicator.remove();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyMapScreen()
                  )
              );

              showDialog(
                context: context,
                builder: (builder) => AlertDialog(
                  title: Text('알림', style: GoogleFonts.notoSans(fontSize: 16),),
                  content: Text('사진이 정상적으로 삭제되었습니다.',style: GoogleFonts.notoSans(fontSize: 13)),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Image.network(imageUrl, fit: BoxFit.scaleDown,)),
          ],
        ),
      ),
    );
  }

}