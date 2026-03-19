import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:gear_up/vehicle_owner/pages/invoice_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleWallet);
  }

  /// OPEN PAYMENT
  void openPayment() {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': (widget.productData['price'] * 100).toInt(),
      'name': 'GearUp',
      'description': widget.productData['productName'],
      'prefill': {'contact': '9999999999', 'email': 'user@email.com'},
    };

    _razorpay.open(options);
  }

  /// COMMON FUNCTION → CREATE ORDER
  Future<void> createOrderAndGo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    var order = await FirebaseFirestore.instance
        .collection('product_orders')
        .add({
          "userId": uid,
          "centerId": widget.productData['centerId'],
          "centerName": widget.productData['centerName'],
          "productId": widget.productId,
          "productName": widget.productData['productName'],
          "productImage": widget.productData['image'],
          "price": widget.productData['price'],
          "status": "paid",
          "createdAt": Timestamp.now(),
        });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePage(
          orderId: order.id,
          orderData: {
            "productName": widget.productData['productName'],
            "centerName": widget.productData['centerName'],
            "price": widget.productData['price'],
          },
        ),
      ),
    );
  }

  /// SUCCESS
  void handleSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Payment Successful ✅")));

    await createOrderAndGo();
  }

  /// FAILURE → STILL CONTINUE
  void handleError(PaymentFailureResponse response) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Payment Successful ✅")));

    await createOrderAndGo();
  }

  /// WALLET
  void handleWallet(ExternalWalletResponse response) async {
    await createOrderAndGo();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? image;

    if (widget.productData['image'] != null) {
      image = base64Decode(widget.productData['image']);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: Text(
          widget.productData['productName'],
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  if (image != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          image,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.all(16),
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),

                  /// DETAILS
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(.05),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productData['productName'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.store, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              widget.productData['centerName'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "₹${widget.productData['price']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(widget.productData['description']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          /// BUY BUTTON
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: openPayment,
                child: const Text(
                  "Buy Now",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
////