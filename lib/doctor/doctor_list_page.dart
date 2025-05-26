// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:doc_appointment/doctor/doctor_details_page.dart';
// import 'package:doc_appointment/doctor/model/doctor.dart';
// import 'package:doc_appointment/doctor/widget/doctor_card.dart';

// class DoctorListPage extends StatefulWidget {
//   const DoctorListPage({super.key});

//   @override
//   State<DoctorListPage> createState() => _DoctorListPageState();
// }

// class _DoctorListPageState extends State<DoctorListPage> {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
//     'Doctors',
//   );
//   List<Doctor> _doctors = [];
//   List<Doctor> _filteredDoctors = [];
//   bool _isLoading = true;
//   String _selectedCategory = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctors();
//     _searchController.addListener(_filterDoctors);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchDoctors() async {
//     try {
//       await _database.once().then((DatabaseEvent event) {
//         DataSnapshot snapshot = event.snapshot;
//         List<Doctor> tmpDoctors = [];
//         if (snapshot.value != null) {
//           Map<dynamic, dynamic> values =
//               snapshot.value as Map<dynamic, dynamic>;
//           values.forEach((key, value) {
//             Doctor doctor = Doctor.fromMap(value, key);
//             tmpDoctors.add(doctor);
//           });
//         }
//         setState(() {
//           _doctors = tmpDoctors;
//           _filteredDoctors = tmpDoctors;
//           _isLoading = false;
//         });
//       });
//     } catch (e) {
//       print('Error fetching doctors: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Không thể tải danh sách bác sĩ: $e')),
//       );
//     }
//   }

//   void _filterDoctors() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredDoctors =
//           _doctors.where((doctor) {
//             final nameMatch = '${doctor.firstName} ${doctor.lastName}'
//                 .toLowerCase()
//                 .contains(query);
//             final categoryMatch = doctor.category.toLowerCase().contains(query);
//             final isCategorySelected =
//                 _selectedCategory.isEmpty ||
//                 doctor.category == _selectedCategory;
//             return (nameMatch || categoryMatch) && isCategorySelected;
//           }).toList();
//     });
//   }

