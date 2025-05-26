// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:location/location.dart';
// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'package:doc_appointment/doctor/doctor_home_page.dart';
// import 'package:doc_appointment/patient/patient_home_page.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   final cloudinary = CloudinaryPublic(
//     'djzcgu0xl',
//     'upload',
//     cache: true,
//   ); // Thay bằng thông tin Cloudinary của bạn

//   final _formKey = GlobalKey<FormState>();
//   String userType = 'Patient';
//   String email = '';
//   String password = '';
//   String phoneNumber = '';
//   String firstName = '';
//   String lastName = '';
//   String city = 'Hồ Chí Minh';
//   String profileImageUrl = ''; // Lưu URL ảnh từ Cloudinary
//   String category = 'Tổng quát';
//   String qualification = '';
//   String yearsOfExperience = '';
//   String description = ''; // Thêm trường description
//   double latitude = 0.0;
//   double longitude = 0.0;

//   final ImagePicker _picker = ImagePicker();
//   XFile? _imageFile;

//   final Location _location = Location();
//   bool _isLoading = false;
//   bool _obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Đăng ký',
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
//                         SizedBox(
//                           width: double.infinity,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Chọn Loại Người Dùng',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               Wrap(
//                                 spacing: 8.0,
//                                 children:
//                                     ['Patient', 'Doctor'].map((String type) {
//                                       final isSelected = userType == type;
//                                       return ChoiceChip(
//                                         checkmarkColor: Colors.white,
//                                         label: Text(type),
//                                         selected: isSelected,
//                                         selectedColor: const Color(0xff0064FA),
//                                         backgroundColor: const Color(
//                                           0xffF0EFFF,
//                                         ),
//                                         labelStyle: GoogleFonts.poppins(
//                                           color:
//                                               isSelected
//                                                   ? Colors.white
//                                                   : const Color(0xff0064FA),
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             20.0,
//                                           ),
//                                           side: const BorderSide(
//                                             color: Color(0xff0064FA),
//                                             width: 2.0,
//                                           ),
//                                         ),
//                                         onSelected: (bool selected) {
//                                           setState(() {
//                                             userType =
//                                                 (selected ? type : null)!;
//                                           });
//                                         },
//                                       );
//                                     }).toList(),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: const Color(0xffF0EFFF),
//                               contentPadding: const EdgeInsets.only(
//                                 left: 10,
//                                 right: 10,
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
//                                   color: Color(0xFF0064FA),
//                                   width: 1.0,
//                                 ),
//                               ),
//                             ),
//                             keyboardType: TextInputType.emailAddress,
//                             onChanged: (val) => email = val,
//                             validator:
//                                 (val) => val!.isEmpty ? 'Nhập email' : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
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
//                               labelText: 'Mật khẩu',
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
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _obscureText
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscureText = !_obscureText;
//                                   });
//                                 },
//                               ),
//                             ),
//                             obscureText: _obscureText,
//                             keyboardType: TextInputType.text,
//                             onChanged: (val) => password = val,
//                             validator:
//                                 (val) =>
//                                     val!.length < 6
//                                         ? 'Mật khẩu phải có ít nhất 6 ký tự'
//                                         : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
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
//                             onChanged: (val) => phoneNumber = val,
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
//                           child: TextFormField(
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
//                             keyboardType: TextInputType.text,
//                             onChanged: (val) => firstName = val,
//                             validator:
//                                 (val) =>
//                                     val!.isEmpty ? 'Vui lòng nhập họ' : null,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 44,
//                           child: TextFormField(
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
//                             keyboardType: TextInputType.text,
//                             onChanged: (val) => lastName = val,
//                             validator:
//                                 (val) =>
//                                     val!.isEmpty ? 'Vui lòng nhập tên' : null,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           height: 44,
//                           child: DropdownButtonFormField<String>(
//                             value: city,
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
//                               setState(() {
//                                 city = val!;
//                               });
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
//                         if (userType == 'Doctor') ...[
//                           SizedBox(
//                             height: 44,
//                             child: TextFormField(
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: const Color(0xffF0EFFF),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                 ),
//                                 labelText: 'Học vấn',
//                                 labelStyle: GoogleFonts.poppins(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                               ),
//                               onChanged: (val) => qualification = val,
//                               validator:
//                                   (val) =>
//                                       val!.isEmpty
//                                           ? 'Vui lòng nhập học vấn'
//                                           : null,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             height: 44,
//                             child: DropdownButtonFormField<String>(
//                               value: category,
//                               items:
//                                   [
//                                     'Nha sĩ',
//                                     'Tim mạch',
//                                     'Tổng quát',
//                                     'Tiêu hóa',
//                                   ].map((String category) {
//                                     return DropdownMenuItem(
//                                       value: category,
//                                       child: Text(
//                                         category,
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                               onChanged: (val) {
//                                 setState(() {
//                                   category = val!;
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: const Color(0xffF0EFFF),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                 ),
//                                 labelText: 'Chuyên môn',
//                                 labelStyle: GoogleFonts.poppins(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                               ),
//                               validator:
//                                   (val) =>
//                                       val == null ? 'Chọn chuyên môn' : null,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             height: 44,
//                             child: TextFormField(
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: const Color(0xffF0EFFF),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                 ),
//                                 labelText: 'Kinh nghiệm',
//                                 labelStyle: GoogleFonts.poppins(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                               ),
//                               keyboardType: TextInputType.number,
//                               onChanged: (val) => yearsOfExperience = val,
//                               validator:
//                                   (val) =>
//                                       val!.isEmpty
//                                           ? 'Vui lòng nhập kinh nghiệm'
//                                           : null,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             height: 100, // Tăng chiều cao cho trường mô tả
//                             child: TextFormField(
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: const Color(0xffF0EFFF),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 10,
//                                 ),
//                                 labelText: 'Mô tả',
//                                 labelStyle: GoogleFonts.poppins(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff0064FA),
//                                     width: 1.0,
//                                   ),
//                                 ),
//                               ),
//                               keyboardType: TextInputType.multiline,
//                               maxLines: 4,
//                               onChanged: (val) => description = val,
//                               validator:
//                                   (val) =>
//                                       val!.isEmpty
//                                           ? 'Vui lòng nhập mô tả'
//                                           : null,
//                             ),
//                           ),
//                         ],
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
//                         if (latitude != 0.0 && longitude != 0.0)
//                           Text('Vị trí: ($latitude, $longitude)'),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _register,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xff0064FA),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             child: Text(
//                               'Đăng ký',
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

