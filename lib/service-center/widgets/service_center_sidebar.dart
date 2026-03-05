import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/login_page.dart';

class ServiceCenterSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ServiceCenterSidebar({
    super.key,
    required this.selectedIndex,
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
            "Service Center",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          ListTile(
            selected: selectedIndex == 0,
            title: const Text("Dashboard"),
            onTap: () => onItemSelected(0),
          ),

          ListTile(
            selected: selectedIndex == 1,
            title: const Text("Add Services"),
            onTap: () => onItemSelected(1),
          ),

          ListTile(
            selected: selectedIndex == 2,
            title: const Text("My Bookings"),
            onTap: () => onItemSelected(2),
          ),
          ListTile(
            selected: selectedIndex == 3,
            title: const Text("Profile"),
            onTap: () => onItemSelected(3),
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
