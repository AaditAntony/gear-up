import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/admin/admin_login_page.dart';


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

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    setState(() {
      isSuperAdmin = userDoc['isSuperAdmin'] ?? false;
      isLoading = false;
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget getSelectedPage() {
    if (selectedIndex == 0) {
      return const Center(child: Text("Admin Dashboard Home"));
    } else if (selectedIndex == 1) {
      return const Center(child: Text("Service Categories Section"));
    } else if (selectedIndex == 2) {
      return const Center(child: Text("View All Bookings Section"));
    } else if (selectedIndex == 3 && isSuperAdmin) {
      return const Center(child: Text("Approve Admins Section"));
    }
    return const Center(child: Text("Section"));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [

          // Sidebar
          Container(
            width: 250,
            color: Colors.grey.shade200,
            child: Column(
              children: [

                const SizedBox(height: 40),
                const Text(
                  "Admin Panel",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                ListTile(
                  title: const Text("Dashboard"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),

                ListTile(
                  title: const Text("Service Categories"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),

                ListTile(
                  title: const Text("View Bookings"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),

                if (isSuperAdmin)
                  ListTile(
                    title: const Text("Approve Admins"),
                    onTap: () {
                      setState(() {
                        selectedIndex = 3;
                      });
                    },
                  ),

                const Spacer(),

                ListTile(
                  title: const Text("Logout"),
                  onTap: logout,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }
}