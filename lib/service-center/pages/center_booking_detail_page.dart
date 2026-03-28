import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

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
        return ServiceTheme.success;
      case "in_progress":
        return ServiceTheme.warning;
      default:
        return ServiceTheme.textSecondary;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "completed":
        return Icons.verified_rounded;
      case "in_progress":
        return Icons.auto_fix_high_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Widget statusBadge(String status) {
    Color color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Service Management", style: TextStyle(color: ServiceTheme.textPrimary, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: ServiceTheme.textPrimary),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ACTION BUTTONS TOP
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ServiceTheme.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => updateBookingStatus("in_progress"),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: const Text("START SERVICE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ServiceTheme.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => updateBookingStatus("completed"),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text("MARK DONE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// BOOKING INFO
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: ServiceTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("WORK ORDER DETAILS", style: ServiceTheme.label),
                      const SizedBox(height: 20),
                      
                      _detailRow(Icons.category_rounded, "Service Category", data['categoryName']),
                      const Divider(height: 32),
                      _detailRow(Icons.directions_car_rounded, "Vehicle Primary", data['vehicleNumber']),
                      const Divider(height: 32),
                      _detailRow(Icons.report_gmailerrorred_rounded, "Owner Complaint", data['complaint'] ?? "General inspection requested"),
                      
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ServiceTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("CURRENT ORDER STATUS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ServiceTheme.textSecondary)),
                            statusBadge(data['status']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// SERVICE TIMELINE
                const Text("ACTIVITY LOG & TIMELINE", style: ServiceTheme.label),
                const SizedBox(height: 20),

                Column(
                  children: List.generate(updates.length, (index) {
                    var update = updates[index];
                    Color statusColor = getStatusColor(update["status"]);
                    IconData icon = getStatusIcon(update["status"]);

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TIMELINE
                          Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: statusColor, size: 18),
                              ),
                              if (index != updates.length - 1)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: ServiceTheme.border.withOpacity(0.5),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 20),

                          /// UPDATE CONTENT
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        update["title"],
                                        style: const TextStyle(fontWeight: FontWeight.w900, color: ServiceTheme.textPrimary, fontSize: 16),
                                      ),
                                      statusBadge(update["status"]),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    update["description"],
                                    style: const TextStyle(color: ServiceTheme.textSecondary, height: 1.5, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                if (updates.isEmpty)
                   Center(
                     child: Padding(
                       padding: const EdgeInsets.all(32),
                       child: Column(
                         children: [
                           Icon(Icons.history_rounded, size: 48, color: ServiceTheme.border.withOpacity(0.5)),
                           const SizedBox(height: 12),
                           const Text("No progress log entries yet.", style: ServiceTheme.body),
                         ],
                       ),
                     ),
                   ),

                const SizedBox(height: 40),

                /// ADD UPDATE FORM
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: ServiceTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("LOG NEW ACTIVITY", style: ServiceTheme.label),
                      const SizedBox(height: 24),

                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Update Title (e.g. Parts Disassembled)",
                          filled: true,
                          fillColor: ServiceTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Technical details or inspection findings...",
                          filled: true,
                          fillColor: ServiceTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: status,
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ServiceTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: const [
                          DropdownMenuItem(value: "pending", child: Text("Status: Pending Task", style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: "in_progress", child: Text("Status: Work in Progress", style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: "completed", child: Text("Status: Phase Completed", style: TextStyle(fontSize: 14))),
                        ],
                        onChanged: (value) => setState(() => status = value!),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ServiceTheme.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: addUpdate,
                          icon: const Icon(Icons.add_task_rounded),
                          label: const Text("PUBLISH LOG ENTRY", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ServiceTheme.accent.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: ServiceTheme.accent, size: 20),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: ServiceTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: ServiceTheme.textPrimary, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
