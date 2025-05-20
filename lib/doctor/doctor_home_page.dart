import 'package:flutter/material.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DoctorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(child: Center(child: Text('Doctor Page'))));
  }
}
