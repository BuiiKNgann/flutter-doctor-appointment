import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xffF0EFFF),
        border: Border.all(
          color: const Color(0xffC8C4FF),
        ), // Xóa const khỏi Border.all hoặc giữ nếu BoxDecoration là const
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: const Color(0xffF0EFFF),
        elevation: 0.0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: ListTile(
          leading: Container(
            width: 55,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: const Color(0xFF0064FA),
              ), // Đảm bảo const ở đây hợp lệ
            ),
            child: CircleAvatar(
              child:
                  doctor.profileImageBase64.isNotEmpty
                      ? ClipOval(
                        child: Image.memory(
                          base64Decode(doctor.profileImageBase64),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: const Color(0xffF0EFFF),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
                        ),
                      )
                      : Container(
                        color: const Color(0xffF0EFFF),
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
            ),
          ),
          title: Text(
            '${doctor.firstName} ${doctor.lastName}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${doctor.category} - ${doctor.city}',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
              Text(
                'Experience: ${doctor.yearsOfExperience} years',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: const Color(0xffFA9600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
