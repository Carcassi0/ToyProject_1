import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




void displayMessageToUser(String message, BuildContext context){
  String printMessage= '';
  // Login Error
  if(message == 'invalid-credential'){
    printMessage = '이메일 또는 비밀번호를 다시 입력하세요';
  }
  else if (message == 'wrong-password'){
    printMessage = '이메일 또는 비밀번호를 다시 입력하세요';
  }
  else if (message == 'too-many-requests'){
    printMessage = '잠시 후 다시 시도하세요';
  }
  else if (message == 'wrong-password'){
    printMessage = '이메일 또는 비밀번호를 다시 입력하세요';
  }
  // Register Error
  else if (message == 'email-already-exists'){
    printMessage = '사용 중인 이메일입니다.';
  }
  else if (message == 'invalid-password'){
    printMessage = '비밀번호는 최소 6자리 이상이여야 합니다';
  }
  else if (message == 'wrong-password'){
    printMessage = '이메일 또는 비밀번호를 다시 입력하세요';
  }
  // forgotpwPage
  else if (message == 'user-not-found'){
    printMessage = '해당 이메일로 가입된 유저가 존재하지 않습니다';
  }
  // etc
  else{printMessage = '알 수 없는 오류입니다.';}

  showDialog(context: context, builder: (builder) => AlertDialog(
    title: Text(printMessage, style: GoogleFonts.notoSans(fontSize: 14),),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))
    ),
  ));
}