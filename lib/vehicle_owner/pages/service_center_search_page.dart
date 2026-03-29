import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/vehicle_owner/pages/center_detail_page.dart';

class ServiceCenterSearchPage extends StatefulWidget {
  const ServiceCenterSearchPage({super.key});

  @override
  State<ServiceCenterSearchPage> createState() => _ServiceCenterSearchPageState();
}

class _ServiceCenterSearchPageState extends State<ServiceCenterSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2563EB), size: 18),
        ),
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
            decoration: InputDecoration(
              hintText: "Search for centers...",
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_center_details')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState("No service centers available.");
          }

          var centers = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var companyName = (data['companyName'] ?? "").toString().toLowerCase();
            return companyName.contains(_searchQuery.toLowerCase());
          }).toList();

          if (centers.isEmpty) {
            return _emptyState("No results found for \"$_searchQuery\"");
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            itemCount: centers.length,
            itemBuilder: (context, index) {
              var doc = centers[index];
              var data = doc.data() as Map<String, dynamic>;
              double rating = (data['avgRating'] ?? 0).toDouble();
              int reviews = (data['totalRatings'] ?? 0);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CenterDetailPage(centerId: doc.id, centerData: data),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.business_rounded, color: Color(0xFF2563EB), size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['companyName'] ?? "Service Center",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "($reviews reviews)",
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${data['location'] ?? ""}, ${data['district'] ?? ""}",
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (data['description'] != null && data['description'].toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            data['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
              )
            ]),
            child: const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
