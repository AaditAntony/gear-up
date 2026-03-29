import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/admin/pages/admin_home_page.dart';
import 'package:gear_up/admin/pages/approve_admins_pages.dart';
import 'package:gear_up/admin/pages/product_sales_page.dart';
import 'package:gear_up/admin/pages/service_categories_page.dart';
import 'package:gear_up/admin/pages/view_bookings_page.dart';

import 'widgets/admin_sidebar.dart';
import 'pages/approve_service_centers_page.dart';
import 'pages/approved_centers_page.dart';
import 'pages/rejected_centers_page.dart';
import 'pages/blocked_centers_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  bool isSuperAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAdminType();
  }

  Future<void> checkAdminType() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      isSuperAdmin = userDoc['isSuperAdmin'] ?? false;
      isLoading = false;
    });
  }

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const AdminHomePage();
      case 1:
        return const ApproveAdminsPage();
      case 2:
        return const ApproveServiceCentersPage();
      case 3:
        return const ServiceCategoriesPage();
      case 4:
        return const ProductSalesPage();
      case 5:
        return const ViewBookingsPage();
      case 6:
        return const ApprovedCentersPage();
      case 7:
        return const RejectedCentersPage();
      case 8:
        return const BlockedCentersPage();
      default:
        return const Scaffold(body: AdminHomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          /// SIDEBAR
          AdminSidebar(
            selectedIndex: selectedIndex,
            isSuperAdmin: isSuperAdmin,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          /// MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                /// TOP HEADER BAR (Modernized)
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.settings_suggest_rounded,
                              color: Color(0xFF1E293B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Control Center",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          /// ADMIN BADGE
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E293B).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isSuperAdmin ? "SUPER ADMIN" : "ADMINISTRATOR",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          /// LOGOUT BUTTON
                          IconButton(
                            icon: const Icon(Icons.power_settings_new_rounded),
                            color: Colors.redAccent,
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// PAGE CONTENT
                Expanded(
                  child: getSelectedPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
