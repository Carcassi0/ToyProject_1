import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doitflutter/user/storecodeConfirm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'displayMessageToUser.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({
    Key? key,
    required this.showLoginPage,
}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _storecodeController = TextEditingController();


  @override

  void dispose(){

    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _storecodeController.dispose();

    super.dispose();
  }

  Future signUp() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Ensure dialog cannot be dismissed by tapping outside
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      if (passwordConfirmed() && inputConfirmed() && storecodeConfirm(_storecodeController.text.trim())) {
        // 유저 생성
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());

        // 유저 정보
        addUserDetails(
            _firstnameController.text.trim(),
            _lastnameController.text.trim(),
            _emailController.text.trim(),
            _storecodeController.text.trim()
        );
        Navigator.pop(context);
      } else {
      Navigator.pop(context);
      showDialog(context: context, builder: (builder) => AlertDialog(
        title: Text('입력한 정보를 다시 확인하세요', style: GoogleFonts.notoSans(fontSize: 16),),
        content: Text('1.모든 정보를 입력하셨나요?\n2.지점 코드를 정확히 입력하셨나요?',style: GoogleFonts.notoSans(fontSize: 13)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      ));
      }

    } on FirebaseAuthException catch  (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  Future addUserDetails(String firstName, String lastName, String email, String storecode) async {
    await FirebaseFirestore.instance.collection('users').add({
      'first name': firstName ,
      'last name': lastName,
      'email': email,
      'store code': int.tryParse(storecode)
    });
  }

  bool passwordConfirmed(){
    if (_passwordController.text.trim() == _confirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }


  bool inputConfirmed(){
    if (_firstnameController.text.trim() != null
        && _lastnameController.text.trim() != null
        && _storecodeController.text.trim() != null
        && _emailController.text.trim() != null
        && _passwordController.text.trim() != null
        && _confirmpasswordController.text.trim() != null) {
      return true;
    } else {
      return false;
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
            Text('환영합니다!',
                style: GoogleFonts.bebasNeue(
                    fontSize: 50
                )),
            SizedBox(height: 10),
            Text(
              '가입을 위해 모든 정보를 입력하세요',
              style: TextStyle(fontSize: 18),
            ),


            SizedBox(height: 60),

            // 이름 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _firstnameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '이름',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 성 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2,)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _lastnameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '성',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _storecodeController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '지점 코드',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 이메일 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '이메일',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 비밀번호 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '비밀번호',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // 비밀번호 확인
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _confirmpasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '비밀번호 확인',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: signUp,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.black,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                      child: Text('회원가입',
                          style: TextStyle(
                            color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)
                      )
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('이미 가입된 상태라면', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                    onTap: widget.showLoginPage,
                    child: Text(' 로그인', style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))
              ],
            )
          ],
        ),
      ),
    );
  }
}
