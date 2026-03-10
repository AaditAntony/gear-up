import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/login_page.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isSuperAdmin;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.isSuperAdmin,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey.shade200,
      child: Column(
        children: [
          const SizedBox(height: 40),

          const Text(
            "Admin Panel",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          // 0
          ListTile(
            selected: selectedIndex == 0,
            title: const Text("Dashboard"),
            onTap: () => onItemSelected(0),
          ),

          // 1 (Only Super Admin)
          if (isSuperAdmin)
            ListTile(
              selected: selectedIndex == 1,
              title: const Text("Approve Admins"),
              onTap: () => onItemSelected(1),
            ),

          // 2
          ListTile(
            selected: selectedIndex == 2,
            title: const Text("Approve Service Centers"),
            onTap: () => onItemSelected(2),
          ),

          // 3
          ListTile(
            selected: selectedIndex == 3,
            title: const Text("Service Categories"),
            onTap: () => onItemSelected(3),
          ),
          // 4
          ListTile(
            selected: selectedIndex == 4,
            title: const Text("Product Sale"),
            onTap: () => onItemSelected(4),
          ),

          // 4
          ListTile(
            selected: selectedIndex == 5,
            title: const Text("View Bookings"),
            onTap: () => onItemSelected(5),
          ),

          const Spacer(),

          ListTile(
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
