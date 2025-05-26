import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap; // Thêm callback cho sự kiện nhấn
  final VoidCallback? onRemove; // Thêm callback cho sự kiện xóa

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffC8C4FF).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xffC8C4FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Section
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xff0064FA).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child:
                        doctor.profileImageUrl.isNotEmpty
                            ? Image.network(
                              doctor.profileImageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: const Color(0xffF0EFFF),
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.grey[400],
                                      size: 28,
                                    ),
                                  ),
                            )
                            : Container(
                              color: const Color(0xffF0EFFF),
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.grey[400],
                                size: 28,
                              ),
                            ),
                  ),
                ),

                const SizedBox(width: 14),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Name
                      Text(
                        '${doctor.firstName} ${doctor.lastName}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Specialty and Location
                      Text(
                        '${doctor.category} • ${doctor.city}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Experience
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            size: 14,
                            color: const Color(0xffFA9600),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.yearsOfExperience} năm kinh nghiệm',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xffFA9600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Section
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
