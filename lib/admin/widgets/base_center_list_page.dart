import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/view_service_center_detail_page.dart';

class BaseCenterListPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool showSearch;

  const BaseCenterListPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.showSearch = false,
  });

  @override
  State<BaseCenterListPage> createState() => _BaseCenterListPageState();
}

class _BaseCenterListPageState extends State<BaseCenterListPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt_rounded, color: Color(0xFF3B82F6)),
              ),
            ],
          ),

          const SizedBox(height: 32),

          /// SEARCH BAR
          if (widget.showSearch)
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search company name...",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 22),
                ),
              ),
            ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('service_center_details')
                  .where('status', isEqualTo: widget.status)
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
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "No ${widget.status} centers found.",
                          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                var centers = snapshot.data!.docs;

                /// CLIENT-SIDE SEARCH FILTERING
                if (searchQuery.isNotEmpty) {
                  centers = centers.where((doc) {
                    String name = (doc['companyName'] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery.toLowerCase());
                  }).toList();
                }

                if (centers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching centers found.",
                      style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: centers.length,
                  itemBuilder: (context, index) {
                    var center = centers[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewServiceCenterDetailPage(
                                    centerId: center.id,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  /// ICON/IMAGE PLACEHOLDER
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.business_rounded,
                                      color: Color(0xFF3B82F6),
                                      size: 32,
                                    ),
                                  ),

                                  const SizedBox(width: 24),

                                  /// CENTER INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          center['companyName'] ?? "N/A",
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_rounded,
                                              size: 16,
                                              color: Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${center['district'] ?? ""}, ${center['state'] ?? ""}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// VIEW BUTTON
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "View Details",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
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
