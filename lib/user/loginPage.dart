import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'displayMessageToUser.dart';
import 'forgotpwPage.dart';

class loginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const loginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  void signIn() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Ensure dialog cannot be dismissed by tapping outside
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Close the current dialog
      Navigator.pop(context);

      // Show error message to the user
      displayMessageToUser(e.code, context);
    }
  }


  @override

  // 메모리 확보
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 150 ),
            SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '이메일', hintStyle: TextStyle(fontSize: 20)
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
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '비밀번호', hintStyle: TextStyle(fontSize: 20)
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(

                    child: Text('비밀번호를 잊으셨나요?', style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ForgotPasswordPage();
                      }));
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: signIn,
                child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),),


                  child: Center(
                    child: Text('로 그 인',
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20)
                    )
                  ),
                ),
              ),
            ),
            SizedBox(height: 35),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('회원이 아니신가요?', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: widget.showRegisterPage,
                    child: Text(' 가입하기', style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))
              ],
            )
          ],
        ),
      ),
    );
  }
}
