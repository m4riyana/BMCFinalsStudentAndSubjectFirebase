import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<bool> saveStudentData({
    required String name,
    required String section,
    required String yearLevel,
    required List<Map<String, String>> subjects,
  }) async {
    try {
      await firestore.collection('students').add({
        'Name': name,
        'Section': section,
        'Year Level': yearLevel,
        'Subjects': subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
