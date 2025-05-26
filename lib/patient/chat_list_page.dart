// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:doc_appointment/chat_screen.dart';

// import '../doctor/model/doctor.dart';

// class ChatListPage extends StatefulWidget {
//   const ChatListPage({super.key});

//   @override
//   State<ChatListPage> createState() => _ChatListPageState();
// }

// class _ChatListPageState extends State<ChatListPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _chatListDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('ChatList');
//   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Doctors');
//   List<Doctor> _chatList = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _fetchChatList();
//   }

//   Future<void> _fetchChatList() async {
//     String? userId = _auth.currentUser?.uid;
//     if (userId != null) {
//       try {
//         final DatabaseEvent event = await _chatListDatabase.once();
//         DataSnapshot snapshot = event.snapshot;
//         List<Doctor> tempChatList = [];

//         if (snapshot.value != null) {
//           Map<dynamic, dynamic> values =
//               snapshot.value as Map<dynamic, dynamic>;
//           for (var doctorId in values.keys) {
//             Map<dynamic, dynamic> userChats = values[doctorId];
//             if (userChats.containsKey(userId)) {
//               final DatabaseEvent doctorEvent =
//                   await _doctorDatabase.child(doctorId).once();
//               DataSnapshot doctorSnapshot = doctorEvent.snapshot;
//               if (doctorSnapshot.value != null) {
//                 Doctor doctor = Doctor.fromMap(
//                   doctorSnapshot.value as Map<dynamic, dynamic>,
//                   doctorId,
//                 );
//                 tempChatList.add(doctor);
//               }
//             }
//           }
//         }
//         setState(() {
//           _chatList = tempChatList;
//           _isLoading = false;
//         });
//       } catch (error) {
//         // error message
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text('Chat with')),
//       body:
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _chatList.isEmpty
//               ? Center(child: Text('No chats available'))
//               : ListView.builder(
//                 itemCount: _chatList.length,
//                 itemBuilder: (context, index) {
//                   Doctor doctor = _chatList[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder:
//                               (context) => ChatScreen(
//                                 doctorId: doctor.uid,
//                                 doctorName:
//                                     '${doctor.firstName} ${doctor.lastName}',
//                                 patientId: _auth.currentUser!.uid,
//                               ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 48,
//                       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Color(0xffF0EFFF),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Color(0xffC8C4FF)),
//                       ),
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.only(left: 16.0, right: 10.0),
//                             child: Text(
//                               '${doctor.firstName} ${doctor.lastName}',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_appointment/chat_screen.dart';

import '../doctor/model/doctor.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListDatabase = FirebaseDatabase.instance
      .ref()
      .child('ChatList');
  final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
      .ref()
      .child('Doctors');

  List<Doctor> _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    final String? userId = _auth.currentUser?.uid;

    if (userId == null) return;

    try {
      final DatabaseEvent event = await _chatListDatabase.once();
      final DataSnapshot snapshot = event.snapshot;
      final List<Doctor> tempChatList = [];

      if (snapshot.value != null) {
        final Map<dynamic, dynamic> values =
            snapshot.value as Map<dynamic, dynamic>;

        for (final doctorId in values.keys) {
          final Map<dynamic, dynamic> userChats = values[doctorId];

          if (userChats.containsKey(userId)) {
            final DatabaseEvent doctorEvent =
                await _doctorDatabase.child(doctorId).once();
            final DataSnapshot doctorSnapshot = doctorEvent.snapshot;

            if (doctorSnapshot.value != null) {
              final Doctor doctor = Doctor.fromMap(
                doctorSnapshot.value as Map<dynamic, dynamic>,
                doctorId,
              );
              tempChatList.add(doctor);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _chatList = tempChatList;
          _isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching chat list: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToChat(Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              doctorId: doctor.uid,
              doctorName: '${doctor.firstName} ${doctor.lastName}',
              patientId: _auth.currentUser!.uid,
            ),
      ),
    );
  }

  Widget _buildChatItem(Doctor doctor) {
    return GestureDetector(
      onTap: () => _navigateToChat(doctor),
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 16, right: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Icon(Icons.person, color: Colors.blue.shade600, size: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${doctor.firstName} ${doctor.lastName}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to chat',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
      ),
      backgroundColor: Colors.grey.shade50,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chatList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No chats available',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  return _buildChatItem(_chatList[index]);
                },
              ),
    );
  }
}
