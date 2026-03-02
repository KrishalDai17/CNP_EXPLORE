import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  static Future<void> saveToFirebase({
    required List<String> activities,
    required String date,
    required String time,
    required int total,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Admin sees this name in their portal
    String name = user.displayName ?? user.email?.split('@')[0] ?? "Guest";

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user.uid,
      'userName': name, 
      'activities': activities,
      'date': date,
      'time': time,
      'totalAmount': total,
      'status': 'Confirmed', 
      'paymentMethod': 'eSewa',
      'bookingTimestamp': FieldValue.serverTimestamp(),
    });
  }
}