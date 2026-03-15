import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CenterBookingDetailPage extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const CenterBookingDetailPage({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  State<CenterBookingDetailPage> createState() =>
      _CenterBookingDetailPageState();
}

class _CenterBookingDetailPageState extends State<CenterBookingDetailPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String status = "pending";

  Future<void> addUpdate() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({
          "serviceUpdates": FieldValue.arrayUnion([
            {
              "title": titleController.text.trim(),
              "description": descriptionController.text.trim(),
              "status": status,
              "createdAt": Timestamp.now(),
            },
          ]),
        });

    titleController.clear();
    descriptionController.clear();
  }

  Future<void> updateBookingStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({"status": newStatus});

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Booking status updated to $newStatus")),
    );

    if (newStatus == "completed") {
      Navigator.pop(context);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "completed":
        return Colors.green;
      case "in_progress":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFF97316)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$title: $value",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        title: const Text("Booking Details"),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List updates = data["serviceUpdates"] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// BOOKING INFORMATION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Booking Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      infoRow(Icons.build, "Service", data['categoryName']),
                      const SizedBox(height: 8),

                      infoRow(
                        Icons.directions_car,
                        "Vehicle",
                        data['vehicleNumber'],
                      ),

                      const SizedBox(height: 8),

                      infoRow(
                        Icons.report_problem,
                        "Complaint",
                        data['complaint'] ?? "None",
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.orange),
                          const SizedBox(width: 8),

                          const Text(
                            "Status:",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              color: getStatusColor(
                                data['status'],
                              ).withOpacity(.15),
                              borderRadius: BorderRadius.circular(6),
                            ),

                            child: Text(
                              data['status'].toUpperCase(),
                              style: TextStyle(
                                color: getStatusColor(data['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// SERVICE TIMELINE
                const Text(
                  "Service Progress",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Column(
                  children: List.generate(updates.length, (index) {
                    var update = updates[index];
                    Color statusColor = getStatusColor(update["status"]);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TIMELINE
                        Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),

                            if (index != updates.length - 1)
                              Container(
                                width: 2,
                                height: 60,
                                color: Colors.grey.shade300,
                              ),
                          ],
                        ),

                        const SizedBox(width: 15),

                        /// UPDATE CARD
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(color: Colors.grey.shade300),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  update["title"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(update["description"]),

                                const SizedBox(height: 6),

                                Text(
                                  update["status"].toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                const SizedBox(height: 25),

                /// ADD UPDATE
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add Service Update",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField(
                        value: status,
                        items: const [
                          DropdownMenuItem(
                            value: "pending",
                            child: Text("Pending"),
                          ),
                          DropdownMenuItem(
                            value: "in_progress",
                            child: Text("In Progress"),
                          ),
                          DropdownMenuItem(
                            value: "completed",
                            child: Text("Completed"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                          ),
                          onPressed: addUpdate,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Update"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ACTION BUTTONS
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () {
                        updateBookingStatus("in_progress");
                      },
                      child: const Text("Start Service"),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        updateBookingStatus("completed");
                      },
                      child: const Text("Mark Completed"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
