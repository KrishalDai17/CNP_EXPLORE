import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyBookingPage extends StatelessWidget {
  const MyBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Booking History", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: userId)
                  .orderBy('bookingTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("No bookings yet."));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    // Matches the lowercase strings from our Payment Logic
                    final String status = data['status'] ?? 'pending'; 
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (data['activities'] as List).first ?? "Activity", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                                _statusBadge(status),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 5),
                            Text("📅 Date: ${data['date']}"),
                            Text("⏰ Time: ${data['time']}"),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Amount:", style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  "Rs. ${data['totalAmount']}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)
                                ),
                              ],
                            ),
                            if (status == 'pending')
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Wait for admin to verify payment...",
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _statusBadge(String status) {
    // Logic: Green only if 'confirmed'. Orange if 'pending'. Red if 'cancelled'.
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        label = "SUCCESSFUL";
        break;
      case 'pending':
        color = Colors.orange;
        label = "PENDING ADMIN";
        break;
      case 'cancelled':
        color = Colors.red;
        label = "CANCELLED";
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}