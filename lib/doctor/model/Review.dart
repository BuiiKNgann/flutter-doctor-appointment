// class Review {
//   final String id;
//   final String userId;
//   final String userName;
//   final double rating;
//   final String comment;
//   final DateTime timestamp;

//   Review({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     required this.rating,
//     required this.comment,
//     required this.timestamp,
//   });

//   factory Review.fromMap(Map<dynamic, dynamic> map, String id) {
//     return Review(
//       id: id,
//       userId: map['userId'] ?? '',
//       userName: map['userName'] ?? 'Anonymous',
//       rating: (map['rating']?.toDouble() ?? 0.0),
//       comment: map['comment'] ?? '',
//       timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'userName': userName,
//       'rating': rating,
//       'comment': comment,
//       'timestamp': timestamp.millisecondsSinceEpoch,
//     };
//   }
// }
class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Review.fromMap(Map<dynamic, dynamic> map, String id) {
    return Review(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      rating: (map['rating']?.toDouble() ?? 0.0),
      comment: map['comment'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
