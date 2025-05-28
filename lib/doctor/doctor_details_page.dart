import 'package:doc_appointment/doctor/model/favorite.dart';
import 'package:doc_appointment/review_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat_screen.dart';

import 'model/doctor.dart';
import 'model/review.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref(
    'Requests',
  );
  final DatabaseReference _reviewsDatabase = FirebaseDatabase.instance.ref(
    'Reviews',
  );
  final DatabaseReference _doctorsDatabase = FirebaseDatabase.instance.ref(
    'Doctors',
  );
  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _availableTimeSlots = [];
  List<String> _bookedTimeSlots = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
    _fetchReviews();
    _checkFavoriteStatus();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateTimeSlots() {
    _availableTimeSlots.clear();
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(2025, 1, 1, 8, 0);
    DateTime endTime = DateTime(2025, 1, 1, 17, 0);

    if (_selectedDate != null &&
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day) {
      startTime = DateTime(2025, 1, 1, now.hour, now.minute);
      if (startTime.minute % 30 != 0) {
        startTime = startTime.add(
          Duration(minutes: 30 - (startTime.minute % 30)),
        );
      }
    }

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      String formattedTime =
          DateFormat('h:mm a').format(startTime).toLowerCase();
      _availableTimeSlots.add(formattedTime);
      startTime = startTime.add(Duration(minutes: 30));
    }
  }

  void _fetchReviews() {
    _reviewsDatabase
        .child(widget.doctor.uid)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> reviewsData =
                  event.snapshot.value as Map<dynamic, dynamic>;
              List<Review> reviews = [];
              reviewsData.forEach((key, value) {
                reviews.add(Review.fromMap(value, key));
              });

              if (reviews.isNotEmpty) {
                double totalRating = reviews
                    .map((r) => r.rating)
                    .reduce((a, b) => a + b);
                setState(() {
                  _averageRating = totalRating / reviews.length;
                  _reviewCount = reviews.length;
                });
                _doctorsDatabase.child(widget.doctor.uid).update({
                  'averageRating': _averageRating,
                  'reviewCount': _reviewCount,
                });
              } else {
                setState(() {
                  _averageRating = 0.0;
                  _reviewCount = 0;
                });
                _doctorsDatabase.child(widget.doctor.uid).update({
                  'averageRating': 0.0,
                  'reviewCount': 0,
                });
              }
            }
          },
          onError: (error) {
            _showSnackBar('Lỗi khi tải đánh giá: $error', isError: true);
          },
        );
  }

  Future<void> _checkBookedTimeSlots() async {
    if (_selectedDate == null) return;

    String formattedDate = DateFormat('MM/dd/yyyy').format(_selectedDate!);
    _bookedTimeSlots.clear();

    try {
      Query query = _requestDatabase
          .orderByChild('receiver')
          .equalTo(widget.doctor.uid);
      DataSnapshot snapshot = await query.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> requests =
            snapshot.value as Map<dynamic, dynamic>;
        requests.forEach((key, value) {
          if (value['date'] == formattedDate &&
              (value['status'] == 'pending' ||
                  value['status'] == 'confirmed')) {
            _bookedTimeSlots.add(
              DateFormat('h:mm a')
                  .format(DateFormat('HH:mm').parse(value['time']).toLocal())
                  .toLowerCase(),
            );
          }
        });
      }

      setState(() {});
    } catch (e) {
      _showSnackBar('Lỗi khi kiểm tra khung giờ đã đặt: $e', isError: true);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final patientUid = _auth.currentUser?.uid;
    if (patientUid != null) {
      final favorite = Favorite(
        patientUid: patientUid,
        doctorUid: widget.doctor.uid,
      );
      try {
        final isFavorite = await favorite.isFavorite();
        setState(() {
          _isFavorite = isFavorite;
          _isLoadingFavorite = false;
        });
      } catch (e) {
        _showSnackBar(
          'Lỗi khi kiểm tra trạng thái yêu thích: $e',
          isError: true,
        );
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    } else {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final patientUid = _auth.currentUser?.uid;
    if (patientUid == null) {
      _showSnackBar(
        'Vui lòng đăng nhập để thêm bác sĩ vào yêu thích',
        isError: true,
      );
      return;
    }

    final favorite = Favorite(
      patientUid: patientUid,
      doctorUid: widget.doctor.uid,
    );
    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      if (_isFavorite) {
        await favorite.removeFromFavorites();
        setState(() {
          _isFavorite = false;
        });
        _showSnackBar('Đã xóa bác sĩ khỏi danh sách yêu thích');
      } else {
        await favorite.addToFavorites();
        setState(() {
          _isFavorite = true;
        });
        _showSnackBar('Đã thêm bác sĩ vào danh sách yêu thích');
      }
    } catch (e) {
      _showSnackBar('Lỗi: $e', isError: true);
    } finally {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F9FA),
      extendBodyBehindAppBar: true,
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
        actions: [
          Container(
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
            child:
                _isLoadingFavorite
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: Colors.red[400],
                      ),
                      onPressed: _toggleFavorite,
                    ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoctorInfo(),
                      SizedBox(height: 24),
                      _buildAboutSection(),
                      SizedBox(height: 24),
                      _buildMapSection(),
                      SizedBox(height: 32),
                      _buildAppointmentSection(),
                      SizedBox(height: 24),
                      _buildDescriptionSection(),
                      SizedBox(height: 32),
                      _buildBookButton(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff667eea), Color(0xff764ba2)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'doctor-${widget.doctor.uid}',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        widget.doctor.profileImageUrl.isNotEmpty
                            ? Image.network(
                              widget.doctor.profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            )
                            : Container(
                              color: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                '${widget.doctor.firstName} ${widget.doctor.lastName}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.doctor.category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_rounded,
            title: 'Vị trí',
            subtitle: widget.doctor.city,
            color: Colors.orange[400]!,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.work_rounded,
            title: 'Kinh nghiệm',
            subtitle: '${widget.doctor.yearsOfExperience} năm',
            color: Colors.blue[400]!,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreen(doctor: widget.doctor),
                ),
              ).then((_) => _fetchReviews());
            },
            child: _buildInfoCard(
              icon: Icons.star_rounded,
              title: 'Đánh giá',
              subtitle: _averageRating.toStringAsFixed(1),
              color: Colors.amber[400]!,
              averageRating: _averageRating,
              reviewCount: _reviewCount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    double? averageRating,
    int? reviewCount,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          if (title == 'Đánh giá' && averageRating != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < averageRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber[400],
                  size: 14,
                );
              }),
            ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (title == 'Đánh giá' && reviewCount != null && reviewCount > 0)
            Text(
              '($reviewCount đánh giá)',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffF0F8FF), Color(0xffE6F3FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)), // Bỏ const
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Giới thiệu về bác sĩ',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            widget.doctor.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[400],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _openMap,
        icon: Icon(Icons.map_rounded),
        label: Text(
          'Xem vị trí trên bản đồ',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAppointmentSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffF0F8FF), Color(0xffE6F3FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)), // Bỏ const
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Chọn ngày & giờ khám',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_selectedDate != null && _selectedTime != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue[600],
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${DateFormat('EEE, MMM d, y').format(_selectedDate!)} | '
                      '${DateFormat('h:mm a').format(DateTime(2025, 1, 1, _selectedTime!.hour, _selectedTime!.minute)).toLowerCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    color: Colors.grey[500],
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Bạn chưa chọn ngày và giờ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await _selectDate(context);
                    await _checkBookedTimeSlots();
                  },
                  icon: Icon(Icons.calendar_month_rounded, size: 20),
                  label: Text('Chọn ngày'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedDate == null
                            ? Colors.grey[300]
                            : Colors.blue[600],
                    foregroundColor:
                        _selectedDate == null ? Colors.grey[600] : Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _selectedDate == null ? null : () => _showTimePicker(),
                  icon: Icon(Icons.access_time_rounded, size: 20),
                  label: Text('Chọn giờ'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildTimeSlots(),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone_rounded, color: Colors.green[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Liên hệ nhanh:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              _buildActionButton(
                icon: Icons.phone_rounded,
                color: Colors.green[400]!,
                onTap: () => _makePhoneCall(widget.doctor.phoneNumber),
              ),
              SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_rounded,
                color: Colors.blue[400]!,
                onTap: _openChat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)), // Bỏ const
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDate == null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Hãy chọn ngày trước',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }

    DateTime now = DateTime.now();
    bool isToday =
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children:
              _availableTimeSlots.map((time) {
                bool isBooked = _bookedTimeSlots.contains(time);
                bool isSelected =
                    _selectedTime != null &&
                    DateFormat('h:mm a')
                            .format(
                              DateTime(
                                2025,
                                1,
                                1,
                                _selectedTime!.hour,
                                _selectedTime!.minute,
                              ),
                            )
                            .toLowerCase() ==
                        time;

                bool isPast = false;
                if (isToday) {
                  List<String> timeParts = time.split(' ');
                  List<String> hourMinute = timeParts[0].split(':');
                  int hour = int.parse(hourMinute[0]);
                  int minute = int.parse(hourMinute[1]);
                  if (timeParts[1] == 'pm' && hour != 12) hour += 12;
                  if (timeParts[1] == 'am' && hour == 12) hour = 0;
                  DateTime slotTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    hour,
                    minute,
                  );
                  isPast = slotTime.isBefore(now);
                }

                return GestureDetector(
                  onTap: (isBooked || isPast) ? null : () => _selectTime(time),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(minWidth: 70),
                    decoration: BoxDecoration(
                      color:
                          isBooked || isPast
                              ? Colors.grey[200]
                              : isSelected
                              ? Colors.blue[600]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isBooked || isPast
                                ? Colors.grey[300]!
                                : isSelected
                                ? Colors.blue[600]!
                                : Colors.grey[200]!,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color:
                            isBooked || isPast
                                ? Colors.grey[500]
                                : isSelected
                                ? Colors.white
                                : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  void _selectTime(String time) {
    DateTime now = DateTime.now();
    bool isToday =
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    List<String> timeParts = time.split(' ');
    List<String> hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);
    if (timeParts[1] == 'pm' && hour != 12) hour += 12;
    if (timeParts[1] == 'am' && hour == 12) hour = 0;

    DateTime slotTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (isToday && slotTime.isBefore(now)) {
      _showSnackBar('Không thể chọn khung giờ trong quá khứ', isError: true);
      return;
    }

    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff667eea),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      String timeString =
          DateFormat('h:mm a')
              .format(DateTime(2025, 1, 1, picked.hour, picked.minute))
              .toLowerCase();
      if (_bookedTimeSlots.contains(timeString)) {
        _showSnackBar('Khung giờ này đã được đặt', isError: true);
        return;
      }
      DateTime now = DateTime.now();
      bool isToday =
          _selectedDate!.year == now.year &&
          _selectedDate!.month == now.month &&
          _selectedDate!.day == now.day;
      DateTime slotTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      if (isToday && slotTime.isBefore(now)) {
        _showSnackBar('Không thể chọn khung giờ trong quá khứ', isError: true);
        return;
      }
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffF0F8FF), Color(0xffE6F3FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)), // Bỏ const
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_rounded, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Mô tả triệu chứng',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _descriptionController,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Mô tả chi tiết về triệu chứng và vấn đề sức khỏe của bạn...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff667eea), Color.fromARGB(255, 57, 28, 187)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 66, 87, 184).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _bookAppointment,
        child: Text(
          'Đặt lịch khám ngay',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff667eea),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
        _generateTimeSlots();
      });
      await _checkBookedTimeSlots();
    }
  }

  void _openMap() async {
    final String googleMapUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.doctor.latitude},${widget.doctor.longitude}';
    if (await canLaunchUrl(Uri.parse(googleMapUrl))) {
      await launchUrl(Uri.parse(googleMapUrl));
    } else {
      _showSnackBar('Không thể mở bản đồ', isError: true);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('Không thể gọi điện tới $phoneNumber', isError: true);
    }
  }

  void _openChat() {
    String currentUserId = _auth.currentUser!.uid;
    String docName = '${widget.doctor.firstName} ${widget.doctor.lastName}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              doctorId: widget.doctor.uid,
              doctorName: docName,
              patientId: currentUserId,
            ),
      ),
    );
  }

  void _bookAppointment() {
    if (_selectedDate != null && _selectedTime != null) {
      String date = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      String description =
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Người dùng không nhập mô tả';
      String requestId = _requestDatabase.push().key!;

      if (_auth.currentUser == null) {
        _showSnackBar('Vui lòng đăng nhập để đặt lịch khám', isError: true);
        return;
      }

      String currentUserId = _auth.currentUser!.uid;
      String receiverId = widget.doctor.uid;
      String status = 'pending';

      String selectedTimeString =
          DateFormat('h:mm a')
              .format(
                DateTime(
                  2025,
                  1,
                  1,
                  _selectedTime!.hour,
                  _selectedTime!.minute,
                ),
              )
              .toLowerCase();

      _requestDatabase
          .child(requestId)
          .set({
            'date': date,
            'time': DateFormat('HH:mm').format(
              DateTime(2025, 1, 1, _selectedTime!.hour, _selectedTime!.minute),
            ),
            'description': description,
            'id': requestId,
            'receiver': receiverId,
            'sender': currentUserId,
            'status': status,
          })
          .then((_) {
            setState(() {
              _selectedDate = null;
              _selectedTime = null;
              _descriptionController.clear();
              _bookedTimeSlots.add(selectedTimeString);
            });
            _showSnackBar('Đặt lịch khám thành công!');
          })
          .catchError((error) {
            _showSnackBar('Đặt lịch khám thất bại: $error', isError: true);
          });
    } else {
      _showSnackBar('Vui lòng chọn ngày và giờ', isError: true);
    }
  }
}
