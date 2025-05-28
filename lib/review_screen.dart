import 'package:doc_appointment/doctor/model/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:doc_appointment/doctor/model/review.dart';

class ReviewScreen extends StatefulWidget {
  final Doctor doctor;

  const ReviewScreen({super.key, required this.doctor});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _fetchReviews() async {
    try {
      DataSnapshot snapshot =
          await _database.child('Reviews').child(widget.doctor.uid).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> reviewsMap =
            snapshot.value as Map<dynamic, dynamic>;
        List<Review> reviews =
            reviewsMap.entries
                .map((entry) => Review.fromMap(entry.value, entry.key))
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        setState(() {
          _reviews = reviews;
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi khi tải đánh giá: $e', isError: true);
    }
  }

  Future<String> _getUserName(String userId) async {
    try {
      // Kiểm tra trong nhánh Patients
      DataSnapshot snapshot =
          await _database.child('Patients').child(userId).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        return userData['displayName'] ??
            '${userData['firstName']} ${userData['lastName']}'.trim();
      }
      // Kiểm tra trong nhánh Doctors (nếu cần)
      snapshot = await _database.child('Doctors').child(userId).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        return userData['displayName'] ??
            '${userData['firstName']} ${userData['lastName']}'.trim();
      }
      return 'Unknown User';
    } catch (e) {
      print('Lỗi khi lấy userName: $e');
      return 'Unknown User';
    }
  }

  Future<void> _submitReview() async {
    if (_auth.currentUser == null) {
      _showSnackBar('Vui lòng đăng nhập để gửi đánh giá', isError: true);
      return;
    }

    if (_rating == 0.0) {
      _showSnackBar('Vui lòng chọn số sao', isError: true);
      return;
    }

    try {
      String userId = _auth.currentUser!.uid;
      String userName =
          _auth.currentUser!.displayName ?? await _getUserName(userId);
      if (userName.isEmpty) {
        userName = 'Unknown User';
      }
      String doctorId = widget.doctor.uid;
      String reviewId = _database.child('Reviews').child(doctorId).push().key!;

      Review review = Review(
        id: reviewId,
        userId: userId,
        userName: userName,
        rating: _rating,
        comment: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _database
          .child('Reviews')
          .child(doctorId)
          .child(reviewId)
          .set(review.toMap());

      // Cập nhật averageRating và reviewCount trong Doctors
      DataSnapshot reviewsSnapshot =
          await _database.child('Reviews').child(doctorId).get();
      double totalRating = 0.0;
      int numberOfReviews = 0;

      if (reviewsSnapshot.exists) {
        Map<dynamic, dynamic> reviewsMap =
            reviewsSnapshot.value as Map<dynamic, dynamic>;
        numberOfReviews = reviewsMap.length;
        reviewsMap.forEach((key, value) {
          totalRating += (value['rating']?.toDouble() ?? 0.0);
        });
      }

      double averageRating =
          numberOfReviews > 0 ? totalRating / numberOfReviews : 0.0;

      await _database.child('Doctors').child(doctorId).update({
        'averageRating': averageRating,
        'reviewCount': numberOfReviews,
      });

      _showSnackBar('Đánh giá đã được gửi thành công!');
      setState(() {
        _rating = 0.0;
        _commentController.clear();
        _fetchReviews();
      });
    } catch (e) {
      _showSnackBar('Gửi đánh giá thất bại: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Đánh giá bác sĩ',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffF0F8FF), Color(0xffE6F3FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gửi đánh giá của bạn',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber[400],
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: TextField(
                        controller: _commentController,
                        maxLines: 2,
                        scrollPhysics: AlwaysScrollableScrollPhysics(),
                        decoration: InputDecoration(
                          hintText: 'Viết nhận xét của bạn...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: _submitReview,
                      child: Text(
                        'Gửi đánh giá',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Đánh giá của người dùng',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child:
                  _reviews.isEmpty
                      ? Center(
                        child: Text(
                          'Chưa có đánh giá nào',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      )
                      : ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(review.timestamp),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: Colors.amber[400],
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    review.comment.isNotEmpty
                                        ? review.comment
                                        : 'Không có nhận xét',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
