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

          ListTile(
            title: const Text("Dashboard"),
            onTap: () => onItemSelected(0),
          ),

          if (isSuperAdmin)
            ListTile(
              title: const Text("Approve Admins"),
              onTap: () => onItemSelected(1),
            ),

          ListTile(
            title: const Text("Approve Service Centers"),
            onTap: () => onItemSelected(2),
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