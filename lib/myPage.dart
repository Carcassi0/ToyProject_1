import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doitflutter/user/forgotpwPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'theme/themeProvider.dart';

class myPage extends StatelessWidget {
  const myPage({super.key});

  @override
  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty){
      final lastName = snapshot.docs.first['last name'];
      final firstName = snapshot.docs.first['first name'];
      return '$lastName$firstName';
    } else {
      return 'Unknown User';
    }
  }

  Future<String> _getUserStoreId() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty){
      final storeCode = snapshot.docs.first['store code'];
      return '$storeCode';
    } else {
      return 'Unknown User';
    }
  }

  Widget build(BuildContext context) {

    double height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.2),

            Container(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text(
                        '마이페이지',
                        style: GoogleFonts.notoSans(fontSize: 50, fontWeight: FontWeight.bold),),

                      SizedBox(height: 70),

                      FutureBuilder(
                        future: _getUserName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                                '사용자: ${snapshot.data}',
                                style: GoogleFonts.notoSans(fontSize: 20)
                            );
                          }
                          },
                      ),

                      SizedBox(height: 20),

                      Text(
                          '이메일: ${user.email!}',
                          style: GoogleFonts.notoSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,)),

                      SizedBox(height: 20),

                      FutureBuilder(
                        future: _getUserStoreId(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                                '매장 코드: ${snapshot.data}',
                                style: GoogleFonts.notoSans(fontSize: 20)
                            );}},),

                      SizedBox(height: 200),

                      MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                            );
                          },
                          child: Text('비밀번호 초기화',style: TextStyle(fontSize: 18),),
                          color: Theme.of(context).colorScheme.primaryContainer
                      )
                    ],
                  ),
                )
            ),


          ],
        ),
      ),
    );


  }
}



