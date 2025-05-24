import 'package:doc_appointment/doctor/doctor_details_page.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';
import 'package:doc_appointment/doctor/widget/doctor_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm để kiểm tra đăng nhập

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    'Doctors',
  );
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view doctors')),
        );
      });
    } else {
      print('User logged in: ${user.uid}');
      _fetchDoctors();
    }
  }

  Future<void> _fetchDoctors() async {
    try {
      final event = await _database.once();
      final snapshot = event.snapshot;
      print('Snapshot value: ${snapshot.value}'); // Log dữ liệu thô
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          print('Doctor data for key $key: $value'); // Log dữ liệu mỗi bác sĩ
          if (value is Map<dynamic, dynamic>) {
            Doctor doctor = Doctor.fromMap(value, key);
            tmpDoctors.add(doctor);
          } else {
            print('Invalid doctor data format for key $key: $value');
          }
        });
      } else {
        print('Snapshot value is null');
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load doctors: $e')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30.0),
                    Text(
                      'Đặt lịch hẹn ngay!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Tìm bác sĩ theo danh mục',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryCard(
                          context,
                          'Cardiologist',
                          'assets/images/heart.png',
                        ),
                        _buildCategoryCard(
                          context,
                          'Dentist',
                          'assets/images/dental.png',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryCard(
                          context,
                          'Oncologist',
                          'assets/images/onco.png',
                        ),
                        _buildCategoryCard(
                          context,
                          'See All',
                          'assets/images/grid.png',
                          isHighlighed: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Các bác sĩ hàng đầu',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Xem thêm',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF006AFA),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child:
                          _doctors.isEmpty
                              ? Center(
                                child: Text(
                                  'No doctors found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                itemCount: _doctors.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DoctorDetailPage(
                                                doctor: _doctors[index],
                                              ),
                                        ),
                                      );
                                    },
                                    child: DoctorCard(doctor: _doctors[index]),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    dynamic icon, {
    bool isHighlighed = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: isHighlighed ? const Color(0xFF006AFA) : const Color(0xffF0EFFF),
        borderRadius: BorderRadius.circular(15),
        border:
            isHighlighed
                ? null
                : Border.all(color: const Color(0xffC8C4FF), width: 2),
      ),
      child: Card(
        color: isHighlighed ? const Color(0xFF006AFA) : const Color(0xffF0EFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon is IconData)
                Icon(
                  icon,
                  size: 40,
                  color: isHighlighed ? Colors.white : const Color(0xFF006AFA),
                )
              else
                Image.asset(icon, width: 40, height: 40),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isHighlighed ? Colors.white : const Color(0xFF006AFA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
