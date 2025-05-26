class Doctor {
  final String uid;
  final String firstName;
  final String lastName;
  final String category; // là chuyên môn của bác sĩ
  final String city;
  final String profileImageUrl;
  final String yearsOfExperience;
  final String qualification;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final int totalReviews;
  final int reviewCount; // Thêm trường số lượng đánh giá
  final double averageRating;
  final int numberOfReviews;
  final String description;

  Doctor({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.category,
    required this.city,
    required this.profileImageUrl,
    required this.yearsOfExperience,
    required this.qualification,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.reviewCount,
    this.totalReviews = 0,
    this.averageRating = 0.0,
    this.numberOfReviews = 0,
  });

  factory Doctor.fromMap(Map<dynamic, dynamic> map, String uid) {
    // Đảm bảo tất cả giá trị là String hoặc giá trị mặc định
    return Doctor(
      uid: uid,
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      profileImageUrl: map['profileImageUrl']?.toString() ?? '',
      yearsOfExperience: map['yearsOfExperience']?.toString() ?? '',
      qualification: map['qualification']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      latitude: (map['latitude']?.toDouble() ?? 0.0),
      longitude: (map['longitude']?.toDouble() ?? 0.0),
      totalReviews: (map['totalReviews']?.toInt() ?? 0),
      reviewCount: (map['reviewCount']?.toInt() ?? 0),
      averageRating: (map['averageRating']?.toDouble() ?? 0.0),
      numberOfReviews: (map['numberOfReviews']?.toInt() ?? 0),
    );
  }
}
