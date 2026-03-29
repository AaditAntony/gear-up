import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/vehicle_owner/pages/booking_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CenterDetailPage extends StatelessWidget {
  final String centerId;
  final Map<String, dynamic> centerData;

  const CenterDetailPage({
    super.key,
    required this.centerId,
    required this.centerData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          centerData['companyName'] ?? "Service Center",
          style: const TextStyle(
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CENTER HEADER CARD
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Color(0xFF3B82F6),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              centerData['companyName'] ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "${centerData['location'] ?? ""}, ${centerData['district'] ?? ""}",
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 24),

                  /// DESCRIPTION
                  const Text(
                    "About This Center",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    centerData['description'] ?? "No description available.",
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  if (centerData['googleMapLink'] != null && centerData['googleMapLink'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(centerData['googleMapLink']);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open map link')),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6).withOpacity(0.05),
                          foregroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 20),
                        label: const Text(
                          "View on Google Maps",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// SERVICES SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Available Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// SERVICES LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('center_services')
                  .where('centerId', isEqualTo: centerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        "No services linked to this center yet.",
                        style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }

                var services = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    var service = services[index];
                    var sData = service.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.build_circle_rounded,
                              color: Color(0xFF64748B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sData['categoryName'] ?? "General Service",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₹ ${sData['price']}",
                                  style: const TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingPage(
                                    centerId: centerId,
                                    centerName: centerData['companyName'],
                                    categoryId: sData['categoryId'],
                                    categoryName: sData['categoryName'],
                                    price: (sData['price'] as num).toDouble(),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Book Now",
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
////