import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/admin/pages/approve_admins_pages.dart';
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
    return Scaffold(body: Center(child: Text("overview"),),);
  case 1:
    return  ApproveAdminsPage();
  case 2:
    return  ApproveServiceCentersPage();
  case 3:
    return  ServiceCategoriesPage();
  case 4:
    return  ViewBookingsPage();
  default:
    return Scaffold(body: Center(child: Text("overview"),),);
}
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: selectedIndex,
            isSuperAdmin: isSuperAdmin,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }
}
