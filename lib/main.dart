import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(VolunteerApp());
}

class VolunteerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ghosn  ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: Directionality(  // إضافة اتجاه من اليمين لليسار
        textDirection: TextDirection.rtl,
        child: LoginPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}/

