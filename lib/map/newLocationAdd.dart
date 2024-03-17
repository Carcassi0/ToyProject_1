import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doitflutter/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:geocoding/geocoding.dart';


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

  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _dateFormKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  List<bool> isSelected = [false, false, false];
  late String selected = '';
  late double longitude = 0.0;
  late double latitude = 0.0;

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

  Future addStoreInfo() async {
    try {
      showDialog(context: context, builder: (context) {
        return Center(child: CircularProgressIndicator());
      });

      final coordinates = await convertAddressToCoordinates(_addressController.text.trim());
      if (coordinates.isNotEmpty) {
        longitude = coordinates[1];
        latitude = coordinates[0];
      }
      await addNewStore(
        _nameController.text.trim(),
        _addressController.text.trim(),
        _detailAddresslController.text.trim(),
        _closedDateController.text.trim(),
        selected,
        longitude,
        latitude,
      );

      Navigator.of(context).pop();

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text("알림"),
            content: Text("새로운 장소를 추가했습니다."),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }




  Future addNewStore(String storeName, String address, String detailAddress, String closedDate, String storeState, double longitude, double latitude) async {
    await FirebaseFirestore.instance.collection('storeInfo').add({

      '도로명전체주소': address+' '+detailAddress,
      '사업장명': storeName,
      '영업상태명': storeState,
      '폐업일자': closedDate,
      '좌표정보(x)': longitude,
      '좌표정보(y)': latitude

    });
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
        if(value != null){
          final date = '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
          _closedDateController.value = TextEditingValue(
            text: date
          );
        }
      });
    });
  }

  void storeState(int selectedIndex) {
    if (selectedIndex == 0) {
      selected = '신축';
    } else if (selectedIndex == 1) {
      selected = '폐업';
    } else if (selectedIndex == 2) {
      selected = '휴업';
    }
  }


  Future<List<double>> convertAddressToCoordinates(String address) async {
    try {
      final geocodingPlatform = GeocodingPlatform.instance;
      if (geocodingPlatform != null) {
        final locations = await geocodingPlatform.locationFromAddress(address);
        final latitude = locations.isNotEmpty ? locations[0].latitude : 0.0;
        final longitude = locations.isNotEmpty ? locations[0].longitude : 0.0;
        return [latitude, longitude];
      } else {
        print('Error: GeocodingPlatform.instance is null');
        return [0.0, 0.0]; // 기본값 반환
      }
    } catch (e) {
      print('Error: GeoCoding');
      return [0.0, 0.0]; // 예외 발생 시 기본값 반환
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
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
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
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Form(
                    key: _addressFormKey,
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
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
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
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Form(
                    key: _dateFormKey,
                    child: TextFormField(
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
            ),

            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1.7),
                ),
                  child:
                  ToggleButtons(
                      renderBorder: false,
                      isSelected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.onInverseSurface,
                      fillColor: Theme.of(context).colorScheme.inverseSurface,
                      splashColor: Theme.of(context).colorScheme.background,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      borderRadius: BorderRadius.circular(19),
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
                          for (int index = 0; index < isSelected.length; index++) {
                            isSelected[index] = index == newIndex;
                          }
                          storeState(newIndex);
                        });
                      }
                  )
              ),
            ),

            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: addStoreInfo,
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
