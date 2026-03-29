import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.more_horiz_rounded, color: const Color(0xFF94A3B8).withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('service_center_details').snapshots(),
        builder: (context, centerSnapshot) {
          if (!centerSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var centers = centerSnapshot.data!.docs;
          int totalCenters = centers.length;
          int pendingCenters = centers.where((c) => c['status'] == "pending").length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
            builder: (context, bookingSnapshot) {
              if (!bookingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var bookings = bookingSnapshot.data!.docs;
              int totalBookings = bookings.length;
              int completedBookings = bookings.where((b) => b['status'] == "completed").length;

              return Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PAGE HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dashboard Overview",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Platform status and core metrics at a glance.",
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF1E293B).withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                            ],
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hub_rounded, size: 18, color: Color(0xFF3B82F6)),
                              const SizedBox(width: 12),
                              const Text(
                                "Live Updates",
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    /// STATS GRID
                    Row(
                      children: [
                        statCard(
                          "Service Centers",
                          totalCenters,
                          Icons.business_center_rounded,
                          const Color(0xFF1E293B),
                        ),
                        const SizedBox(width: 24),
                        statCard(
                          "Pending Approvals",
                          pendingCenters,
                          Icons.security_rounded,
                          const Color(0xFF3B82F6),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        statCard(
                          "Total Bookings",
                          totalBookings,
                          Icons.analytics_rounded,
                          const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 24),
                        statCard(
                          "Completed Services",
                          completedBookings,
                          Icons.task_alt_rounded,
                          const Color(0xFF10B981),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    /// QUICK ACTIONS
                    const Text(
                      "Executive Actions",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 2.2,
                      children: [
                        _quickActionCard(
                          context,
                          "Approval Pipeline",
                          Icons.how_to_reg_rounded,
                          const Color(0xFF3B82F6),
                        ),
                        _quickActionCard(
                          context,
                          "Service Domains",
                          Icons.category_rounded,
                          const Color(0xFF8B5CF6),
                        ),
                        _quickActionCard(
                          context,
                          "Revenue Stream",
                          Icons.payments_rounded,
                          const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _quickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
