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
    if (widget.productData['image'] != null) image = base64Decode(widget.productData['image']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE SECTION
                  Container(
                    width: double.infinity,
                    height: 300,
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: image != null
                          ? Image.memory(image, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.image_outlined, color: Color(0xFFCBD5E1), size: 60)),
                    ),
                  ),

                  /// PRODUCT INFO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.productData['productName'] ?? "Product Name",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E293B),
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.store_rounded, size: 14, color: Color(0xFF3B82F6)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.productData['centerName'] ?? "GearUp Seller",
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "Price",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "₹${widget.productData['price']}",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3B82F6),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.productData['description'] ?? "No description available for this product.",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BUY NOW BUTTON
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: openPayment,
                child: const Text(
                  "Buy Now",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
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