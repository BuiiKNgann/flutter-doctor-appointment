// // import 'package:doc_appointment/doctor/doctor_details_page.dart';
// // import 'package:doc_appointment/doctor/model/favorite.dart';
// // import 'package:doc_appointment/doctor/widget/doctor_card.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:doc_appointment/doctor/model/doctor.dart';

// // class FavoriteDoctorsPage extends StatefulWidget {
// //   const FavoriteDoctorsPage({super.key});

// //   @override
// //   State<FavoriteDoctorsPage> createState() => _FavoriteDoctorsPageState();
// // }

// // class _FavoriteDoctorsPageState extends State<FavoriteDoctorsPage> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final DatabaseReference _favoritesDatabase = FirebaseDatabase.instance
// //       .ref()
// //       .child('Favorites');
// //   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
// //       .ref()
// //       .child('Doctors');
// //   List<Doctor> _favoriteDoctors = [];
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchFavoriteDoctors();
// //   }

// //   Future<void> _fetchFavoriteDoctors() async {
// //     String? userId = _auth.currentUser?.uid;
// //     if (userId != null) {
// //       try {
// //         final favoriteDoctorUids = await Favorite.getFavoriteDoctorUids(userId);
// //         List<Doctor> tempDoctors = [];
// //         for (var doctorId in favoriteDoctorUids) {
// //           final doctorSnapshot = await _doctorDatabase.child(doctorId).once();
// //           if (doctorSnapshot.snapshot.value != null) {
// //             Doctor doctor = Doctor.fromMap(
// //               doctorSnapshot.snapshot.value as Map<dynamic, dynamic>,
// //               doctorId,
// //             );
// //             tempDoctors.add(doctor);
// //           }
// //         }
// //         setState(() {
// //           _favoriteDoctors = tempDoctors;
// //           _isLoading = false;
// //         });
// //       } catch (e) {
// //         _showSnackBar(
// //           'Lỗi khi tải danh sách bác sĩ yêu thích: $e',
// //           isError: true,
// //         );
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     } else {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _removeFavoriteDoctor(String doctorUid) async {
// //     final patientUid = _auth.currentUser?.uid;
// //     if (patientUid != null) {
// //       final favorite = Favorite(patientUid: patientUid, doctorUid: doctorUid);
// //       try {
// //         await favorite.removeFromFavorites();
// //         setState(() {
// //           _favoriteDoctors.removeWhere((doctor) => doctor.uid == doctorUid);
// //         });
// //         _showSnackBar('Đã xóa bác sĩ khỏi danh sách yêu thích');
// //       } catch (e) {
// //         _showSnackBar('Lỗi khi xóa bác sĩ: $e', isError: true);
// //       }
// //     }
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: isError ? Colors.red[400] : Colors.green[400],
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         margin: const EdgeInsets.all(16),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(
// //           'Bác sĩ yêu thích',
// //           style: GoogleFonts.poppins(
// //             fontSize: 20,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //       ),
// //       body:
// //           _isLoading
// //               ? const Center(child: CircularProgressIndicator())
// //               : _favoriteDoctors.isEmpty
// //               ? Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(
// //                       Icons.favorite_border_rounded,
// //                       size: 80,
// //                       color: Colors.grey[400],
// //                     ),
// //                     const SizedBox(height: 16),
// //                     Text(
// //                       'Không có bác sĩ yêu thích',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 18,
// //                         color: Colors.grey[600],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               )
// //               : ListView.builder(
// //                 padding: const EdgeInsets.all(8),
// //                 itemCount: _favoriteDoctors.length,
// //                 itemBuilder: (context, index) {
// //                   Doctor doctor = _favoriteDoctors[index];
// //                   return DoctorCard(
// //                     doctor: doctor,
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder:
// //                               (context) => DoctorDetailPage(doctor: doctor),
// //                         ),
// //                       );
// //                     },
// //                     onRemove: () => _removeFavoriteDoctor(doctor.uid),
// //                   );
// //                 },
// //               ),
// //     );
// //   }
// // }
// import 'package:doc_appointment/doctor/doctor_details_page.dart';
// import 'package:doc_appointment/doctor/model/favorite.dart';
// import 'package:doc_appointment/doctor/widget/doctor_card.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:doc_appointment/doctor/model/doctor.dart';

// class FavoriteDoctorsPage extends StatefulWidget {
//   const FavoriteDoctorsPage({super.key});

//   @override
//   State<FavoriteDoctorsPage> createState() => _FavoriteDoctorsPageState();
// }

// class _FavoriteDoctorsPageState extends State<FavoriteDoctorsPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _favoritesDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Favorites');
//   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Doctors');
//   List<Doctor> _favoriteDoctors = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchFavoriteDoctors();
//   }

//   Future<void> _fetchFavoriteDoctors() async {
//     String? userId = _auth.currentUser?.uid;
//     if (userId != null) {
//       try {
//         final favoriteDoctorUids = await Favorite.getFavoriteDoctorUids(userId);
//         List<Doctor> tempDoctors = [];
//         for (var doctorId in favoriteDoctorUids) {
//           final doctorSnapshot = await _doctorDatabase.child(doctorId).once();
//           if (doctorSnapshot.snapshot.value != null) {
//             Doctor doctor = Doctor.fromMap(
//               doctorSnapshot.snapshot.value as Map<dynamic, dynamic>,
//               doctorId,
//             );
//             tempDoctors.add(doctor);
//           }
//         }
//         setState(() {
//           _favoriteDoctors = tempDoctors;
//           _isLoading = false;
//         });
//       } catch (e) {
//         _showSnackBar(
//           'Lỗi khi tải danh sách bác sĩ yêu thích: $e',
//           isError: true,
//         );
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _removeFavoriteDoctor(String doctorUid) async {
//     final patientUid = _auth.currentUser?.uid;
//     if (patientUid != null) {
//       final favorite = Favorite(patientUid: patientUid, doctorUid: doctorUid);
//       try {
//         await favorite.removeFromFavorites();
//         setState(() {
//           _favoriteDoctors.removeWhere((doctor) => doctor.uid == doctorUid);
//         });
//         _showSnackBar('Đã xóa bác sĩ khỏi danh sách yêu thích');
//       } catch (e) {
//         _showSnackBar('Lỗi khi xóa bác sĩ: $e', isError: true);
//       }
//     }
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor: isError ? Colors.red[400] : Colors.green[400],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade600, // Changed background color
//       appBar: AppBar(
//         title: Text(
//           'Bác sĩ yêu thích',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white, // Changed to white for contrast
//           ),
//         ),
//         backgroundColor: Colors.grey.shade800, // Darker shade for app bar
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ), // White icon
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body:
//           _isLoading
//               ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//               : _favoriteDoctors.isEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.favorite_border_rounded,
//                       size: 80,
//                       color:
//                           Colors.grey.shade300, // Lighter shade for visibility
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Không có bác sĩ yêu thích',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         color:
//                             Colors.grey.shade200, // Lighter text for contrast
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : ListView.builder(
//                 padding: const EdgeInsets.all(8),
//                 itemCount: _favoriteDoctors.length,
//                 itemBuilder: (context, index) {
//                   Doctor doctor = _favoriteDoctors[index];
//                   return DoctorCard(
//                     doctor: doctor,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => DoctorDetailPage(doctor: doctor),
//                         ),
//                       );
//                     },
//                     onRemove: () => _removeFavoriteDoctor(doctor.uid),
//                   );
//                 },
//               ),
//     );
//   }
// }
import 'package:doc_appointment/doctor/doctor_details_page.dart';
import 'package:doc_appointment/doctor/model/favorite.dart';
import 'package:doc_appointment/doctor/widget/doctor_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';

class FavoriteDoctorsPage extends StatefulWidget {
  const FavoriteDoctorsPage({super.key});

  @override
  State<FavoriteDoctorsPage> createState() => _FavoriteDoctorsPageState();
}

class _FavoriteDoctorsPageState extends State<FavoriteDoctorsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _favoritesDatabase = FirebaseDatabase.instance
      .ref()
      .child('Favorites');
  final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
      .ref()
      .child('Doctors');
  List<Doctor> _favoriteDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteDoctors();
  }

  Future<void> _fetchFavoriteDoctors() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final favoriteDoctorUids = await Favorite.getFavoriteDoctorUids(userId);
        List<Doctor> tempDoctors = [];
        for (var doctorId in favoriteDoctorUids) {
          final doctorSnapshot = await _doctorDatabase.child(doctorId).once();
          if (doctorSnapshot.snapshot.value != null) {
            Doctor doctor = Doctor.fromMap(
              doctorSnapshot.snapshot.value as Map<dynamic, dynamic>,
              doctorId,
            );
            tempDoctors.add(doctor);
          }
        }
        setState(() {
          _favoriteDoctors = tempDoctors;
          _isLoading = false;
        });
      } catch (e) {
        _showSnackBar(
          'Lỗi khi tải danh sách bác sĩ yêu thích: $e',
          isError: true,
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavoriteDoctor(String doctorUid) async {
    final patientUid = _auth.currentUser?.uid;
    if (patientUid != null) {
      final favorite = Favorite(patientUid: patientUid, doctorUid: doctorUid);
      try {
        await favorite.removeFromFavorites();
        setState(() {
          _favoriteDoctors.removeWhere((doctor) => doctor.uid == doctorUid);
        });
        _showSnackBar('Đã xóa bác sĩ khỏi danh sách yêu thích');
      } catch (e) {
        _showSnackBar('Lỗi khi xóa bác sĩ: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Changed to gray-white background
      appBar: AppBar(
        title: Text(
          'Bác sĩ yêu thích',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87, // Kept dark for contrast
          ),
        ),
        backgroundColor: Colors.white, // White app bar for clean look
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : _favoriteDoctors.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 80,
                      color:
                          Colors
                              .grey
                              .shade400, // Slightly darker for visibility
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có bác sĩ yêu thích',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey.shade700, // Darker text for contrast
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _favoriteDoctors.length,
                itemBuilder: (context, index) {
                  Doctor doctor = _favoriteDoctors[index];
                  return DoctorCard(
                    doctor: doctor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DoctorDetailPage(doctor: doctor),
                        ),
                      );
                    },
                    onRemove: () => _removeFavoriteDoctor(doctor.uid),
                  );
                },
              ),
    );
  }
}
