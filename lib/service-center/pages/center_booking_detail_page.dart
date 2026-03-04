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

class _CenterBookingDetailPageState
    extends State<CenterBookingDetailPage> {

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String status = "pending";

  Future<void> addUpdate() async {

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all fields"),
        ),
      );
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
        }
      ])
    });

    titleController.clear();
    descriptionController.clear();
  }

  Future<void> updateBookingStatus(String newStatus) async {

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({
      "status": newStatus
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data!.data()
              as Map<String, dynamic>;

          List updates = data["serviceUpdates"] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Service: ${data['categoryName']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text("Vehicle: ${data['vehicleNumber']}"),

                Text("Complaint: ${data['complaint']}"),

                const SizedBox(height: 10),

                Text(
                  "Booking Status: ${data['status']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Service Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: updates.length,
                    itemBuilder: (context, index) {

                      var update = updates[index];

                      return Card(
                        child: ListTile(
                          title: Text(update["title"]),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(update["description"]),
                              Text(
                                "Status: ${update["status"]}",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                const Text(
                  "Add Service Update",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: addUpdate,
                  child: const Text("Add Update"),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    ElevatedButton(
                      onPressed: () {
                        updateBookingStatus("in_progress");
                      },
                      child: const Text("Start Service"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: () {
                        updateBookingStatus("completed");
                      },
                      child: const Text("Mark Completed"),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}