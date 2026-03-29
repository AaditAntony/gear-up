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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON CONTAINER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(width: 20),

            /// TEXT SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
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
        stream: FirebaseFirestore.instance
            .collection('service_center_details')
            .snapshots(),
        builder: (context, centerSnapshot) {
          if (!centerSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var centers = centerSnapshot.data!.docs;
          int totalCenters = centers.length;
          int pendingCenters = centers
              .where((c) => c['status'] == "pending")
              .length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .snapshots(),
            builder: (context, bookingSnapshot) {
              if (!bookingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var bookings = bookingSnapshot.data!.docs;
              int totalBookings = bookings.length;
              int completedBookings = bookings
                  .where((b) => b['status'] == "completed")
                  .length;

              return Padding(
                padding: const EdgeInsets.all(32),
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
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Welcome back! Here's what's happening today.",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Color(0xFF3B82F6),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Latest Stats",
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    /// STATS GRID
                    Row(
                      children: [
                        statCard(
                          "Service Centers",
                          totalCenters,
                          Icons.business_rounded,
                          const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 24),
                        statCard(
                          "Pending Approval",
                          pendingCenters,
                          Icons.hourglass_empty_rounded,
                          const Color(0xFFF59E0B),
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
                          Icons.check_circle_outline_rounded,
                          const Color(0xFF10B981),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    /// RECENT ACTIVITY PLACEHOLDER OR MORE SECTIONS
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 2.5,
                      children: [
                        _quickActionCard(
                          context,
                          "Approve Centers",
                          Icons.how_to_reg_rounded,
                          const Color(0xFF3B82F6),
                        ),
                        _quickActionCard(
                          context,
                          "Manage Categories",
                          Icons.category_rounded,
                          const Color(0xFF8B5CF6),
                        ),
                        _quickActionCard(
                          context,
                          "View Sales",
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Logic would go here to navigate, but keeping logic minimal
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
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
