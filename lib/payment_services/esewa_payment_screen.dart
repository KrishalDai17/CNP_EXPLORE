import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'esewa_service.dart';

class EsewaPaymentScreen extends StatefulWidget {
  final int amount;
  const EsewaPaymentScreen({super.key, required this.amount});

  @override
  State<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends State<EsewaPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final String cleanAmount = widget.amount.toString();
    final String uuid = EsewaService.generateUuid();
    final String signature = EsewaService.generateSignature(
      totalAmount: cleanAmount,
      transactionUuid: uuid,
    );

    // Build the query parameters for eSewa v2 GET request
    // This bypasses the need for an HTML form
    final Uri paymentUri = Uri.parse("https://rc-epay.esewa.com.np/api/epay/main/v2/form").replace(
      queryParameters: {
        'amount': cleanAmount,
        'tax_amount': '0',
        'total_amount': cleanAmount,
        'transaction_uuid': uuid,
        'product_code': EsewaService.productCode,
        'product_service_charge': '0',
        'product_delivery_charge': '0',
        'success_url': 'https://developer.esewa.com.np/success',
        'failure_url': 'https://developer.esewa.com.np/failure',
        'signed_field_names': 'total_amount,transaction_uuid,product_code',
        'signature': signature,
      },
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint("Loading URL: $url");
            if (url.contains("success")) {
              Navigator.pop(context, true);
            } else if (url.contains("failure")) {
              Navigator.pop(context, false);
            }
          },
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) => debugPrint("WebView Error: ${error.description}"),
        ),
      )
      ..loadRequest(paymentUri); // Directly loading the URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eSewa Payment"),
        backgroundColor: const Color(0xFF4FBF26),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF4FBF26))),
        ],
      ),
    );
  }
}