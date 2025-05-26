// import 'package:doc_appointment/doctor/doctor_chatlist_page.dart';
// import 'package:doc_appointment/doctor/doctor_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'doctor_requests_page.dart';

// class DoctorHomePage extends StatefulWidget {
//   const DoctorHomePage({super.key});

//   @override
//   State<DoctorHomePage> createState() => _DoctorHomePageState();
// }

// class _DoctorHomePageState extends State<DoctorHomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _children = [
//     DoctorRequestsPage(),
//     DoctorChatlistPage(),
//     DoctorProfile(),
//   ];

//   void _onItmTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   Future<bool> _onWilPop() async {
//     return await showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('Are you sure?'),
//             content: Text('Do you want to exit the app?'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//                 child: Text('No'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(true);
//                   SystemNavigator.pop();
//                 },
//                 child: Text('Yes'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWilPop,
//       child: Scaffold(
//         body: _children.elementAt(_selectedIndex),
//         bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Color(0xff0064FA),
//           unselectedItemColor: Color(0xffBEBEBE),
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_filled),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           ],
//           currentIndex: _selectedIndex,
//           selectedItemColor: Colors.white,
//           onTap: _onItmTapped,
//         ),
//       ),
//     );
//   }
// }
import 'package:doc_appointment/doctor/doctor_chatlist_page.dart';
import 'package:doc_appointment/doctor/doctor_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'doctor_requests_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    // Lấy doctorId từ FirebaseAuth
    _doctorId = FirebaseAuth.instance.currentUser?.uid;
    if (_doctorId == null) {
      // Hiển thị thông báo nếu chưa đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để tiếp tục'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        // Có thể điều hướng về trang đăng nhập
        // Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  // Danh sách các màn hình
  List<Widget> _getChildren() {
    return [
      const DoctorRequestsPage(),
      const DoctorChatlistPage(),
      _doctorId != null
          ? DoctorProfile(doctorId: _doctorId!)
          : const Center(child: Text('Lỗi: Không tìm thấy ID bác sĩ')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to exit the app?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _getChildren().elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xff0064FA),
          unselectedItemColor: const Color(0xffBEBEBE),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
