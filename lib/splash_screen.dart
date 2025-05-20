// import 'package:doc_appointment/auth/login_page.dart';
// import 'package:doc_appointment/doctor/doctor_home_page.dart';
// import 'package:doc_appointment/patient/patient_home_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<SplashScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // _checkAuthUser();
//   }

//   Future<void> _checkAuthUser() async {
//     User? user = _auth.currentUser;
//     if (user == null) {
//       await Future.delayed(Duration(seconds: 3));
//       _navigateToLogin();
//     } else {
//       DatabaseReference userRef = _database.child("Doctor").child(user.uid);
//       DataSnapshot snapshot = await userRef.get();
//       if (snapshot.exists) {
//         await Future.delayed(Duration(seconds: 3));
//         _navigateToDoctorHomePage();
//       } else {
//         userRef = _database.child("Patient").child(user.uid);
//         snapshot = await userRef.get();
//         if (snapshot.exists) {
//           await Future.delayed(Duration(seconds: 3));
//           _navigateToPatientHomePage();
//         } else {
//           await Future.delayed(Duration(seconds: 3));
//           _navigateToLogin();
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           color: Color(0xff0064FA),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0, right: 10.0),
//                   child: Text(
//                     'D+',
//                     style: GoogleFonts.poppins(
//                       fontSize: 48,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 650),
//                   child: Text(
//                     textAlign: TextAlign.end,
//                     'Transforming\nHealthcare',
//                     style: GoogleFonts.poppins(
//                       fontSize: 28,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),

//                 Image.asset(
//                   'assets/images/dna_image.png',
//                   width: MediaQuery.of(context).size.width,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToLogin() {
//     Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (context) => LoginPage()));
//   }

//   void _navigateToDoctorHomePage() {
//     Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (context) => DoctorHomePage()));
//   }

//   void _navigateToPatientHomePage() {
//     Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (context) => PatientHomePage()));
//   }
// }
import 'package:doc_appointment/auth/login_page.dart';
import 'package:doc_appointment/doctor/doctor_home_page.dart';
import 'package:doc_appointment/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthUser();
    });
  }

  Future<void> _checkAuthUser() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        await Future.delayed(const Duration(seconds: 3));
        _navigateToLogin();
      } else {
        DatabaseReference userRef = _database.child("Doctor").child(user.uid);
        DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          await Future.delayed(const Duration(seconds: 3));
          _navigateToDoctorHomePage();
        } else {
          userRef = _database.child("Patient").child(user.uid);
          snapshot = await userRef.get();
          if (snapshot.exists) {
            await Future.delayed(const Duration(seconds: 3));
            _navigateToPatientHomePage();
          } else {
            await Future.delayed(const Duration(seconds: 3));
            _navigateToLogin();
          }
        }
      }
    } catch (e) {
      print("Error checking user: $e");
      await Future.delayed(const Duration(seconds: 3));
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xff0064FA),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Chuyển sang bên trái
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 10.0),
                child: Align(
                  alignment: Alignment.topRight, // Đặt "D+" ở góc phải
                  child: Text(
                    'D+',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  'Transforming\nHealthcare',
                  style: GoogleFonts.poppins(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20), // Khoảng cách giữa chữ và hình
              Image.asset(
                'assets/images/dna_image.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _navigateToDoctorHomePage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const DoctorHomePage()));
  }

  void _navigateToPatientHomePage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PatientHomePage()));
  }
}
