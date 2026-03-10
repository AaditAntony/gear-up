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
      appBar: AppBar(
        title: const Text("Invoice"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Payment Successful",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            Text("Order ID: $orderId"),

            const SizedBox(height: 20),

            const Text(
              "Product Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Product: ${orderData['productName']}"),

            Text("Sold By: ${orderData['centerName']}"),

            Text("Price: ₹${orderData['price']}"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Done"),
                onPressed: () {

                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );

                },
              ),
            )
          ],
        ),
      ),
    );
  }
}