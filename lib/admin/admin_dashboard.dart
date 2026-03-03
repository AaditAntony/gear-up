import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/admin_sidebar.dart';
import 'pages/admin_home_page.dart';
import 'pages/approve_admins_page.dart';
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
      default:
        return const AdminHomePage();
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
