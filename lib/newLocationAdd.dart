import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedi_kopo/remedi_kopo.dart';


class newLocationAdd extends StatefulWidget {

  const newLocationAdd({
    Key? key,
  }) : super(key: key);

  @override
  State<newLocationAdd> createState() => _newLocationAddState();
}

class _newLocationAddState extends State<newLocationAdd> {

  final _detailAddresslController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _closedDateController = TextEditingController();
  final _storeStateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};


  @override

  void dispose(){

    _detailAddresslController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _closedDateController.dispose();
    _storeStateController.dispose();

    super.dispose();
  }

  Future signUp() async {
    try {
      if (passwordConfirmed()) {
        // 유저 생성
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _detailAddresslController.text.trim(),
            password: _passwordController.text.trim());

        // 유저 정보
        addUserDetails(
            _nameController.text.trim(),
            _closedDateController.text.trim(),
            _detailAddresslController.text.trim(),
            _storeStateController.text.trim()
        );
      }
    } on FirebaseAuthException catch  (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
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
    if (_passwordController.text.trim() == _addressController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  void _searchAddress(BuildContext context) async {
    KopoModel? model = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );

    if (model != null) {
      final address = model.address ?? '';
      _addressController.value = TextEditingValue(
        text: address,
      );
      formData['address'] = address;
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
            Text('새로운 장소를 추가!',
                style: GoogleFonts.notoSans(
                    fontSize: 40
                )),
            SizedBox(height: 10),
            Text(
              '원하는 장소를 추가하세요',
              style: TextStyle(fontSize: 18),
            ),


            SizedBox(height: 60),

            // 이름 입력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '사업장명',
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      onTap: () async {
                        _searchAddress(context);
                      },
                      readOnly: true,
                      controller: _addressController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '주소',
                      ),
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _detailAddresslController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '세부주소',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 날짜 선택 기능으로 입력하도록 바꿔야함
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _closedDateController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '폐업일자/등록일자',
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('신축', style: TextStyle(fontSize: 18)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('폐업', style: TextStyle(fontSize: 18)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('휴업', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: signUp,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                      child: Text('장소 추가',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18)
                      )
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),

          ],
        ),
      ),
    );
  }
}
