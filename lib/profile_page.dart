// import 'package:doc_appointment/doctor/model/booking.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:doc_appointment/auth/login_page.dart';
// import 'package:doc_appointment/doctor/model/doctor.dart';
// import 'package:intl/intl.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref(
//     'Requests',
//   );
//   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance.ref(
//     'Doctors',
//   );

//   List<Booking> _bookings = [];
//   Map<String, Doctor> _doctors = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchBookings();
//   }

//   Future<void> _fetchBookings() async {
//     String? currentUserId = _auth.currentUser?.uid;
//     if (currentUserId != null) {
//       try {
//         DatabaseEvent event =
//             await _requestDatabase
//                 .orderByChild('sender')
//                 .equalTo(currentUserId)
//                 .once();

//         if (event.snapshot.value != null) {
//           Map<dynamic, dynamic> bookingMap =
//               event.snapshot.value as Map<dynamic, dynamic>;
//           List<Booking> tempBookings = [];

//           for (var entry in bookingMap.entries) {
//             var bookingData = Map<String, dynamic>.from(entry.value);
//             bookingData['id'] = entry.key;
//             tempBookings.add(Booking.fromMap(bookingData));

//             // Debug: Log createdAt
//             print(
//               'Booking ${bookingData['id']}: createdAt = ${bookingData['createdAt']}',
//             );

//             String doctorId = bookingData['receiver'];
//             if (!_doctors.containsKey(doctorId)) {
//               DatabaseEvent doctorEvent =
//                   await _doctorDatabase.child(doctorId).once();
//               if (doctorEvent.snapshot.value != null) {
//                 Map<dynamic, dynamic> doctorData =
//                     doctorEvent.snapshot.value as Map<dynamic, dynamic>;
//                 _doctors[doctorId] = Doctor.fromMap(doctorData, doctorId);
//               }
//             }
//           }

//           // Sắp xếp bookings theo createdAt (nếu có) hoặc date
//           tempBookings.sort((a, b) {
//             if (a.createdAt != null && b.createdAt != null) {
//               return b.createdAt!.compareTo(a.createdAt!); // Giảm dần
//             }
//             try {
//               DateTime dateA = DateFormat('MM/dd/yyyy').parse(a.date);
//               DateTime dateB = DateFormat('MM/dd/yyyy').parse(b.date);
//               return dateB.compareTo(dateA); // Giảm dần
//             } catch (e) {
//               return 0; // Giữ nguyên nếu lỗi
//             }
//           });

//           setState(() {
//             _bookings = tempBookings;
//             _isLoading = false;
//           });
//         } else {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Lỗi khi tải lịch hẹn: $e')));
//       }
//     }
//   }

//   void _logout() async {
//     await _auth.signOut();
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => const LoginPage()),
//       (Route<dynamic> route) => false,
//     );
//   }

//   Future<void> _cancelBooking(String bookingId, String doctorId) async {
//     TextEditingController reasonController = TextEditingController();

//     return showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Hủy lịch hẹn'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Vui lòng nhập lý do hủy lịch:'),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: reasonController,
//                   decoration: const InputDecoration(
//                     hintText: 'Nhập lý do ở đây',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Thoát'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   if (reasonController.text.trim().isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Vui lòng nhập lý do')),
//                     );
//                     return;
//                   }

//                   try {
//                     await _requestDatabase.child(bookingId).update({
//                       'status': 'canceled',
//                       'cancelReason': reasonController.text.trim(),
//                       'cancelledAt': ServerValue.timestamp,
//                     });

//                     setState(() {
//                       _bookings =
//                           _bookings.map((booking) {
//                             if (booking.id == bookingId) {
//                               return Booking(
//                                 id: booking.id,
//                                 sender: booking.sender,
//                                 receiver: booking.receiver,
//                                 date: booking.date,
//                                 time: booking.time,
//                                 description: booking.description,
//                                 status: 'canceled',
//                                 cancelReason: reasonController.text.trim(),
//                                 canceledAt: DateTime.now(),
//                                 createdAt: booking.createdAt,
//                               );
//                             }
//                             return booking;
//                           }).toList();
//                     });

//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Hủy lịch thành công')),
//                     );
//                   } catch (e) {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Lỗi khi hủy lịch: $e')),
//                     );
//                   }
//                 },
//                 child: const Text('Xác nhận'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Lịch hẹn của tôi'),
//       //   actions: [
//       //     IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
//       //   ],
//       // ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _bookings.isEmpty
//               ? const Center(child: Text('Không có lịch hẹn nào'))
//               : ListView.builder(
//                 itemCount: _bookings.length,
//                 itemBuilder: (context, index) {
//                   final booking = _bookings[index];
//                   final doctor = _doctors[booking.receiver];
//                   String doctorName =
//                       doctor != null
//                           ? '${doctor.firstName} ${doctor.lastName}'
//                           : 'Bác sĩ chưa rõ';