//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = pickedFile;
//         });
//       }
//     } catch (e) {}
//   }

//   Future<void> _getLocation() async {
//     try {
//       final locationData = await _location.getLocation();
//       setState(() {
//         latitude = locationData.latitude!;
//         longitude = locationData.longitude!;
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
//     if (_imageFile == null) return null;

//     try {
//       CloudinaryResponse response = await cloudinary.uploadFile(
//         CloudinaryFile.fromFile(
//           _imageFile!.path,
//           resourceType: CloudinaryResourceType.Image,
//         ),
//       );
//       print('Ảnh đã được tải lên: ${response.secureUrl}');
//       return response.secureUrl;
//     } catch (e) {
//       print('Lỗi khi tải ảnh lên: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Không thể tải ảnh lên: $e')));
//       return null;
//     }
//   }

//   Future<void> _register() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         UserCredential userCredential = await _auth
//             .createUserWithEmailAndPassword(email: email, password: password);
//         User? user = userCredential.user;

//         if (user != null) {
//           String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';
//           String? imageUrl = await _uploadImageToCloudinary();

//           Map<String, dynamic> userData = {
//             'uid': user.uid,
//             'email': email,
//             'phoneNumber': phoneNumber,
//             'firstName': firstName,
//             'lastName': lastName,
//             'city': city,
//             'profileImageUrl': imageUrl ?? '',
//             'latitude': latitude,
//             'longitude': longitude,
//           };

//           if (userType == 'Doctor') {
//             userData['qualification'] = qualification;
//             userData['category'] = category;
//             userData['yearsOfExperience'] = yearsOfExperience;
//             userData['description'] = description; // Lưu trường description
//             userData['totalReviews'] = 0;
//             userData['averageRating'] = 0.0;
//             userData['numberOfReviews'] = 0;
//           }

//           await _database.child(userTypePath).child(user.uid).set(userData);

