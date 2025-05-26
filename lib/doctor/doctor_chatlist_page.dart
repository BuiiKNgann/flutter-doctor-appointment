// import 'package:doc_appointment/doctor/model/patient.dart';
// import 'package:doc_appointment/patient/patient_home_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:doc_appointment/chat_screen.dart';

// class DoctorChatlistPage extends StatefulWidget {
//   const DoctorChatlistPage({super.key});

//   @override
//   State<DoctorChatlistPage> createState() => _DoctorChatlistPageState();
// }

// class _DoctorChatlistPageState extends State<DoctorChatlistPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _chatListDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('ChatList');
//   final DatabaseReference _patientsDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Patients');
//   List<Patient> _chatList = []; // Sửa từ PatientHomePage thành Patient
//   bool _isLoading = true;
//   late String doctorId;

//   @override
//   void initState() {
//     super.initState();
//     doctorId = _auth.currentUser?.uid ?? '';
//     _fetchChatList();
//   }

//   Future<void> _fetchChatList() async {
//     if (doctorId.isNotEmpty) {
//       try {
//         final DatabaseEvent event =
//             await _chatListDatabase.child(doctorId).once();
//         DataSnapshot snapshot = event.snapshot;
//         List<Patient> tempChatList = [];

//         if (snapshot.value != null) {
//           Map<dynamic, dynamic> values =
//               snapshot.value as Map<dynamic, dynamic>;

//           for (var userId in values.keys) {
//             final DatabaseEvent patientEvent =
//                 await _patientsDatabase.child(userId).once();
//             DataSnapshot patientSnapshot = patientEvent.snapshot;
//             if (patientSnapshot.value != null) {
//               Map<dynamic, dynamic> patientMap =
//                   patientSnapshot.value as Map<dynamic, dynamic>;
//               tempChatList.add(
//                 Patient.fromMap(Map<String, dynamic>.from(patientMap)),
//               );
//             }
//           }
//         }
//         setState(() {
//           _chatList = tempChatList;
//           _isLoading = false;
//         });
//       } catch (error) {
//         // Xử lý lỗi, ví dụ: in lỗi hoặc hiển thị thông báo
//         print('Lỗi khi lấy danh sách chat: $error');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Chat with')),
//       body:
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _chatList.isEmpty
//               ? Center(child: Text('No chats available'))
//               : ListView.builder(
//                 itemCount: _chatList.length,
//                 itemBuilder: (context, index) {
//                   final patient = _chatList[index];
//                   return Card(
//                     elevation: 2.0,
//                     margin: EdgeInsets.symmetric(
//                       vertical: 8.0,
//                       horizontal: 16.0,
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         'Chat with ${patient.firstName} ${patient.lastName}',
//                       ),
//                       onTap: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => ChatScreen(
//                                   doctorId: doctorId,
//                                   patientId: patient.uid,
//                                   patientName:
//                                       '${patient.firstName} ${patient.lastName}',
//                                 ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }
import 'package:doc_appointment/doctor/doctor_profile_update.dart';
import 'package:doc_appointment/doctor/model/patient.dart';
import 'package:doc_appointment/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_appointment/chat_screen.dart';

class DoctorChatlistPage extends StatefulWidget {
  const DoctorChatlistPage({super.key});

  @override
  State<DoctorChatlistPage> createState() => _DoctorChatlistPageState();
}

class _DoctorChatlistPageState extends State<DoctorChatlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListDatabase = FirebaseDatabase.instance
      .ref()
      .child('ChatList');
  final DatabaseReference _patientsDatabase = FirebaseDatabase.instance
      .ref()
      .child('Patients');
  List<Patient> _chatList = [];
  bool _isLoading = true;
  late String doctorId;

  @override
  void initState() {
    super.initState();
    doctorId = _auth.currentUser?.uid ?? '';
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    if (doctorId.isNotEmpty) {
      try {
        final DatabaseEvent event =
            await _chatListDatabase.child(doctorId).once();
        DataSnapshot snapshot = event.snapshot;
        List<Patient> tempChatList = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> values =
              snapshot.value as Map<dynamic, dynamic>;
          for (var userId in values.keys) {
            final DatabaseEvent patientEvent =
                await _patientsDatabase.child(userId).once();
            DataSnapshot patientSnapshot = patientEvent.snapshot;
            if (patientSnapshot.value != null) {
              Map<dynamic, dynamic> patientMap =
                  patientSnapshot.value as Map<dynamic, dynamic>;
              tempChatList.add(
                Patient.fromMap(Map<String, dynamic>.from(patientMap)),
              );
            }
          }
        }
        setState(() {
          _chatList = tempChatList;
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lấy danh sách chat: $error'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
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
              backgroundColor: Colors.red.shade400,
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
          'Danh sách trò chuyện',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
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
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : _chatList.isEmpty
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
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có cuộc trò chuyện',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'Chưa có bệnh nhân nào trong danh sách trò chuyện',
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
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  final patient = _chatList[index];
                  return Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          patient.firstName.isNotEmpty
                              ? patient.firstName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        '${patient.firstName} ${patient.lastName}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => ChatScreen(
                                  doctorId: doctorId,
                                  patientId: patient.uid,
                                  patientName:
                                      '${patient.firstName} ${patient.lastName}',
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