//                   return ListTile(
//                     onTap: () {
//                       if (booking.status == 'pending') {
//                         _cancelBooking(booking.id, booking.receiver);
//                       }
//                     },
//                     title: Text('Bác sĩ: $doctorName'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Ngày: ${booking.date}  Giờ: ${booking.time}'),
//                         if (booking.status == 'canceled' &&
//                             booking.cancelReason != null &&
//                             booking.cancelReason!.isNotEmpty)
//                           Text(
//                             'Lý do hủy: ${booking.cancelReason}',
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                       ],
//                     ),
//                     trailing: Text(
//                       booking.status == 'pending'
//                           ? 'Đang chờ'
//                           : booking.status == 'Đồng ý'
//                           ? 'Đồng ý'
//                           : booking.status == 'Từ chối'
//                           ? 'Từ chối'
//                           : booking.status == 'Hoàn tất'
//                           ? 'Hoàn tất'
//                           : booking.status == 'canceled'
//                           ? 'Đã hủy'
//                           : 'Khác',
//                       style: TextStyle(
//                         color:
//                             booking.status == 'Từ chối' ||
//                                     booking.status == 'canceled'
//                                 ? Colors.red
//                                 : booking.status == 'Đồng ý'
//                                 ? Colors.blue
//                                 : booking.status == 'Hoàn tất'
//                                 ? Colors.green
//                                 : Colors.orange,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }
import 'package:doc_appointment/doctor/model/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:doc_appointment/auth/login_page.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref(
    'Requests',
  );
  final DatabaseReference _doctorDatabase = FirebaseDatabase.instance.ref(
    'Doctors',
  );

  List<Booking> _bookings = [];
  Map<String, Doctor> _doctors = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      try {
        DatabaseEvent event =
            await _requestDatabase
                .orderByChild('sender')
                .equalTo(currentUserId)
                .once();

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap =
              event.snapshot.value as Map<dynamic, dynamic>;
          List<Booking> tempBookings = [];

          for (var entry in bookingMap.entries) {
            var bookingData = Map<String, dynamic>.from(entry.value);
            bookingData['id'] = entry.key;
            tempBookings.add(Booking.fromMap(bookingData));

            // Debug: Log createdAt
            print(
              'Booking ${bookingData['id']}: createdAt = ${bookingData['createdAt']}',
            );

            String doctorId = bookingData['receiver'];
            if (!_doctors.containsKey(doctorId)) {
              DatabaseEvent doctorEvent =
                  await _doctorDatabase.child(doctorId).once();
              if (doctorEvent.snapshot.value != null) {
                Map<dynamic, dynamic> doctorData =
                    doctorEvent.snapshot.value as Map<dynamic, dynamic>;
                _doctors[doctorId] = Doctor.fromMap(doctorData, doctorId);
              }
            }
          }

          // Sắp xếp bookings theo createdAt (nếu có) hoặc date
          tempBookings.sort((a, b) {
            if (a.createdAt != null && b.createdAt != null) {
              return b.createdAt!.compareTo(a.createdAt!); // Giảm dần
            }
            try {
              DateTime dateA = DateFormat('MM/dd/yyyy').parse(a.date);
              DateTime dateB = DateFormat('MM/dd/yyyy').parse(b.date);
              return dateB.compareTo(dateA); // Giảm dần
            } catch (e) {
              return 0; // Giữ nguyên nếu lỗi
            }
          });

          setState(() {
            _bookings = tempBookings;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải lịch hẹn: $e')));
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _cancelBooking(String bookingId, String doctorId) async {
    TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text(
                  'Hủy lịch hẹn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vui lòng nhập lý do hủy lịch:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do ở đây',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Thoát',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập lý do')),
                    );
                    return;
                  }

                  try {
                    await _requestDatabase.child(bookingId).update({
                      'status': 'canceled',
                      'cancelReason': reasonController.text.trim(),
                      'cancelledAt': ServerValue.timestamp,
                    });

                    setState(() {
                      _bookings =
                          _bookings.map((booking) {
                            if (booking.id == bookingId) {
                              return Booking(
                                id: booking.id,
                                sender: booking.sender,
                                receiver: booking.receiver,
                                date: booking.date,
                                time: booking.time,
                                description: booking.description,
                                status: 'canceled',
                                cancelReason: reasonController.text.trim(),
                                canceledAt: DateTime.now(),
                                createdAt: booking.createdAt,
                              );
                            }
                            return booking;
                          }).toList();
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hủy lịch thành công')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi hủy lịch: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Xác nhận', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Từ chối':
      case 'canceled':
        return Colors.red;
      case 'Đồng ý':
        return Colors.blue;
      case 'Hoàn tất':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Từ chối':
      case 'canceled':
        return Icons.cancel;
      case 'Đồng ý':
        return Icons.check_circle;
      case 'Hoàn tất':
        return Icons.done_all;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Đang chờ';
      case 'Đồng ý':
        return 'Đồng ý';
      case 'Từ chối':
        return 'Từ chối';
      case 'Hoàn tất':
        return 'Hoàn tất';
      case 'canceled':
        return 'Đã hủy';
      default:
        return 'Khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải lịch hẹn...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : _bookings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có lịch hẹn nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy đặt lịch hẹn với bác sĩ để xem tại đây',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
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
                    final doctor = _doctors[booking.receiver];
                    String doctorName =
                        doctor != null
                            ? '${doctor.firstName} ${doctor.lastName}'
                            : 'Bác sĩ chưa rõ';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap:
                              booking.status == 'pending'
                                  ? () => _cancelBooking(
                                    booking.id,
                                    booking.receiver,
                                  )
                                  : null,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header với thông tin bác sĩ và trạng thái
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctorName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            doctor != null
                                                ? doctor.category
                                                : 'Bác sĩ chuyên khoa',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          booking.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(booking.status),
                                            size: 16,
                                            color: _getStatusColor(
                                              booking.status,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getDisplayStatus(booking.status),
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                booking.status,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Thông tin lịch hẹn
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              booking.date,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: Colors.grey[300],
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              booking.time,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Lý do hủy (nếu có)
                                if (booking.status == 'canceled' &&
                                    booking.cancelReason != null &&
                                    booking.cancelReason!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.red[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Lý do hủy:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                booking.cancelReason!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Hướng dẫn hủy lịch (chỉ hiện với booking pending)
                                if (booking.status == 'pending') ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: Colors.orange[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Nhấn để hủy lịch hẹn',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
