import 'package:flutter/material.dart';

class InvoicePage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const InvoicePage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text("Invoice", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            /// ✅ SUCCESS ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),

            const SizedBox(height: 15),

            /// SUCCESS TEXT
            const Text(
              "Payment Successful",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 25),

            /// 🔥 INVOICE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

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
                  /// ORDER ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Order ID",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        orderId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Divider(height: 25),

                  /// PRODUCT DETAILS
                  const Text(
                    "Product Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  _row("Product", orderData['productName']),
                  _row("Seller", orderData['centerName']),

                  const SizedBox(height: 20),

                  /// PRICE SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${orderData['price']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// 🔥 DONE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),

                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 REUSABLE ROW
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
////