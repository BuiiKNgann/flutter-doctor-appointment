// import 'package:doc_appointment/doctor/model/doctor.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class DoctorProfileUpdatePage extends StatefulWidget {
//   const DoctorProfileUpdatePage({super.key});

//   @override
//   State<DoctorProfileUpdatePage> createState() =>
//       _DoctorProfileUpdatePageState();
// }

// class _DoctorProfileUpdatePageState extends State<DoctorProfileUpdatePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Doctors');
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = true;

//   // Controllers for form fields
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _categoryController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _profileImageUrlController =
//       TextEditingController();
//   final TextEditingController _yearsOfExperienceController =
//       TextEditingController();
//   final TextEditingController _qualificationController =
//       TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _latitudeController = TextEditingController();
//   final TextEditingController _longitudeController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _reviewCountController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctorProfile();
//   }

//   Future<void> _fetchDoctorProfile() async {
//     String? currentUserId = _auth.currentUser?.uid;
//     if (currentUserId != null) {
//       final snapshot = await _doctorDatabase.child(currentUserId).once();
//       if (snapshot.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
//         final doctor = Doctor.fromMap(data, currentUserId);
//         _firstNameController.text = doctor.firstName;
//         _lastNameController.text = doctor.lastName;
//         _categoryController.text = doctor.category;
//         _cityController.text = doctor.city;
//         _profileImageUrlController.text = doctor.profileImageUrl;
//         _yearsOfExperienceController.text = doctor.yearsOfExperience;
//         _qualificationController.text = doctor.qualification;
//         _phoneNumberController.text = doctor.phoneNumber;
//         _latitudeController.text = doctor.latitude.toString();
//         _longitudeController.text = doctor.longitude.toString();
//         _descriptionController.text = doctor.description;
//         _reviewCountController.text = doctor.reviewCount.toString();
//       }
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       String? currentUserId = _auth.currentUser?.uid;
//       if (currentUserId != null) {
//         final updatedData = {
//           'firstName': _firstNameController.text.trim(),
//           'lastName': _lastNameController.text.trim(),
//           'category': _categoryController.text.trim(),
//           'city': _cityController.text.trim(),
//           'profileImageUrl': _profileImageUrlController.text.trim(),
//           'yearsOfExperience': _yearsOfExperienceController.text.trim(),
//           'qualification': _qualificationController.text.trim(),
//           'phoneNumber': _phoneNumberController.text.trim(),
//           'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
//           'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
//           'description': _descriptionController.text.trim(),
//           'reviewCount': int.tryParse(_reviewCountController.text.trim()) ?? 0,
//         };
//         await _doctorDatabase.child(currentUserId).update(updatedData);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Cập nhật thông tin thành công')),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Cập nhật thông tin bác sĩ')),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         TextFormField(
//                           controller: _firstNameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Họ',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập họ';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _lastNameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Tên',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập tên';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _categoryController,
//                           decoration: const InputDecoration(
//                             labelText: 'Chuyên môn',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập chuyên môn';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _cityController,
//                           decoration: const InputDecoration(
//                             labelText: 'Thành phố',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập thành phố';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _profileImageUrlController,
//                           decoration: const InputDecoration(
//                             labelText: 'URL ảnh hồ sơ',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập URL ảnh hồ sơ';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _yearsOfExperienceController,
//                           decoration: const InputDecoration(
//                             labelText: 'Số năm kinh nghiệm',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập số năm kinh nghiệm';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _qualificationController,
//                           decoration: const InputDecoration(
//                             labelText: 'Bằng cấp',
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập bằng cấp';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _phoneNumberController,
//                           decoration: const InputDecoration(
//                             labelText: 'Số điện thoại',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.phone,
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập số điện thoại';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _latitudeController,
//                           decoration: const InputDecoration(
//                             labelText: 'Vĩ độ',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập vĩ độ';
//                             }
//                             if (double.tryParse(value) == null) {
//                               return 'Vĩ độ phải là một số';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _longitudeController,
//                           decoration: const InputDecoration(
//                             labelText: 'Kinh độ',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập kinh độ';
//                             }
//                             if (double.tryParse(value) == null) {
//                               return 'Kinh độ phải là một số';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _descriptionController,
//                           decoration: const InputDecoration(
//                             labelText: 'Mô tả',
//                             border: OutlineInputBorder(),
//                           ),
//                           maxLines: 4,
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập mô tả';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _reviewCountController,
//                           decoration: const InputDecoration(
//                             labelText: 'Số lượng đánh giá',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Vui lòng nhập số lượng đánh giá';
//                             }
//                             if (int.tryParse(value) == null) {
//                               return 'Số lượng đánh giá phải là một số';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: _updateProfile,
//                           child: const Text('Cập nhật'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//     );
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _categoryController.dispose();
//     _cityController.dispose();
//     _profileImageUrlController.dispose();
//     _yearsOfExperienceController.dispose();
//     _qualificationController.dispose();
//     _phoneNumberController.dispose();
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     _descriptionController.dispose();
//     _reviewCountController.dispose();
//     super.dispose();
//   }
// }
import 'dart:io';
import 'package:doc_appointment/doctor/model/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class DoctorProfileUpdatePage extends StatefulWidget {
  const DoctorProfileUpdatePage({super.key});

  @override
  State<DoctorProfileUpdatePage> createState() =>
      _DoctorProfileUpdatePageState();
}

