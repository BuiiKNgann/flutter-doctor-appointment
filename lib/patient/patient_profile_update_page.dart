// import 'dart:io';
// import 'package:doc_appointment/doctor/model/patient.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:location/location.dart';
// import 'package:cloudinary_public/cloudinary_public.dart';

// class PatientProfileUpdatePage extends StatefulWidget {
//   const PatientProfileUpdatePage({super.key});

//   @override
//   State<PatientProfileUpdatePage> createState() =>
//       _PatientProfileUpdatePageState();
// }

// class _PatientProfileUpdatePageState extends State<PatientProfileUpdatePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _patientDatabase = FirebaseDatabase.instance
//       .ref()
//       .child('Patients');
//   final cloudinary = CloudinaryPublic('djzcgu0xl', 'upload', cache: true);
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = true;

//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();

//   final ImagePicker _picker = ImagePicker();
//   XFile? _imageFile;
//   String _profileImageUrl = '';
//   double _latitude = 0.0;
//   double _longitude = 0.0;
//   final Location _location = Location();

//   @override
//   void initState() {
//     super.initState();
//     _fetchPatientProfile();
//   }

//   Future<void> _fetchPatientProfile() async {
//     String? currentUserId = _auth.currentUser?.uid;
//     if (currentUserId != null) {
//       final snapshot = await _patientDatabase.child(currentUserId).once();
//       if (snapshot.snapshot.value != null) {
//         final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
//         final patient = Patient.fromMap(data);
//         _firstNameController.text = patient.firstName;
//         _lastNameController.text = patient.lastName;
//         _phoneNumberController.text = patient.phoneNumber;
//         _cityController.text = patient.city;
//         _emailController.text = patient.email;
//         _profileImageUrl = patient.profileImageUrl;
//         _latitude = patient.latitude;
//         _longitude = patient.longitude;
//       }
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = pickedFile;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
//     }
//   }

//   Future<void> _getLocation() async {
//     try {
//       bool serviceEnabled = await _location.serviceEnabled();
//       if (!serviceEnabled) {
//         serviceEnabled = await _location.requestService();
//         if (!serviceEnabled) return;
//       }

//       PermissionStatus permissionGranted = await _location.hasPermission();
//       if (permissionGranted == PermissionStatus.denied) {
//         permissionGranted = await _location.requestPermission();
//         if (permissionGranted != PermissionStatus.granted) return;
//       }

//       final locationData = await _location.getLocation();
//       setState(() {
//         _latitude = locationData.latitude!;
//         _longitude = locationData.longitude!;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Không thể lấy vị trí. Vui lòng kiểm tra quyền vị trí.',
//           ),
//         ),
//       );
//     }
//   }

//   Future<String?> _uploadImageToCloudinary() async {
//     if (_imageFile == null) return _profileImageUrl;

