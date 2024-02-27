import 'package:flutter/material.dart';

class settingPage extends StatelessWidget {
  const settingPage({super.key});

  @override

  Widget build(BuildContext context) {

    double height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 70),
              const Text('설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),),
              const SizedBox(height: 70),
              Stack(
                children:[
                  Container(height: height*0.9,
                  decoration: BoxDecoration(color: const Color.fromRGBO(255, 190, 152, 1),
                  borderRadius: BorderRadius.circular(30))),

                  Container(height: 20, width: 30, decoration:BoxDecoration (color: Colors.black,
                      borderRadius: BorderRadius.circular(30))
                  )
                  ]
              )

            ],
          ),
        ),
      )
    );
  }
}
