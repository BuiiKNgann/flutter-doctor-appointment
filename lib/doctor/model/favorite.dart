import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Favorite {
  final String patientUid;
  final String doctorUid;
  final DatabaseReference _favoritesDatabase = FirebaseDatabase.instance
      .ref()
      .child('Favorites');

  Favorite({required this.patientUid, required this.doctorUid});

  Future<void> addToFavorites() async {
    try {
      await _favoritesDatabase.child(patientUid).child(doctorUid).set(true);
    } catch (e) {
      throw Exception('Lỗi khi thêm bác sĩ vào yêu thích: $e');
    }
  }

  Future<void> removeFromFavorites() async {
    try {
      await _favoritesDatabase.child(patientUid).child(doctorUid).remove();
    } catch (e) {
      throw Exception('Lỗi khi xóa bác sĩ khỏi yêu thích: $e');
    }
  }

  Future<bool> isFavorite() async {
    try {
      final snapshot =
          await _favoritesDatabase.child(patientUid).child(doctorUid).once();
      return snapshot.snapshot.value == true;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra trạng thái yêu thích: $e');
    }
  }

  static Future<List<String>> getFavoriteDoctorUids(String patientUid) async {
    try {
      final snapshot =
          await FirebaseDatabase.instance
              .ref()
              .child('Favorites')
              .child(patientUid)
              .once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> favorites =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        return favorites.keys.cast<String>().toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách bác sĩ yêu thích: $e');
    }
  }
}
