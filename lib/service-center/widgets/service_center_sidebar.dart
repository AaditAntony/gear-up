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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: isSelected ? const Color(0xFFEA580C) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
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
      color: const Color(0xFFF97316), // FULL ORANGE SIDEBAR
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          /// LOGO / HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings, // GEAR ICON
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GearUp",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Service Center",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// MENU
          buildMenuItem(icon: Icons.dashboard, title: "Dashboard", index: 0),

          buildMenuItem(icon: Icons.build, title: "Add Services", index: 1),

          buildMenuItem(
            icon: Icons.calendar_month,
            title: "My Bookings",
            index: 2,
          ),

          buildMenuItem(icon: Icons.inventory, title: "Add Products", index: 3),

          buildMenuItem(icon: Icons.bar_chart, title: "Sales Board", index: 4),

          buildMenuItem(icon: Icons.person, title: "Profile", index: 5),

          const Spacer(),

          /// LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
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

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
