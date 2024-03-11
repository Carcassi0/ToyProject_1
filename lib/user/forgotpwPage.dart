import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}): super(key: key);


  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final _emailController = TextEditingController();

  @override

  void dispose(){
    _emailController.dispose();
    super.dispose();
  }


  Future passwordReset() async {
    try {
      if(UserCredential == null){
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            content: Text('This Email is not registered'),
          );
        });
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text('Password reset link sent. Check your email'),
        );
      },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(e.message.toString()),
        );
      }
      );
    }
  }


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('가입할 때 사용한 이메일로 \n비밀번호 복구 링크가 전송됩니다.', style: GoogleFonts.notoSans(
            fontSize: 25)),

            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryContainer ),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryContainer ),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  hintText: 'Email', hintStyle: TextStyle(fontSize: 18),
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  filled: true
                ),
              ),
            ),
            SizedBox(height: 20),

            MaterialButton(
              onPressed: passwordReset,
              child: Text('비밀번호 초기화',style: TextStyle(fontSize: 18,color: Colors.white),),
              color: Colors.black
            )
          ],
        ),
      ),
    );
  }
}
