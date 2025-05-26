import 'package:doc_appointment/doctor/model/booking.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DoctorProfile extends StatefulWidget {
  final String doctorId;

  const DoctorProfile({super.key, required this.doctorId});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref(
    'Requests',
  );
  final DatabaseReference _doctorDatabase = FirebaseDatabase.instance.ref(
    'Doctors',
  );
  final DatabaseReference _statisticsDatabase = FirebaseDatabase.instance.ref(
    'Statistics',
  );
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String? doctorName;

  // Danh sách tháng và năm để chọn
  final List<int> months = List.generate(12, (index) => index + 1);
  final List<int> years = List.generate(
    10,
    (index) => DateTime.now().year - 5 + index,
  );

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  // Lấy tên bác sĩ từ Firebase
  Future<void> _fetchDoctorName() async {
    try {
      DataSnapshot snapshot =
          await _doctorDatabase.child(widget.doctorId).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          doctorName = '${data['firstName']} ${data['lastName']}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải thông tin bác sĩ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm xử lý dữ liệu để đếm trạng thái
  Map<String, int> getBookingStatusByMonth(
    List<Booking> bookings,
    int year,
    int month,
  ) {
    Map<String, int> statusCount = {'Từ chối': 0, 'Đồng ý': 0, 'Hoàn tất': 0};

    for (var booking in bookings) {
      try {
        List<String> dateParts = booking.date.split('/');
        int bookingMonth = int.parse(dateParts[0]);
        int bookingYear = int.parse(dateParts[2]);
        if (bookingMonth == month && bookingYear == year) {
          String status = booking.status;
          // Ánh xạ trạng thái từ database
          if (status == 'rejected') status = 'Từ chối';
          if (status == 'confirmed') status = 'Đồng ý';
          if (status == 'completed') status = 'Hoàn tất';
          if (statusCount.containsKey(status)) {
            statusCount[status] = (statusCount[status] ?? 0) + 1;
          }
        }
      } catch (e) {
        // Bỏ qua nếu định dạng ngày không hợp lệ
      }
    }

    return statusCount;
  }

  // Lưu thống kê vào Firebase
  Future<void> _saveStatistics(Map<String, int> statusCount) async {
    if (doctorName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu: Chưa tải được thông tin bác sĩ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _statisticsDatabase
          .child(widget.doctorId)
          .child(selectedYear.toString())
          .child(selectedMonth.toString())
          .set({
            'rejected': statusCount['Từ chối'] ?? 0,
            'confirmed': statusCount['Đồng ý'] ?? 0,
            'completed': statusCount['Hoàn tất'] ?? 0,
            'doctorName': doctorName,
            'timestamp': ServerValue.timestamp,
          });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu thống kê thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu thống kê: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Xuất thống kê ra file Excel
  Future<void> _exportToExcel(Map<String, int> statusCount) async {
    if (doctorName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xuất Excel: Chưa tải được thông tin bác sĩ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Yêu cầu quyền lưu trữ trên Android
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền lưu trữ để xuất file Excel'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      // Tiêu đề
      sheet.appendRow([
        TextCellValue('Thống kê lịch đặt khám'),
        TextCellValue('Tháng $selectedMonth/$selectedYear'),
      ]);
      sheet.appendRow([TextCellValue('')]); // Dòng trống

      // Thông tin bác sĩ
      sheet.appendRow([TextCellValue('Bác sĩ'), TextCellValue(doctorName!)]);

      // Thống kê
      sheet.appendRow([TextCellValue('Trạng thái'), TextCellValue('Số lượng')]);
      statusCount.forEach((status, count) {
        sheet.appendRow([TextCellValue(status), IntCellValue(count)]);
      });

      // Lưu file
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/statistics_${widget.doctorId}_$selectedMonth-$selectedYear.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      // Mở file (tùy chọn)
      await OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xuất file Excel thành công: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thống kê lịch khám của bác sĩ: ${doctorName != null ? ': $doctorName' : ''}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<DatabaseEvent>(
        stream:
            _requestDatabase
                .orderByChild('receiver')
                .equalTo(widget.doctorId)
                .limitToLast(100)
                .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi khi tải dữ liệu: ${snapshot.error}',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            );
          }

          List<Booking> bookings = [];
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value;
            if (data is Map<Object?, Object?>) {
              data.forEach((key, value) {
                if (value is Map<Object?, Object?>) {
                  try {
                    bookings.add(
                      Booking.fromMap(Map<String, dynamic>.from(value)),
                    );
                  } catch (e) {
                    // Bỏ qua nếu dữ liệu không hợp lệ
                  }
                }
              });
            }
          }

          final statusCount = getBookingStatusByMonth(
            bookings,
            selectedYear,
            selectedMonth,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bộ chọn tháng và năm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<int>(
                      value: selectedMonth,
                      items:
                          months.map((month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(
                                'Tháng $month',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value!;
                        });
                      },
                    ),
                    DropdownButton<int>(
                      value: selectedYear,
                      items:
                          years.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(
                                '$year',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Thống kê lịch đặt khám (Tháng $selectedMonth/$selectedYear)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Kiểm tra xem có dữ liệu để hiển thị biểu đồ không
                statusCount.values.every((count) => count == 0)
                    ? Center(
                      child: Text(
                        'Không có lịch đặt khám trong tháng này',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: statusCount['Đồng ý']?.toDouble() ?? 0,
                              color: Colors.blue,
                              title: 'Đồng ý (${statusCount['Đồng ý']})',
                              radius: 100,
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: statusCount['Từ chối']?.toDouble() ?? 0,
                              color: Colors.red,
                              title: 'Từ chối (${statusCount['Từ chối']})',
                              radius: 100,
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: statusCount['Hoàn tất']?.toDouble() ?? 0,
                              color: Colors.green,
                              title: 'Hoàn tất (${statusCount['Hoàn tất']})',
                              radius: 100,
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                const SizedBox(height: 20),
                // Hiển thị chú thích
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(
                      'Đồng ý',
                      Colors.blue,
                      statusCount['Đồng ý']!,
                    ),
                    _buildLegendItem(
                      'Từ chối',
                      Colors.red,
                      statusCount['Từ chối']!,
                    ),
                    _buildLegendItem(
                      'Hoàn tất',
                      Colors.green,
                      statusCount['Hoàn tất']!,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Nút lưu và xuất Excel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:
                          statusCount.values.every((count) => count == 0)
                              ? null
                              : () => _saveStatistics(statusCount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lưu thống kê',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          statusCount.values.every((count) => count == 0)
                              ? null
                              : () => _exportToExcel(statusCount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Xuất Excel',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị chú thích
  Widget _buildLegendItem(String title, Color color, int count) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text('$title: $count', style: GoogleFonts.poppins(fontSize: 14)),
      ],
    );
  }
}
