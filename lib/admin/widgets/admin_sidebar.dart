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

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: isSelected ? const Color(0xFF334155) : Colors.transparent,
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
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP LOGO / TITLE
          const SizedBox(height: 40),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Admin Panel",
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

          if (isSuperAdmin)
            buildMenuItem(
              icon: Icons.verified_user,
              title: "Approve Admins",
              index: 1,
            ),

          buildMenuItem(
            icon: Icons.approval,
            title: "Approve Centers",
            index: 2,
          ),

          buildMenuItem(
            icon: Icons.build,
            title: "Service Categories",
            index: 3,
          ),

          buildMenuItem(
            icon: Icons.shopping_cart,
            title: "Product Sales",
            index: 4,
          ),

          buildMenuItem(
            icon: Icons.calendar_month,
            title: "View Bookings",
            index: 5,
          ),

          const Spacer(),

          /// LOGOUT BUTTON
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
