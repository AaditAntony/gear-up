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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF334155) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ).copyWith(
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
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
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP LOGO / TITLE
          const SizedBox(height: 50),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "GEAR UP",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// SECTION LABEL
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Text(
              "MAIN MENU",
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),

          /// MENU ITEMS
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildMenuItem(icon: Icons.dashboard_outlined, title: "Dashboard", index: 0),

                  if (isSuperAdmin)
                    buildMenuItem(
                      icon: Icons.verified_user_outlined,
                      title: "Approve Admins",
                      index: 1,
                    ),

                  buildMenuItem(
                    icon: Icons.approval_outlined,
                    title: "Approve Centers",
                    index: 2,
                  ),

                  buildMenuItem(
                    icon: Icons.check_circle_outline,
                    title: "Approved Centers",
                    index: 6,
                  ),

                  buildMenuItem(
                    icon: Icons.highlight_off,
                    title: "Rejected Centers",
                    index: 7,
                  ),

                  buildMenuItem(
                    icon: Icons.block_outlined,
                    title: "Blocked Centers",
                    index: 8,
                  ),

                  buildMenuItem(
                    icon: Icons.build_circle_outlined,
                    title: "Service Categories",
                    index: 3,
                  ),

                  buildMenuItem(
                    icon: Icons.shopping_cart_outlined,
                    title: "Product Sales",
                    index: 4,
                  ),

                  buildMenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: "View Bookings",
                    index: 5,
                  ),
                ],
              ),
            ),
          ),

          /// LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  "Logout Session",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
