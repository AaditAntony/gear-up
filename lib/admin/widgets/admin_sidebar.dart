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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onItemSelected(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 1)
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slightly darker navy for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP LOGO / TITLE
          const SizedBox(height: 60),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded, // GEAR ICON
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "GEAR UP",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "ADMIN PORTAL",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: const Color(0xFF3B82F6).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          /// SECTION LABEL
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Text(
              "MANAGEMENT",
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),

          /// MENU ITEMS
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  buildMenuItem(icon: Icons.grid_view_rounded, title: "Statistics", index: 0),

                  if (isSuperAdmin)
                    buildMenuItem(
                      icon: Icons.verified_user_rounded,
                      title: "Approve Admins",
                      index: 1,
                    ),

                  buildMenuItem(
                    icon: Icons.pending_actions_rounded,
                    title: "Pending Centers",
                    index: 2,
                  ),

                  buildMenuItem(
                    icon: Icons.check_circle_rounded,
                    title: "Approved Centers",
                    index: 6,
                  ),

                  buildMenuItem(
                    icon: Icons.cancel_rounded,
                    title: "Rejected Centers",
                    index: 7,
                  ),

                  buildMenuItem(
                    icon: Icons.block_rounded,
                    title: "Blocked Centers",
                    index: 8,
                  ),

                  buildMenuItem(
                    icon: Icons.category_rounded,
                    title: "Service Categories",
                    index: 3,
                  ),

                  buildMenuItem(
                    icon: Icons.shopping_bag_rounded,
                    title: "Product Sales",
                    index: 4,
                  ),

                  buildMenuItem(
                    icon: Icons.calendar_month_rounded,
                    title: "All Bookings",
                    index: 5,
                  ),
                ],
              ),
            ),
          ),

          /// LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
              ),
              child: ListTile(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
