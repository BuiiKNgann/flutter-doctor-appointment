// // import 'package:doc_appointment/doctor/doctor_profile_update.dart';
// // import 'package:doc_appointment/doctor/model/booking.dart';
// // import 'package:doc_appointment/doctor/model/doctor.dart';
// // import 'package:doc_appointment/doctor/model/patient.dart';
// // import 'package:doc_appointment/auth/login_page.dart'; // Import LoginPage
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:flutter/material.dart';

// // class DoctorRequestsPage extends StatefulWidget {
// //   const DoctorRequestsPage({super.key});

// //   @override
// //   State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
// // }

// // class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final DatabaseReference _requestDatabase = FirebaseDatabase.instance
// //       .ref()
// //       .child('Requests');
// //   final DatabaseReference _patientDatabase = FirebaseDatabase.instance
// //       .ref()
// //       .child('Patients');
// //   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
// //       .ref()
// //       .child('Doctors');

// //   List<Booking> _bookings = [];
// //   bool _isLoading = true;
// //   final Map<String, String> _patientNameCache = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchBookings();
// //   }

// //   Future<void> _fetchBookings() async {
// //     String? currentUserId = _auth.currentUser?.uid;
// //     if (currentUserId != null) {
// //       final event =
// //           await _requestDatabase
// //               .orderByChild('receiver')
// //               .equalTo(currentUserId)
// //               .once();
// //       if (event.snapshot.value != null) {
// //         Map<dynamic, dynamic> bookingMap =
// //             event.snapshot.value as Map<dynamic, dynamic>;
// //         _bookings.clear();
// //         bookingMap.forEach((key, value) {
// //           _bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
// //         });
// //       }
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<String> _getPatientFullName(String uid) async {
// //     if (_patientNameCache.containsKey(uid)) {
// //       return _patientNameCache[uid]!;
// //     }

// //     final snapshot = await _patientDatabase.child(uid).once();
// //     if (snapshot.snapshot.value != null) {
// //       final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
// //       final patient = Patient.fromMap(data);
// //       final fullName = '${patient.firstName} ${patient.lastName}';
// //       _patientNameCache[uid] = fullName;
// //       return fullName;
// //     } else {
// //       return 'Không rõ';
// //     }
// //   }

// //   void _handleMenuSelection(String value, BuildContext context) async {
// //     switch (value) {
// //       case 'update_profile':
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => const DoctorProfileUpdatePage(),
// //           ),
// //         );
// //         break;
// //       case 'logout':
// //         try {
// //           await _auth.signOut();
// //           // Navigate to LoginPage and clear the navigation stack
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (context) => const LoginPage()),
// //           );
// //         } catch (e) {
// //           ScaffoldMessenger.of(
// //             context,
// //           ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: $e')));
// //         }
// //         break;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Yêu cầu khám bệnh'),
// //         actions: [
// //           PopupMenuButton<String>(
// //             onSelected: (value) => _handleMenuSelection(value, context),
// //             itemBuilder:
// //                 (BuildContext context) => [
// //                   const PopupMenuItem<String>(
// //                     value: 'update_profile',
// //                     child: Text('Cập nhật thông tin bác sĩ'),
// //                   ),
// //                   const PopupMenuItem<String>(
// //                     value: 'logout',
// //                     child: Text('Đăng xuất'),
// //                   ),
// //                 ],
// //           ),
// //         ],
// //       ),
// //       body:
// //           _isLoading
// //               ? const Center(child: CircularProgressIndicator())
// //               : _bookings.isEmpty
// //               ? const Center(child: Text('Không có yêu cầu nào'))
// //               : ListView.builder(
// //                 itemCount: _bookings.length,
// //                 itemBuilder: (context, index) {
// //                   final booking = _bookings[index];
// //                   return FutureBuilder<String>(
// //                     future: _getPatientFullName(booking.sender),
// //                     builder: (context, snapshot) {
// //                       final fullName = snapshot.data ?? 'Đang tải...';
// //                       return Card(
// //                         margin: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 6,
// //                         ),
// //                         child: ListTile(
// //                           leading: CircleAvatar(child: Text(fullName[0])),
// //                           title: Text(
// //                             fullName,
// //                             style: const TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           subtitle: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 'Mô tả triệu chứng:\n${booking.description}',
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Text(
// //                                 'Ngày: ${booking.date} Giờ: ${booking.time}',
// //                               ),
// //                             ],
// //                           ),
// //                           trailing: Text(
// //                             booking.status,
// //                             style: TextStyle(
// //                               color: _getStatusColor(booking.status),
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           onTap:
// //                               () =>
// //                                   _showStatusDialog(booking.id, booking.status),
// //                         ),
// //                       );
// //                     },
// //                   );
// //                 },
// //               ),
// //     );
// //   }

// //   void _showStatusDialog(String requestId, String currentStatus) {
// //     List<String> statuses = ['Đồng ý', 'Từ chối', 'Hoàn tất'];
// //     String selectedStatus = currentStatus;
// //     TextEditingController reasonController = TextEditingController();
// //     bool showReasonField = false;

// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setState) {
// //             return AlertDialog(
// //               title: const Text('Cập nhật trạng thái yêu cầu'),
// //               content: SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text('Vui lòng chọn trạng thái cho yêu cầu này.'),
// //                     const SizedBox(height: 12),
// //                     ...statuses.map((status) {
// //                       return RadioListTile<String>(
// //                         title: Text(status),
// //                         value: status,
// //                         groupValue: selectedStatus,
// //                         onChanged: (value) {
// //                           setState(() {
// //                             selectedStatus = value!;
// //                             showReasonField = (selectedStatus == 'Từ chối');
// //                           });
// //                         },
// //                       );
// //                     }).toList(),
// //                     if (showReasonField) ...[
// //                       const SizedBox(height: 10),
// //                       TextField(
// //                         controller: reasonController,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Lý do từ chối',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                         maxLines: 3,
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   child: const Text('Hủy'),
// //                 ),
// //                 TextButton(
// //                   onPressed: () async {
// //                     if (selectedStatus == 'Từ chối' &&
// //                         reasonController.text.trim().isEmpty) {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text('Vui lòng nhập lý do từ chối'),
// //                         ),
// //                       );
// //                       return;
// //                     }

// //                     await _updateRequestStatus(
// //                       requestId,
// //                       selectedStatus,
// //                       reasonController.text.trim(),
// //                     );
// //                     Navigator.pop(context);
// //                   },
// //                   child: const Text('Cập nhật'),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'Đồng ý':
// //         return Colors.blue;
// //       case 'Từ chối':
// //         return Colors.red;
// //       case 'Hoàn tất':
// //         return Colors.green;
// //       default:
// //         return Colors.black;
// //     }
// //   }

// //   Future<void> _updateRequestStatus(
// //     String requestId,
// //     String status,
// //     String? reason,
// //   ) async {
// //     Map<String, dynamic> updateData = {'status': status};
// //     if (status == 'Từ chối' && reason != null && reason.isNotEmpty) {
// //       updateData['reason'] = reason;
// //     }
// //     await _requestDatabase.child(requestId).update(updateData);
// //     await _fetchBookings();
// //   }
// // }
// import 'package:doc_appointment/doctor/doctor_profile_update.dart';
// import 'package:doc_appointment/doctor/model/booking.dart';
// import 'package:doc_appointment/doctor/model/doctor.dart';
// import 'package:doc_appointment/doctor/model/patient.dart';
// import 'package:doc_appointment/auth/login_page.dart'; // Import LoginPage
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class DoctorRequestsPage extends StatefulWidget {
//   const DoctorRequestsPage({super.key});

//   @override
//   State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
// }

// class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _requestDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Requests');
//   final DatabaseReference _patientDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Patients');
//   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Doctors');

//   List<Booking> _bookings = [];
//   bool _isLoading = true;
//   final Map<String, String> _patientNameCache = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchBookings();
//   }

//   Future<void> _fetchBookings() async {
//     String? currentUserId = _auth.currentUser?.uid;
//     if (currentUserId != null) {
//       final event =
//           await _requestDatabase
//               .orderByChild('receiver')
//               .equalTo(currentUserId)
//               .once();
//       if (event.snapshot.value != null) {
//         Map<dynamic, dynamic> bookingMap =
//             event.snapshot.value as Map<dynamic, dynamic>;
//         _bookings.clear();
//         bookingMap.forEach((key, value) {
//           _bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
//         });
//       }
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<String> _getPatientFullName(String uid) async {
//     if (_patientNameCache.containsKey(uid)) {
//       return _patientNameCache[uid]!;
//     }

//     final snapshot = await _patientDatabase.child(uid).once();
//     if (snapshot.snapshot.value != null) {
//       final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
//       final patient = Patient.fromMap(data);
//       final fullName = '${patient.firstName} ${patient.lastName}';
//       _patientNameCache[uid] = fullName;
//       return fullName;
//     } else {
//       return 'Không rõ';
//     }
//   }

//   void _handleMenuSelection(String value, BuildContext context) async {
//     switch (value) {
//       case 'update_profile':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const DoctorProfileUpdatePage(),
//           ),
//         );
//         break;
//       case 'logout':
//         try {
//           await _auth.signOut();
//           // Navigate to LoginPage and clear the navigation stack
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginPage()),
//           );
//         } catch (e) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: $e')));
//         }
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         title: const Text(
//           'Yêu cầu khám bệnh',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 8),
//             child: PopupMenuButton<String>(
//               onSelected: (value) => _handleMenuSelection(value, context),
//               icon: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.more_vert, color: Colors.black87),
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 8,
//               itemBuilder:
//                   (BuildContext context) => [
//                     PopupMenuItem<String>(
//                       value: 'update_profile',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, color: Colors.blue[600], size: 20),
//                           const SizedBox(width: 12),
//                           const Text('Cập nhật thông tin bác sĩ'),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'logout',
//                       child: Row(
//                         children: [
//                           Icon(Icons.logout, color: Colors.red[600], size: 20),
//                           const SizedBox(width: 12),
//                           const Text('Đăng xuất'),
//                         ],
//                       ),
//                     ),
//                   ],
//             ),
//           ),
//         ],
//       ),
//       body:
//           _isLoading
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Đang tải dữ liệu...',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                     ),
//                   ],
//                 ),
//               )
//               : _bookings.isEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.calendar_today_outlined,
//                             size: 64,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Không có yêu cầu nào',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Chưa có bệnh nhân nào gửi yêu cầu khám bệnh',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : RefreshIndicator(
//                 onRefresh: _fetchBookings,
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _bookings.length,
//                   itemBuilder: (context, index) {
//                     final booking = _bookings[index];
//                     return FutureBuilder<String>(
//                       future: _getPatientFullName(booking.sender),
//                       builder: (context, snapshot) {
//                         final fullName = snapshot.data ?? 'Đang tải...';
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           child: Material(
//                             elevation: 2,
//                             borderRadius: BorderRadius.circular(16),
//                             color: Colors.white,
//                             child: InkWell(
//                               onTap:
//                                   () => _showStatusDialog(
//                                     booking.id,
//                                     booking.status,
//                                   ),
//                               borderRadius: BorderRadius.circular(16),
//                               child: Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: Border.all(
//                                     color: _getStatusColor(
//                                       booking.status,
//                                     ).withOpacity(0.2),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Header with patient info and status
//                                     Row(
//                                       children: [
//                                         Container(
//                                           width: 50,
//                                           height: 50,
//                                           decoration: BoxDecoration(
//                                             gradient: LinearGradient(
//                                               colors: [
//                                                 Colors.blue[400]!,
//                                                 Colors.blue[600]!,
//                                               ],
//                                               begin: Alignment.topLeft,
//                                               end: Alignment.bottomRight,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               25,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               fullName.isNotEmpty
//                                                   ? fullName[0].toUpperCase()
//                                                   : '?',
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 fullName,
//                                                 style: const TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 12,
//                                                       vertical: 6,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   color: _getStatusColor(
//                                                     booking.status,
//                                                   ).withOpacity(0.1),
//                                                   borderRadius:
//                                                       BorderRadius.circular(20),
//                                                   border: Border.all(
//                                                     color: _getStatusColor(
//                                                       booking.status,
//                                                     ).withOpacity(0.3),
//                                                   ),
//                                                 ),
//                                                 child: Text(
//                                                   booking.status,
//                                                   style: TextStyle(
//                                                     color: _getStatusColor(
//                                                       booking.status,
//                                                     ),
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Icon(
//                                           Icons.arrow_forward_ios,
//                                           color: Colors.grey[400],
//                                           size: 16,
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),

//                                     // Symptoms description
//                                     Container(
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[50],
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.medical_services_outlined,
//                                                 color: Colors.grey[600],
//                                                 size: 18,
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Text(
//                                                 'Mô tả triệu chứng',
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Colors.grey[700],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             booking.description,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[700],
//                                               height: 1.4,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),

//                                     const SizedBox(height: 12),

//                                     // Date and time
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Container(
//                                             padding: const EdgeInsets.all(12),
//                                             decoration: BoxDecoration(
//                                               color: Colors.blue[50],
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                             child: Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.calendar_today,
//                                                   color: Colors.blue[600],
//                                                   size: 16,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   booking.date,
//                                                   style: TextStyle(
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Colors.blue[700],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Container(
//                                             padding: const EdgeInsets.all(12),
//                                             decoration: BoxDecoration(
//                                               color: Colors.orange[50],
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                             child: Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.access_time,
//                                                   color: Colors.orange[600],
//                                                   size: 16,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   booking.time,
//                                                   style: TextStyle(
//                                                     fontSize: 13,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Colors.orange[700],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//     );
//   }

//   void _showStatusDialog(String requestId, String currentStatus) {
//     List<String> statuses = ['Đồng ý', 'Từ chối', 'Hoàn tất'];
//     String selectedStatus = currentStatus;
//     TextEditingController reasonController = TextEditingController();
//     bool showReasonField = false;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               title: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[100],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(Icons.edit_note, color: Colors.blue[600]),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Cập nhật trạng thái yêu cầu',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Vui lòng chọn trạng thái cho yêu cầu này.',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                     const SizedBox(height: 20),
//                     ...statuses.map((status) {
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color:
//                                 selectedStatus == status
//                                     ? _getStatusColor(status).withOpacity(0.5)
//                                     : Colors.grey[300]!,
//                             width: selectedStatus == status ? 2 : 1,
//                           ),
//                           color:
//                               selectedStatus == status
//                                   ? _getStatusColor(status).withOpacity(0.1)
//                                   : Colors.white,
//                         ),
//                         child: RadioListTile<String>(
//                           title: Row(
//                             children: [
//                               Container(
//                                 width: 8,
//                                 height: 8,
//                                 decoration: BoxDecoration(
//                                   color: _getStatusColor(status),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Text(
//                                 status,
//                                 style: TextStyle(
//                                   fontWeight:
//                                       selectedStatus == status
//                                           ? FontWeight.w600
//                                           : FontWeight.normal,
//                                   color:
//                                       selectedStatus == status
//                                           ? _getStatusColor(status)
//                                           : Colors.grey[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           value: status,
//                           groupValue: selectedStatus,
//                           activeColor: _getStatusColor(status),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedStatus = value!;
//                               showReasonField = (selectedStatus == 'Từ chối');
//                             });
//                           },
//                         ),
//                       );
//                     }).toList(),
//                     if (showReasonField) ...[
//                       const SizedBox(height: 16),
//                       Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                         child: TextField(
//                           controller: reasonController,
//                           decoration: const InputDecoration(
//                             labelText: 'Lý do từ chối',
//                             prefixIcon: Icon(Icons.edit_note),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.all(16),
//                           ),
//                           maxLines: 3,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Text(
//                     'Hủy',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (selectedStatus == 'Từ chối' &&
//                         reasonController.text.trim().isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: const Text('Vui lòng nhập lý do từ chối'),
//                           backgroundColor: Colors.red[400],
//                           behavior: SnackBarBehavior.floating,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       );
//                       return;
//                     }

//                     await _updateRequestStatus(
//                       requestId,
//                       selectedStatus,
//                       reasonController.text.trim(),
//                     );
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[600],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Cập nhật',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Đồng ý':
//         return Colors.blue;
//       case 'Từ chối':
//         return Colors.red;
//       case 'Hoàn tất':
//         return Colors.green;
//       default:
//         return Colors.black;
//     }
//   }

//   Future<void> _updateRequestStatus(
//     String requestId,
//     String status,
//     String? reason,
//   ) async {
//     Map<String, dynamic> updateData = {'status': status};
//     if (status == 'Từ chối' && reason != null && reason.isNotEmpty) {
//       updateData['reason'] = reason;
//     }
//     await _requestDatabase.child(requestId).update(updateData);
//     await _fetchBookings();
//   }
// }
import 'package:doc_appointment/doctor/doctor_profile_update.dart';
import 'package:doc_appointment/doctor/model/booking.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';
import 'package:doc_appointment/doctor/model/patient.dart';
import 'package:doc_appointment/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance
      .ref()
      .child('Requests');
  final DatabaseReference _patientDatabase = FirebaseDatabase.instance
      .ref()
      .child('Patients');
  final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
      .ref()
      .child('Doctors');

  List<Booking> _bookings = [];
  bool _isLoading = true;
  final Map<String, String> _patientNameCache = {};

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      final event =
          await _requestDatabase
              .orderByChild('receiver')
              .equalTo(currentUserId)
              .once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> bookingMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        _bookings.clear();
        bookingMap.forEach((key, value) {
          _bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getPatientFullName(String uid) async {
    if (_patientNameCache.containsKey(uid)) {
      return _patientNameCache[uid]!;
    }

    final snapshot = await _patientDatabase.child(uid).once();
    if (snapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      final patient = Patient.fromMap(data);
      final fullName = '${patient.firstName} ${patient.lastName}';
      _patientNameCache[uid] = fullName;
      return fullName;
    } else {
      return 'Không rõ';
    }
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    Navigator.pop(context); // Close menu
    switch (value) {
      case 'update_profile':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, _) => const DoctorProfileUpdatePage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        );
        break;
      case 'logout':
        try {
          await _auth.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi đăng xuất: $e'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        break;
    }
  }

  void _showCustomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Menu header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff0064FA),
                              const Color(0xff0064FA).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Menu',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Menu items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Cập nhật thông tin bác sĩ',
                  subtitle: 'Chỉnh sửa thông tin cá nhân',
                  onTap: () => _handleMenuSelection('update_profile', context),
                  color: Colors.blue,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(),
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản',
                  onTap: () => _handleMenuSelection('logout', context),
                  color: Colors.red,
                  isDestructive: true,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.1), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? color : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Changed to white-gray background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Yêu cầu khám bệnh',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showCustomMenu,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu...',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : _bookings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có yêu cầu nào',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có bệnh nhân nào gửi yêu cầu khám bệnh',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchBookings,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return FutureBuilder<String>(
                      future: _getPatientFullName(booking.sender),
                      builder: (context, snapshot) {
                        final fullName = snapshot.data ?? 'Đang tải...';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            child: InkWell(
                              onTap:
                                  () => _showStatusDialog(
                                    booking.id,
                                    booking.status,
                                  ),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      booking.status,
                                    ).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with patient info and status
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.shade400,
                                                Colors.blue.shade600,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              fullName.isNotEmpty
                                                  ? fullName[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fullName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    booking.status,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: _getStatusColor(
                                                      booking.status,
                                                    ).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  booking.status,
                                                  style: GoogleFonts.poppins(
                                                    color: _getStatusColor(
                                                      booking.status,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey.shade400,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Symptoms description
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.medical_services_outlined,
                                                color: Colors.grey.shade600,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Mô tả triệu chứng',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            booking.description,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Date and time
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.blue.shade600,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  booking.date,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: Colors.orange.shade600,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  booking.time,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.orange.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
    );
  }

  void _showStatusDialog(String requestId, String currentStatus) {
    List<String> statuses = ['Đồng ý', 'Từ chối', 'Hoàn tất'];
    String selectedStatus = currentStatus;
    TextEditingController reasonController = TextEditingController();
    bool showReasonField = currentStatus == 'Từ chối';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.edit_note, color: Colors.blue.shade600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cập nhật trạng thái yêu cầu',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vui lòng chọn trạng thái cho yêu cầu này.',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...statuses.map((status) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                selectedStatus == status
                                    ? _getStatusColor(status).withOpacity(0.5)
                                    : Colors.grey.shade300,
                            width: selectedStatus == status ? 2 : 1,
                          ),
                          color:
                              selectedStatus == status
                                  ? _getStatusColor(status).withOpacity(0.1)
                                  : Colors.white,
                        ),
                        child: RadioListTile<String>(
                          title: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                status,
                                style: GoogleFonts.poppins(
                                  fontWeight:
                                      selectedStatus == status
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      selectedStatus == status
                                          ? _getStatusColor(status)
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          value: status,
                          groupValue: selectedStatus,
                          activeColor: _getStatusColor(status),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                              showReasonField = (selectedStatus == 'Từ chối');
                            });
                          },
                        ),
                      );
                    }).toList(),
                    if (showReasonField) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: reasonController,
                          decoration: const InputDecoration(
                            labelText: 'Lý do từ chối',
                            prefixIcon: Icon(Icons.edit_note),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStatus == 'Từ chối' &&
                        reasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Vui lòng nhập lý do từ chối'),
                          backgroundColor: Colors.red.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                      return;
                    }
                    await _updateRequestStatus(
                      requestId,
                      selectedStatus,
                      reasonController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Cập nhật',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đồng ý':
        return Colors.blue;
      case 'Từ chối':
        return Colors.red;
      case 'Hoàn tất':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  Future<void> _updateRequestStatus(
    String requestId,
    String status,
    String? reason,
  ) async {
    Map<String, dynamic> updateData = {'status': status};
    if (status == 'Từ chối' && reason != null && reason.isNotEmpty) {
      updateData['reason'] = reason;
    }
    await _requestDatabase.child(requestId).update(updateData);
    await _fetchBookings();
  }
}