//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder:
//                   (context) =>
//                       userType == 'Doctor'
//                           ? const DoctorHomePage()
//                           : const PatientHomePage(),
//             ),
//           );
//         }
//       } catch (e) {
//         _showErrorDialog(e.toString());
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Lỗi'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:doc_appointment/doctor/doctor_home_page.dart';
import 'package:doc_appointment/patient/patient_home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final cloudinary = CloudinaryPublic('djzcgu0xl', 'upload', cache: true);

  final _formKey = GlobalKey<FormState>();
  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'Hồ Chí Minh';
  String profileImageUrl = '';
  String category = 'Tổng quát';
  String qualification = '';
  String yearsOfExperience = '';
  String description = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final Location _location = Location();
  bool _isLoading = false;
  bool _obscureText = true;

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
        latitude = locationData.latitude!;
        longitude = locationData.longitude!;
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
    if (_imageFile == null) return null;

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _imageFile!.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      print('Ảnh đã được tải lên: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Lỗi khi tải ảnh lên: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải ảnh lên: $e')));
      return null;
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;

        if (user != null) {
          // Cập nhật displayName
          String displayName = '$firstName $lastName'.trim();
          if (displayName.isEmpty) {
            displayName = 'Unknown User';
          }
          await user.updateDisplayName(displayName);
          await user.reload();
          user = _auth.currentUser;

          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';
          String? imageUrl = await _uploadImageToCloudinary();

          Map<String, dynamic> userData = {
            'uid': user!.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'displayName': displayName, // Lưu displayName vào cơ sở dữ liệu
            'city': city,
            'profileImageUrl': imageUrl ?? '',
            'latitude': latitude,
            'longitude': longitude,
          };

          if (userType == 'Doctor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearsOfExperience;
            userData['description'] = description;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await _database.child(userTypePath).child(user.uid).set(userData);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      userType == 'Doctor'
                          ? const DoctorHomePage()
                          : const PatientHomePage(),
            ),
          );
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đăng ký',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
        ),
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
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn Loại Người Dùng',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Wrap(
                                spacing: 8.0,
                                children:
                                    ['Patient', 'Doctor'].map((String type) {
                                      final isSelected = userType == type;
                                      return ChoiceChip(
                                        checkmarkColor: Colors.white,
                                        label: Text(type),
                                        selected: isSelected,
                                        selectedColor: const Color(0xff0064FA),
                                        backgroundColor: const Color(
                                          0xffF0EFFF,
                                        ),
                                        labelStyle: GoogleFonts.poppins(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xff0064FA),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xff0064FA),
                                            width: 2.0,
                                          ),
                                        ),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            userType =
                                                (selected ? type : null)!;
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xffF0EFFF),
                              contentPadding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
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
                                  color: Color(0xFF0064FA),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) => email = val,
                            validator:
                                (val) => val!.isEmpty ? 'Nhập email' : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xffF0EFFF),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              labelText: 'Mật khẩu',
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureText,
                            keyboardType: TextInputType.text,
                            onChanged: (val) => password = val,
                            validator:
                                (val) =>
                                    val!.length < 6
                                        ? 'Mật khẩu phải có ít nhất 6 ký tự'
                                        : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xffF0EFFF),
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
                            onChanged: (val) => phoneNumber = val,
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
                          child: TextFormField(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xffF0EFFF),
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
                            keyboardType: TextInputType.text,
                            onChanged: (val) => firstName = val,
                            validator:
                                (val) =>
                                    val!.isEmpty ? 'Vui lòng nhập họ' : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: TextFormField(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xffF0EFFF),
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
                            keyboardType: TextInputType.text,
                            onChanged: (val) => lastName = val,
                            validator:
                                (val) =>
                                    val!.isEmpty ? 'Vui lòng nhập tên' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: DropdownButtonFormField<String>(
                            value: city,
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
                              setState(() {
                                city = val!;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xffF0EFFF),
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
                        if (userType == 'Doctor') ...[
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0EFFF),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                labelText: 'Học vấn',
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
                              onChanged: (val) => qualification = val,
                              validator:
                                  (val) =>
                                      val!.isEmpty
                                          ? 'Vui lòng nhập học vấn'
                                          : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: DropdownButtonFormField<String>(
                              value: category,
                              items:
                                  [
                                    'Nha sĩ',
                                    'Tim mạch',
                                    'Tổng quát',
                                    'Tiêu hóa',
                                  ].map((String category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  category = val!;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0EFFF),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                labelText: 'Chuyên môn',
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
                                      val == null ? 'Chọn chuyên môn' : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0EFFF),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                labelText: 'Kinh nghiệm',
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
                              keyboardType: TextInputType.number,
                              onChanged: (val) => yearsOfExperience = val,
                              validator:
                                  (val) =>
                                      val!.isEmpty
                                          ? 'Vui lòng nhập kinh nghiệm'
                                          : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0EFFF),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                labelText: 'Mô tả',
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
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              onChanged: (val) => description = val,
                              validator:
                                  (val) =>
                                      val!.isEmpty
                                          ? 'Vui lòng nhập mô tả'
                                          : null,
                            ),
                          ),
                        ],
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
                        if (latitude != 0.0 && longitude != 0.0)
                          Text('Vị trí: ($latitude, $longitude)'),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0064FA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Đăng ký',
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
}
