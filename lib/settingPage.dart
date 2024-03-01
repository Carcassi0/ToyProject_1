import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'theme/themeProvider.dart';

class settingPage extends StatelessWidget {
  const settingPage({super.key});

  @override

  Widget build(BuildContext context) {

    double height, width;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.2),
            Text(
              '설정',
              style: GoogleFonts.notoSans(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 70),
            SwitchButtonWithLabel(
              label: '라이트 / 다크모드 전환',
              initialValue: Provider.of<ThemeProvider>(context).isDarkMode(),
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );


  }
}

class SwitchButtonWithLabel extends StatelessWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const SwitchButtonWithLabel({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 20),),
        SizedBox(width: 10),
        Switch(
          activeColor: Colors.white,
          activeTrackColor: Colors.black,
          value: initialValue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

