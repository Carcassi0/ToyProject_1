import 'dart:io';
import 'package:doitflutter/dataUpdate.dart';
import 'package:doitflutter/homePage.dart';
import 'package:doitflutter/theme/theme.dart';
import 'package:doitflutter/theme/themeProvider.dart';
import 'package:doitflutter/user/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'user/authPage.dart';
import 'theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async { // firebase를 통해 접속하려면 async 필요
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 파이어베이스 스토리지에서 csv 파일 다운로드
  final prefs = await SharedPreferences.getInstance();
  final lastRun = prefs.getString('lastRun');
  final today = DateTime.now().toIso8601String().substring(0, 10);
  await downloadCSV();

  // if (lastRun == null) {
  //   prefs.setString('lastRun', today);
  // }
  // if (lastRun == today) {
  //   // 09시 30분 이후인지 확인
  //   final now = DateTime.now();
  //   if (now.hour >= 9 && now.minute >= 30) {
  //     await downloadCSV();
  //     prefs.setString('lastRun', today);
  //   }
  // }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return MyHomePage();
          }
          else{
            return const AuthPage();
          }
        },),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

