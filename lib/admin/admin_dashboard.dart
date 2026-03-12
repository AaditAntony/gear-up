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
      backgroundColor: const Color(0xFFF1F5F9),
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
                /// TOP HEADER BAR
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Admin Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            isSuperAdmin ? "Super Admin" : "Admin",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(width: 20),

                          IconButton(
                            icon: const Icon(Icons.logout),
                            color: Colors.white,
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: getSelectedPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