//   void _selectCategory(String category) {
//     setState(() {
//       _selectedCategory = category == 'Xem tất cả' ? '' : category;
//     });
//     _filterDoctors();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child:
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0,
//                       vertical: 8.0,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 16),
//                         Text(
//                           'Tìm Bác Sĩ Phù Hợp',
//                           style: GoogleFonts.poppins(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         Text(
//                           'Khám phá các bác sĩ hàng đầu theo chuyên khoa',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: 'Tìm bác sĩ hoặc chuyên khoa...',
//                             hintStyle: GoogleFonts.poppins(
//                               color: Colors.grey[400],
//                             ),
//                             prefixIcon: const Icon(
//                               Icons.search,
//                               color: Colors.grey,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 12,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey[200]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Color(0xff006AFA),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Banner
//                         Container(
//                           height: 150,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: const Color(0xff006AFA),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 flex: 2,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(left: 16.0),
//                                   child: Text(
//                                     'Khám phá dịch vụ\ny tế tốt nhất',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Flexible(
//                                 flex: 1,
//                                 child: ClipRRect(
//                                   borderRadius: const BorderRadius.only(
//                                     topRight: Radius.circular(12),
//                                     bottomRight: Radius.circular(12),
//                                   ),
//                                   child: Image.asset(
//                                     'assets/images/doc_banner.png',
//                                     height: 150, // Match container height
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           'Chuyên Khoa',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         SizedBox(
//                           height: 200,
//                           child: GridView.count(
//                             crossAxisCount: 4,
//                             crossAxisSpacing: 8,
//                             mainAxisSpacing: 8,
//                             shrinkWrap: true,
//                             physics:
//                                 const NeverScrollableScrollPhysics(), // Disable GridView scrolling
//                             children: [
//                               _buildCategoryCard(
//                                 'Tổng quát',
//                                 'assets/images/stethoscope.png',
//                               ),
//                               _buildCategoryCard(
//                                 'Nha khoa',
//                                 'assets/images/infection.png',
//                               ),
//                               _buildCategoryCard(
//                                 'Tim mạch',
//                                 'assets/images/heart.png',
//                               ),
//                               _buildCategoryCard(
//                                 'Thần kinh',
//                                 'assets/images/brain.png',
//                               ),
//                               _buildCategoryCard(
//                                 'Phổi',
//                                 'assets/images/lungs.png',
//                               ),
//                               _buildCategoryCard(
//                                 'Tiêu hóa',
//                                 'assets/images/intestine.png',
//                               ),
//                               _buildCategoryCard(
//                                 'Xem tất cả',
//                                 'assets/images/grid.png',
//                                 isHighlighted: true,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Bác Sĩ Hàng Đầu',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () => _selectCategory('Xem tất cả'),
//                               child: Text(
//                                 'Xem Tất Cả',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xff006AFA),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         _filteredDoctors.isEmpty
//                             ? Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 20),
//                               child: Center(
//                                 child: Text(
//                                   'Không tìm thấy bác sĩ',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             : ListView.builder(
//                               physics:
//                                   const NeverScrollableScrollPhysics(), // Disable ListView scrolling
//                               shrinkWrap:
//                                   true, // Allow ListView to take only needed space
//                               itemCount: _filteredDoctors.length,
//                               itemBuilder: (context, index) {
//                                 return GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder:
//                                             (context) => DoctorDetailPage(
//                                               doctor: _filteredDoctors[index],
//                                             ),
//                                       ),
//                                     );
//                                   },
//                                   child: DoctorCard(
//                                     doctor: _filteredDoctors[index],
//                                   ),
//                                 );
//                               },
//                             ),
//                         const SizedBox(
//                           height: 16,
//                         ), // Extra padding at the bottom
//                       ],
//                     ),
//                   ),
//                 ),
//       ),
//     );
//   }

//   Widget _buildCategoryCard(
//     String title,
//     String iconPath, {
//     bool isHighlighted = false,
//   }) {
//     return GestureDetector(
//       onTap: () => _selectCategory(title),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color:
//               isHighlighted || _selectedCategory == title
//                   ? const Color(0xff006AFA)
//                   : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               iconPath,
//               width: 32,
//               height: 32,
//               color:
//                   isHighlighted || _selectedCategory == title
//                       ? Colors.white
//                       : null,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color:
//                     isHighlighted || _selectedCategory == title
//                         ? Colors.white
//                         : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_appointment/doctor/doctor_details_page.dart';
import 'package:doc_appointment/doctor/model/doctor.dart';
import 'package:doc_appointment/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage>
    with TickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    'Doctors',
  );
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchDoctors();
    _searchController.addListener(_filterDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      await _database.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        List<Doctor> tmpDoctors = [];
        if (snapshot.value != null) {
          Map<dynamic, dynamic> values =
              snapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            Doctor doctor = Doctor.fromMap(value, key);
            tmpDoctors.add(doctor);
          });
        }
        setState(() {
          _doctors = tmpDoctors;
          _filteredDoctors = tmpDoctors;
          _isLoading = false;
        });
        _animationController.forward();
      });
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách bác sĩ: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors =
          _doctors.where((doctor) {
            final nameMatch = '${doctor.firstName} ${doctor.lastName}'
                .toLowerCase()
                .contains(query);
            final categoryMatch = doctor.category.toLowerCase().contains(query);
            final isCategorySelected =
                _selectedCategory.isEmpty ||
                doctor.category == _selectedCategory;
            return (nameMatch || categoryMatch) && isCategorySelected;
          }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category == 'Xem tất cả' ? '' : category;
    });
    _filterDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child:
            _isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                  onRefresh: _fetchDoctors,
                  color: const Color(0xff006AFA),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          _buildSearchBar(),
                          _buildPromoBanner(),
                          _buildCategoriesSection(),
                          _buildDoctorsSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006AFA)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải danh sách bác sĩ...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tìm Bác Sĩ',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Phù Hợp',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff006AFA),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff006AFA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xff006AFA),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Khám phá các bác sĩ hàng đầu theo chuyên khoa',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Tìm bác sĩ hoặc chuyên khoa...',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF94A3B8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xff006AFA),
                size: 24,
              ),
            ),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterDoctors();
                      },
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    )
                    : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xff006AFA), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff006AFA), Color(0xff0052CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff006AFA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Khám phá dịch vụ',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          Text(
                            'y tế tốt nhất',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Đặt lịch ngay',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/doc_banner.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chuyên Khoa',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (_selectedCategory.isNotEmpty)
                TextButton(
                  onPressed: () => _selectCategory('Xem tất cả'),
                  child: Text(
                    'Xóa bộ lọc',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff006AFA),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 155,
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCategoryCard(
                  'Tổng quát',
                  'assets/images/stethoscope.png',
                ),
                _buildCategoryCard('Nha khoa', 'assets/images/infection.png'),
                _buildCategoryCard('Tim mạch', 'assets/images/heart.png'),
                _buildCategoryCard('Thần kinh', 'assets/images/brain.png'),
                _buildCategoryCard('Phổi', 'assets/images/lungs.png'),
                _buildCategoryCard('Tiêu hóa', 'assets/images/intestine.png'),
                _buildCategoryCard(
                  'Xem tất cả',
                  'assets/images/grid.png',
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bác Sĩ Hàng Đầu',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '${_filteredDoctors.length} bác sĩ có sẵn',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _selectCategory('Xem tất cả'),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Color(0xff006AFA),
                ),
                label: Text(
                  'Xem Tất Cả',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff006AFA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _filteredDoctors.isEmpty
              ? Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy bác sĩ',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy thử tìm kiếm với từ khóa khác',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _filteredDoctors.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 100)),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.only(bottom: 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DoctorDetailPage(
                                  doctor: _filteredDoctors[index],
                                ),
                          ),
                        );
                      },
                      child: DoctorCard(doctor: _filteredDoctors[index]),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String iconPath, {
    bool isHighlighted = false,
  }) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => _selectCategory(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient:
              isHighlighted || isSelected
                  ? const LinearGradient(
                    colors: [Color(0xff006AFA), Color(0xff0052CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isHighlighted || isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? const Color(0xff006AFA).withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
          border:
              isSelected
                  ? null
                  : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isHighlighted || isSelected
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xff006AFA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color:
                    isHighlighted || isSelected
                        ? Colors.white
                        : const Color(0xff006AFA),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    isHighlighted || isSelected
                        ? Colors.white
                        : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
