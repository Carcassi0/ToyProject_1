import 'package:flutter/material.dart';

class menuItems extends StatelessWidget {
  const menuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          color: Colors.deepPurple[300],
        ),
        Container(
          height: 50,
          color: Colors.deepPurple[200],
        ),
        Container(
          height: 50,
          color: Colors.deepPurple[100],
        )
      ],
    );
  }
}
