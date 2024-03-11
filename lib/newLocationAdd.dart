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
  List<bool> isSelected = [true, false, false];

  DateTime _dateTime = DateTime.now();


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
            _addressController.text.trim(),
            _detailAddresslController.text.trim(),
            _closedDateController.text.trim(),
        );
      }
    } on FirebaseAuthException catch  (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  Future addUserDetails(String storeName, String address, String detailAddress, String closedDate) async {
    await FirebaseFirestore.instance.collection('storeInfo').add({

      '도로명전체주소': address+' ('+detailAddress+')',
      '사업장명': storeName,
      '폐업일자': closedDate,

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
  void _showDatePicker(){
    showDatePicker(context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030)
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
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
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
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
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
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
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
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
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    onTap: _showDatePicker,
                    readOnly: true,
                    controller: _closedDateController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '폐업일자/등록일자',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                  child:
                  ToggleButtons(
                      renderBorder: false,
                      isSelected: isSelected,
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).colorScheme.primary,
                      splashColor: Theme.of(context).colorScheme.secondaryContainer,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      borderRadius: BorderRadius.circular(20),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 41),
                          child: Text('신축', style: GoogleFonts.notoSans(fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 41),
                          child: Text('폐업', style: GoogleFonts.notoSans(fontSize: 18)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 41),
                          child: Text('휴업', style: GoogleFonts.notoSans(fontSize: 18)),
                        ),
                      ],
                      onPressed: (int newIndex) {
                        setState(() {
                      // looping through the list of booleans values
                      for (int index = 0; index < isSelected.length; index++) {
                        if (index == newIndex) {
                          isSelected[index] = true;
                        } else {
                          // other two will be set to false and not selected
                          isSelected[index] = false;
                        }
                      }
                    });
                  })
              ),
            ),

            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: signUp,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black)),

                  child: Center(
                      child: Text('장소 추가',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
