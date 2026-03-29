import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/vehicle_owner/pages/center_detail_page.dart';
import 'package:gear_up/vehicle_owner/pages/service_center_search_page.dart';

class BrowseCentersPage extends StatelessWidget {
  const BrowseCentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E293B),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceCenterSearchPage()),
          );
        },
        icon: const Icon(Icons.search_rounded, color: Colors.white),
        label: const Text("Search Centers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PAGE HEADER SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Service Centers",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Discover and book the best service centers near you",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// LIST VIEW
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('service_center_details')
                  .where('status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          "No service centers available.",
                          style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                var centers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                  itemCount: centers.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var doc = centers[index];
                    var data = doc.data() as Map<String, dynamic>;

                    double rating = (data['avgRating'] ?? 0).toDouble();
                    int totalRatings = (data['totalRatings'] ?? 0);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CenterDetailPage(
                                    centerId: doc.id,
                                    centerData: data,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// CENTER ICON
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
                                              data['companyName'] ?? "Service Center",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1E293B),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  rating.toStringAsFixed(1),
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "($totalRatings reviews)",
                                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  const SizedBox(height: 16),

                                  /// LOCATION
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF3B82F6)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "${data['location'] ?? ""}, ${data['district'] ?? ""}",
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

                                  const SizedBox(height: 12),

                                  /// DESCRIPTION
                                  if (data['description'] != null && data['description'] != "")
                                    Text(
                                      data['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 13,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
