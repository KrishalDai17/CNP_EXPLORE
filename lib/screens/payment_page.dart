import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';

class PaymentPage extends StatefulWidget {
  final String activityName;
  final DateTime date;
  final String time;
  final int totalAmount;
  final String bookingId; // Add this to receive the ID from the previous page

  const PaymentPage({
    super.key,
    required this.activityName,
    required this.date,
    required this.time,
    required this.totalAmount,
    required this.bookingId, // Make it required
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  bool isSavingToFirebase = false;

  final List<Map<String, String>> paymentMethods = [
    {"name": "Khalti", "image": "assets/images/khaltilogo.png"},
    {"name": "eSewa", "image": "assets/images/esewalogo.png"},
  ];

  void _payWithEsewa() {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R",
          secretId: "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==",
        ),
        esewaPayment: EsewaPayment(
          productId: widget.bookingId, // Use your actual booking ID here
          productName: widget.activityName,
          productPrice: widget.totalAmount.toString(),
          callbackUrl: "https://example.com/",
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          // Instead of a generic save, we UPDATE the existing record
          _updateBookingStatus(refId: data.refId);
        },
        onPaymentFailure: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment Failed or Technical Error")),
          );
        },
        onPaymentCancellation: (data) => debugPrint("User cancelled payment"),
      );
    } catch (e) {
      debugPrint("SDK Error: $e");
    }
  }

  // --- THE FIX: UPDATE EXISTING INSTEAD OF SAVING NEW ---
  Future<void> _updateBookingStatus({required String refId}) async {
    setState(() => isSavingToFirebase = true);
    try {
      // We use .doc(widget.bookingId).update to avoid duplicates
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'status': 'pending', // Keeps it orange/pending for Admin
        'transactionId': refId,
        'paymentMethod': 'eSewa',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) _showPendingApprovalDialog();
    } catch (e) {
      debugPrint("Firebase Update Error: $e");
    } finally {
      if (mounted) setState(() => isSavingToFirebase = false);
    }
  }

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange),
            SizedBox(width: 10),
            Text("Payment Received"),
          ],
        ),
        content: const Text(
          "Your payment is successful! Your booking is now **Pending Admin Confirmation**. "
          "You will be notified once the admin verifies the transaction.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("Go to Home"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... UI remains the same as your previous code ...
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Select Payment Method"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose your payment method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...paymentMethods.map((method) {
              bool isSelected = selectedMethod == method["name"];
              return GestureDetector(
                onTap: () => setState(() => selectedMethod = method["name"]),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.asset(method["image"]!, width: 50, height: 50, fit: BoxFit.contain),
                    title: Text(method["name"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    trailing: Radio<String>(
                      value: method["name"]!,
                      groupValue: selectedMethod,
                      onChanged: (value) => setState(() => selectedMethod = value),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (selectedMethod == null || isSavingToFirebase)
                    ? null
                    : () {
                        if (selectedMethod == "eSewa") {
                          _payWithEsewa();
                        } else if (selectedMethod == "Khalti") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Khalti support coming soon!")),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FBF26),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: isSavingToFirebase 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pay Now", style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}