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

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[300],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () => onItemSelected(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1F2937),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          const SizedBox(height: 40),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.build_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Service Center",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// MENU ITEMS
          buildMenuItem(icon: Icons.dashboard, title: "Dashboard", index: 0),

          buildMenuItem(icon: Icons.build, title: "Add Services", index: 1),

          buildMenuItem(
            icon: Icons.calendar_month,
            title: "My Bookings",
            index: 2,
          ),

          buildMenuItem(
            icon: Icons.inventory_2,
            title: "Add Products",
            index: 3,
          ),

          buildMenuItem(icon: Icons.bar_chart, title: "Sales Board", index: 4),

          buildMenuItem(icon: Icons.person, title: "Profile", index: 5),

          const Spacer(),

          /// LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
