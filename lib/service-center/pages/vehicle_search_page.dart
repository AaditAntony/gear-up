import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import 'center_booking_detail_page.dart';

class VehicleSearchPage extends StatefulWidget {
  const VehicleSearchPage({super.key});

  @override
  State<VehicleSearchPage> createState() => _VehicleSearchPageState();
}

class _VehicleSearchPageState extends State<VehicleSearchPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  late Stream<QuerySnapshot> _bookingsStream;

  @override
  void initState() {
    super.initState();
    String centerId = FirebaseAuth.instance.currentUser!.uid;
    _bookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('centerId', isEqualTo: centerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vehicle Lookup & Service History",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: ServiceTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Search for a vehicle by its registration number to see all past records at your center.",
          style: TextStyle(color: ServiceTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 32),

        /// SEARCH BAR
        Container(
          decoration: BoxDecoration(
            color: ServiceTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                searchQuery = val.trim().toUpperCase();
              });
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.search_rounded, color: ServiceTheme.accent),
              hintText: "Enter Vehicle Number (e.g. KL 01 AB 1234)",
              hintStyle: TextStyle(
                color: ServiceTheme.textSecondary,
                fontSize: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 40),

        /// RESULTS
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _bookingsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // This will print the specific Firestore index link to the debug console
                print("FIRESTORE ERROR: ${snapshot.error}");

                return _buildEmptyState(
                  "Error loading records: ${snapshot.error}",
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(
                  "No service records found for this center.",
                );
              }

              var allBookings = snapshot.data!.docs.toList();

              // Sort manually to avoid indexing issues
              allBookings.sort((a, b) {
                var tA = a.data() as Map<String, dynamic>;
                var tB = b.data() as Map<String, dynamic>;
                Timestamp timeA = tA['createdAt'] ?? Timestamp.now();
                Timestamp timeB = tB['createdAt'] ?? Timestamp.now();
                return timeB.compareTo(timeA);
              });

              // Filter logic
              var filteredBookings = allBookings.where((doc) {
                if (searchQuery.isEmpty) return false;

                var data = doc.data() as Map<String, dynamic>;
                String vNum = (data['vehicleNumber'] ?? "")
                    .toString()
                    .replaceAll(" ", "")
                    .toUpperCase();
                String query = searchQuery.replaceAll(" ", "").toUpperCase();

                return vNum.contains(query);
              }).toList();

              if (searchQuery.isEmpty) {
                return _buildEmptyState(
                  "Start typing to search for a vehicle's history.\n(${allBookings.length} total records found for this center)",
                );
              }

              if (filteredBookings.isEmpty) {
                return _buildEmptyState(
                  "No history found matching '$searchQuery'.\n(Searching through ${allBookings.length} total records for your center)",
                );
              }

              return ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  var booking = filteredBookings[index];
                  var data = booking.data() as Map<String, dynamic>;
                  DateTime date = (data['createdAt'] as Timestamp).toDate();

                  return _buildHistoryCard(booking.id, data, date);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: ServiceTheme.border.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ServiceTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    String id,
    Map<String, dynamic> data,
    DateTime date,
  ) {
    String status = data['status'] ?? "unknown";
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CenterBookingDetailPage(bookingId: id, bookingData: data),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ServiceTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.car_repair_rounded,
            color: ServiceTheme.accent,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                data['categoryName'] ?? "General Service",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: ServiceTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(
                    color: ServiceTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 14,
                  color: ServiceTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  "${data['price']}",
                  style: const TextStyle(
                    color: ServiceTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (data['complaint'] != null) ...[
              const SizedBox(height: 8),
              Text(
                "Complaint: ${data['complaint']}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ServiceTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: ServiceTheme.textSecondary,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return ServiceTheme.success;
      case "in_progress":
        return ServiceTheme.warning;
      case "accepted":
        return ServiceTheme.info;
      case "rejected":
        return ServiceTheme.error;
      default:
        return ServiceTheme.textSecondary;
    }
  }
}
