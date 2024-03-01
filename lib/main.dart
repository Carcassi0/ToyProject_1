import 'dart:io';
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


void main() async { // firebase를 통해 접속하려면 async 필요
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