//     try {
//       CloudinaryResponse response = await cloudinary.uploadFile(
//         CloudinaryFile.fromFile(
//           _imageFile!.path,
//           resourceType: CloudinaryResourceType.Image,
//         ),
//       );
//       return response.secureUrl;
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Không thể tải ảnh lên: $e')));
//       return _profileImageUrl;
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         String? currentUserId = _auth.currentUser?.uid;
//         if (currentUserId != null) {
//           String? imageUrl = await _uploadImageToCloudinary();
//           final updatedData = {
//             'uid': currentUserId,
//             'firstName': _firstNameController.text.trim(),
//             'lastName': _lastNameController.text.trim(),
//             'phoneNumber': _phoneNumberController.text.trim(),
//             'city': _cityController.text,
//             'profileImageUrl': imageUrl ?? '',
//             'latitude': _latitude,
//             'longitude': _longitude,
//             'email': _emailController.text.trim(),
//           };
//           await _patientDatabase.child(currentUserId).update(updatedData);
//           await _auth.currentUser!.updateDisplayName(
//             '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
//           );
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cập nhật thông tin thành công')),
//           );
//           Navigator.pop(context);
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Thông tin cá nhân',
//           style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
//         ),
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(100),
//                             child:
//                                 _imageFile != null
//                                     ? Image.file(
//                                       File(_imageFile!.path),
//                                       width: 100,
//                                       height: 100,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               Container(
//                                                 color: const Color(0xffF0EFFF),
//                                                 width: 100,
//                                                 height: 100,
//                                                 child: Center(
//                                                   child: Icon(
//                                                     Icons.add_a_photo,
//                                                     color: Colors.grey.shade600,
//                                                     size: 30,
//                                                   ),
//                                                 ),
//                                               ),
//                                     )
//                                     : _profileImageUrl.isNotEmpty
//                                     ? Image.network(
//                                       _profileImageUrl,
//                                       width: 100,
//                                       height: 100,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               Container(
//                                                 color: const Color(0xffF0EFFF),
//                                                 width: 100,
//                                                 height: 100,
//                                                 child: Center(
//                                                   child: Icon(
//                                                     Icons.add_a_photo,
//                                                     color: Colors.grey.shade600,
//                                                     size: 30,
//                                                   ),
//                                                 ),
//                                               ),
//                                     )
//                                     : Container(
//                                       color: const Color(0xffF0EFFF),
//                                       width: 100,
//                                       height: 100,
//                                       child: Center(
//                                         child: Icon(
//                                           Icons.add_a_photo,
//                                           color: Colors.grey.shade600,
//                                           size: 30,
//                                         ),
//                                       ),
//                                     ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
//                             controller: _emailController,
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xffF0EFFF),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               labelText: 'Email',
//                               labelStyle: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             enabled: false, // Email is read-only
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
//                             controller: _firstNameController,
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xffF0EFFF),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               labelText: 'Họ',
//                               labelStyle: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             validator:
//                                 (val) =>
//                                     val!.isEmpty ? 'Vui lòng nhập họ' : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
//                             controller: _lastNameController,
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xffF0EFFF),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               labelText: 'Tên',
//                               labelStyle: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             validator:
//                                 (val) =>
//                                     val!.isEmpty ? 'Vui lòng nhập tên' : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
//                             controller: _phoneNumberController,
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xffF0EFFF),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               labelText: 'Số điện thoại',
//                               labelStyle: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             keyboardType: TextInputType.phone,
//                             validator:
//                                 (val) =>
//                                     val!.isEmpty
//                                         ? 'Vui lòng nhập số điện thoại'
//                                         : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: DropdownButtonFormField<String>(
//                             value:
//                                 _cityController.text.isEmpty
//                                     ? null
//                                     : _cityController.text,
//                             items:
//                                 [
//                                   'Hồ Chí Minh',
//                                   'Hà Nội',
//                                   'Đà Nẵng',
//                                   'Nha Trang',
//                                 ].map((String city) {
//                                   return DropdownMenuItem(
//                                     value: city,
//                                     child: Text(
//                                       city,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                             onChanged: (val) {
//                               _cityController.text = val!;
//                             },
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xffF0EFFF),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               labelText: 'Thành phố',
//                               labelStyle: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade400,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: const BorderSide(
//                                   color: Color(0xff0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             validator:
//                                 (val) => val == null ? 'Chọn thành phố' : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _getLocation,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xffFA9600),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: Text(
//                               'Lấy vị trí hiện tại',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         if (_latitude != 0.0 && _longitude != 0.0)
//                           Text(
//                             'Vị trí: ($_latitude, $_longitude)',
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _updateProfile,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xff0064FA),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: Text(
//                               'Cập nhật',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
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
//     _phoneNumberController.dispose();
//     _cityController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
// }
import 'dart:io';
import 'package:doc_appointment/doctor/model/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class PatientProfileUpdatePage extends StatefulWidget {
  const PatientProfileUpdatePage({super.key});

  @override
  State<PatientProfileUpdatePage> createState() =>
      _PatientProfileUpdatePageState();
}

