// class Booking {
//   final String date; // Format: MM/dd/yyyy (e.g., "05/25/2025")
//   final String description;
//   final String id;
//   final String receiver;
//   final String sender;
//   final String status;
//   final String time; // Format: HH:mm (e.g., "14:23")
//   final String? cancelReason;
//   final DateTime? canceledAt;
//   final int? createdAt; // Thêm trường này

//   Booking({
//     required this.date,
//     required this.description,
//     required this.id,
//     required this.receiver,
//     required this.sender,
//     required this.status,
//     required this.time,
//     this.cancelReason,
//     this.canceledAt,
//     this.createdAt,
//   });

//   factory Booking.fromMap(Map<String, dynamic> data) {
//     return Booking(
//       date: data['date'] ?? '',
//       description: data['description'] ?? '',
//       id: data['id'] ?? '',
//       receiver: data['receiver'] ?? '',
//       sender: data['sender'] ?? '',
//       status: data['status'] ?? 'pending',
//       time: data['time'] ?? '',
//       cancelReason: data['cancelReason'],
//       canceledAt:
//           data['canceledAt'] != null
//               ? DateTime.fromMillisecondsSinceEpoch(data['canceledAt'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'date': date,
//       'description': description,
//       'id': id,
//       'receiver': receiver,
//       'sender': sender,
//       'status': status,
//       'time': time,
//       'cancelReason': cancelReason,
//       'canceledAt': canceledAt?.millisecondsSinceEpoch,
//     };
//   }

//   DateTime getBookingDateTime() {
//     try {
//       List<String> dateParts = date.split('/');
//       int month = int.parse(dateParts[0]);
//       int day = int.parse(dateParts[1]);
//       int year = int.parse(dateParts[2]);
//       List<String> timeParts = time.split(':');
//       int hour = int.parse(timeParts[0]);
//       int minute = int.parse(timeParts[1]);
//       return DateTime(year, month, day, hour, minute);
//     } catch (e) {
//       return DateTime(9999, 12, 31);
//     }
//   }

//   bool isOverdue(DateTime currentDateTime) {
//     return getBookingDateTime().isBefore(currentDateTime);
//   }
// }
import 'package:intl/intl.dart';

class Booking {
  final String date; // Format: MM/dd/yyyy (e.g., "05/25/2025")
  final String description;
  final String id;
  final String receiver;
  final String sender;
  final String status;
  final String time; // Format: HH:mm (e.g., "14:23")
  final String? cancelReason;
  final DateTime? canceledAt;
  final int? createdAt; // Timestamp (milliseconds since epoch)

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.receiver,
    required this.sender,
    required this.status,
    required this.time,
    this.cancelReason,
    this.canceledAt,
    this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      receiver: data['receiver'] ?? '',
      sender: data['sender'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] ?? '',
      cancelReason: data['cancelReason'],
      canceledAt:
          data['cancelledAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['cancelledAt'])
              : null,
      createdAt: data['createdAt'], // Thêm trường này
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'id': id,
      'receiver': receiver,
      'sender': sender,
      'status': status,
      'time': time,
      'cancelReason': cancelReason,
      'cancelledAt': canceledAt?.millisecondsSinceEpoch,
      'createdAt': createdAt, // Thêm trường này
    };
  }

  DateTime getBookingDateTime() {
    try {
      List<String> dateParts = date.split('/');
      int month = int.parse(dateParts[0]);
      int day = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);
      List<String> timeParts = time.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime(9999, 12, 31);
    }
  }

  bool isOverdue(DateTime currentDateTime) {
    return getBookingDateTime().isBefore(currentDateTime);
  }
}