class _DoctorProfileUpdatePageState extends State<DoctorProfileUpdatePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _doctorDatabase = FirebaseDatabase.instance
      .ref()
      .child('Doctors');
  final cloudinary = CloudinaryPublic('djzcgu0xl', 'upload', cache: true);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _yearsOfExperienceController =
      TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reviewCountController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _profileImageUrl = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      final snapshot = await _doctorDatabase.child(currentUserId).once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        final doctor = Doctor.fromMap(data, currentUserId);
        _firstNameController.text = doctor.firstName;
        _lastNameController.text = doctor.lastName;
        _categoryController.text = doctor.category;
        _cityController.text = doctor.city;
        _profileImageUrl = doctor.profileImageUrl;
        _yearsOfExperienceController.text = doctor.yearsOfExperience;
        _qualificationController.text = doctor.qualification;
        _phoneNumberController.text = doctor.phoneNumber;
        _latitude = doctor.latitude;
        _longitude = doctor.longitude;
        _descriptionController.text = doctor.description;
        _reviewCountController.text = doctor.reviewCount.toString();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locationData = await _location.getLocation();
      if (mounted) {
        setState(() {
          _latitude = locationData.latitude!;
          _longitude = locationData.longitude!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể lấy vị trí. Vui lòng kiểm tra quyền vị trí.',
            ),
          ),
        );
      }
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (_imageFile == null) return _profileImageUrl;

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _imageFile!.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải ảnh lên: $e')));
      }
      return _profileImageUrl;
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final String? currentUserId = _auth.currentUser?.uid;
        if (currentUserId != null) {
          final String? imageUrl = await _uploadImageToCloudinary();
          final updatedData = {
            'uid': currentUserId,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'category': _categoryController.text,
            'city': _cityController.text,
            'profileImageUrl': imageUrl ?? '',
            'yearsOfExperience': _yearsOfExperienceController.text.trim(),
            'qualification': _qualificationController.text.trim(),
            'phoneNumber': _phoneNumberController.text.trim(),
            'latitude': _latitude,
            'longitude': _longitude,
            'description': _descriptionController.text.trim(),
            'reviewCount':
                int.tryParse(_reviewCountController.text.trim()) ?? 0,
            'totalReviews': 0,
            'averageRating': 0.0,
            'numberOfReviews': 0,
          };
          await _doctorDatabase.child(currentUserId).update(updatedData);
          await _auth.currentUser!.updateDisplayName(
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thông tin thành công')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    double height = 44,
  }) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: maxLines > 1 ? 12 : 0,
          ),
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xff0064FA), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String labelText,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items:
            items.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
        onChanged: (val) {
          if (val != null) controller.text = val;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xff0064FA), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child:
                _imageFile != null
                    ? Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                    )
                    : _profileImageUrl.isNotEmpty
                    ? Image.network(
                      _profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                    )
                    : _buildImagePlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 30),
            const SizedBox(height: 4),
            Text(
              'Chọn ảnh',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Màu nền xám nhạt
      appBar: AppBar(
        title: Text(
          'Cập nhật thông tin bác sĩ',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 24),

                        _buildFormField(
                          controller: _firstNameController,
                          labelText: 'Họ',
                          validator:
                              (val) => val!.isEmpty ? 'Vui lòng nhập họ' : null,
                        ),
                        const SizedBox(height: 16),

                        _buildFormField(
                          controller: _lastNameController,
                          labelText: 'Tên',
                          validator:
                              (val) =>
                                  val!.isEmpty ? 'Vui lòng nhập tên' : null,
                        ),
                        const SizedBox(height: 16),

                        _buildDropdownField(
                          controller: _cityController,
                          labelText: 'Thành phố',
                          items: [
                            'Hồ Chí Minh',
                            'Hà Nội',
                            'Đà Nẵng',
                            'Nha Trang',
                          ],
                          validator:
                              (val) => val == null ? 'Chọn thành phố' : null,
                        ),
                        const SizedBox(height: 16),

                        _buildDropdownField(
                          controller: _categoryController,
                          labelText: 'Chuyên môn',
                          items: [
                            'Nha sĩ',
                            'Tim mạch',
                            'Tổng quát',
                            'Tiêu hóa',
                          ],
                          validator:
                              (val) => val == null ? 'Chọn chuyên môn' : null,
                        ),
                        const SizedBox(height: 16),

                        _buildFormField(
                          controller: _qualificationController,
                          labelText: 'Bằng cấp',
                          validator:
                              (val) =>
                                  val!.isEmpty
                                      ? 'Vui lòng nhập bằng cấp'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        _buildFormField(
                          controller: _yearsOfExperienceController,
                          labelText: 'Số năm kinh nghiệm',
                          keyboardType: TextInputType.number,
                          validator:
                              (val) =>
                                  val!.isEmpty
                                      ? 'Vui lòng nhập số năm kinh nghiệm'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        _buildFormField(
                          controller: _phoneNumberController,
                          labelText: 'Số điện thoại',
                          keyboardType: TextInputType.phone,
                          validator:
                              (val) =>
                                  val!.isEmpty
                                      ? 'Vui lòng nhập số điện thoại'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        _buildFormField(
                          controller: _descriptionController,
                          labelText: 'Mô tả',
                          maxLines: 4,
                          height: 100,
                          validator:
                              (val) =>
                                  val!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _getLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFA9600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            child: Text(
                              'Lấy vị trí hiện tại',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        if (_latitude != 0.0 && _longitude != 0.0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Vị trí: (${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0064FA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            child: Text(
                              'Cập nhật',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _categoryController.dispose();
    _cityController.dispose();
    _yearsOfExperienceController.dispose();
    _qualificationController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    _reviewCountController.dispose();
    super.dispose();
  }
}