class _PatientProfileUpdatePageState extends State<PatientProfileUpdatePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _patientDatabase = FirebaseDatabase.instance
      .ref()
      .child('Patients');
  final cloudinary = CloudinaryPublic('djzcgu0xl', 'upload', cache: true);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _profileImageUrl = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _fetchPatientProfile();
  }

  Future<void> _fetchPatientProfile() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      final snapshot = await _patientDatabase.child(currentUserId).once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        final patient = Patient.fromMap(data);
        _firstNameController.text = patient.firstName;
        _lastNameController.text = patient.lastName;
        _phoneNumberController.text = patient.phoneNumber;
        _cityController.text = patient.city;
        _emailController.text = patient.email;
        _profileImageUrl = patient.profileImageUrl;
        _latitude = patient.latitude;
        _longitude = patient.longitude;
      }
      setState(() {
        _isLoading = false;
      });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
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
      setState(() {
        _latitude = locationData.latitude!;
        _longitude = locationData.longitude!;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể lấy vị trí. Vui lòng kiểm tra quyền vị trí.',
          ),
        ),
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải ảnh lên: $e')));
      return _profileImageUrl;
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? currentUserId = _auth.currentUser?.uid;
        if (currentUserId != null) {
          String? imageUrl = await _uploadImageToCloudinary();
          final updatedData = {
            'uid': currentUserId,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phoneNumber': _phoneNumberController.text.trim(),
            'city': _cityController.text,
            'profileImageUrl': imageUrl ?? '',
            'latitude': _latitude,
            'longitude': _longitude,
            'email': _emailController.text.trim(),
          };
          await _patientDatabase.child(currentUserId).update(updatedData);
          await _auth.currentUser!.updateDisplayName(
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin thành công')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Changed to white-gray background
      appBar: AppBar(
        title: Text(
          'Thông tin cá nhân',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87, // Dark text for contrast
          ),
        ),
        backgroundColor: Colors.white, // White app bar for clean look
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child:
                                _imageFile != null
                                    ? Image.file(
                                      File(_imageFile!.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: const Color(0xffF0EFFF),
                                                width: 100,
                                                height: 100,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.add_a_photo,
                                                    color: Colors.grey.shade600,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                    )
                                    : _profileImageUrl.isNotEmpty
                                    ? Image.network(
                                      _profileImageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: const Color(0xffF0EFFF),
                                                width: 100,
                                                height: 100,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.add_a_photo,
                                                    color: Colors.grey.shade600,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                    )
                                    : Container(
                                      color: const Color(0xffF0EFFF),
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey.shade600,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            controller: _emailController,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  Colors.white, // White fill for contrast
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            enabled: false, // Email is read-only
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            controller: _firstNameController,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  Colors.white, // White fill for contrast
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              labelText: 'Họ',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator:
                                (val) =>
                                    val!.isEmpty ? 'Vui lòng nhập họ' : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            controller: _lastNameController,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  Colors.white, // White fill for contrast
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              labelText: 'Tên',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator:
                                (val) =>
                                    val!.isEmpty ? 'Vui lòng nhập tên' : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            controller: _phoneNumberController,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  Colors.white, // White fill for contrast
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              labelText: 'Số điện thoại',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator:
                                (val) =>
                                    val!.isEmpty
                                        ? 'Vui lòng nhập số điện thoại'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: DropdownButtonFormField<String>(
                            value:
                                _cityController.text.isEmpty
                                    ? null
                                    : _cityController.text,
                            items:
                                [
                                  'Hồ Chí Minh',
                                  'Hà Nội',
                                  'Đà Nẵng',
                                  'Nha Trang',
                                ].map((String city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      city,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              _cityController.text = val!;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  Colors.white, // White fill for contrast
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              labelText: 'Thành phố',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff0064FA),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator:
                                (val) => val == null ? 'Chọn thành phố' : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _getLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFA9600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Lấy vị trí hiện tại',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_latitude != 0.0 && _longitude != 0.0)
                          Text(
                            'Vị trí: ($_latitude, $_longitude)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  Colors
                                      .grey
                                      .shade700, // Darker text for contrast
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0064FA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Cập nhật',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
    _phoneNumberController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
