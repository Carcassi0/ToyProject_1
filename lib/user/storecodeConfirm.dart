import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool storecodeConfirm(storecodetext){
  List<String> storecodeList = ['SZA0000834', 'SZA0001000', 'SZH0000008', 'SZH0000742', 'SZA0000924', '1001085792', '1100018005','SAH0000209',
  '1001092643', '1000047134', '1100024984', '1000028448', '1100016568', '1000032811', '1001350224', 'SZH0000260', 'SZH0000637', '1001525827', '1000032809',
  'SAH0000229', 'SZH0000778', 'SAH0000343', '1100002601', 'SAH0000305', 'SAH0000237', 'SAH0000172', 'SAH0000091', '1000032804', '1000075971', '1001247918',
  '1100014696', 'SAH0000257', 'SAH0000249', '1100015377', 'SAH0000130', 'SAH0000295', 'SAH0000312', 'SAH0000293', 'SAH0000221', 'SZH0000354', 'SZH0000634',
  '1100025861', '1100013770', '1100031596', '1100014731', '1000035082', 'SAH0000178', 'SAH0000174', '1100010807', '1100012614', '1100019363', 'SAH0000257',
  'SZH0000265', 'SZH0000183', 'SZH0000382', '1100023893', '1001426262', 'SAH0000243', '1100034354', 'SAH0000240', 'SZH0000267', 'SZH0000268', 'SZH0000266',
  '1100000933', '1100009032', '1100009109'];

  Set<String> storecodeListSet = storecodeList.toSet();

  String inputString = storecodetext;

  if (storecodeListSet.contains(inputString)){
    return true;
  } else {
    return false;
  }
}