import 'package:flutter/material.dart';
import 'package:gear_up/vehicle_owner/pages/ai_recommendation_page.dart';
import 'package:gear_up/vehicle_owner/pages/browse_centers_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_bookings_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_vehicles_page.dart';
import 'package:gear_up/vehicle_owner/pages/product_page.dart';
import 'package:gear_up/vehicle_owner/pages/profile_page.dart';
import 'package:gear_up/services/notification_service.dart';
import 'package:gear_up/vehicle_owner/pages/notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AIRecommendationPage(),
    BrowseCentersPage(),
    MyBookingsPage(),
    MyVehiclesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "GearUp",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<int>(
            stream: NotificationService.getUnreadCount(
              FirebaseAuth.instance.currentUser!.uid,
            ),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: const Color(0xFF64748B),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NotificationsPage()),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            unreadCount > 9 ? "9+" : "$unreadCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              color: const Color(0xFF64748B),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductsPage()),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),

      /// BODY (Responsive Centered)
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: pages[selectedIndex],
        ),
      ),

      /// BOTTOM NAVIGATION (Premium Look)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => setState(() => selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF3B82F6),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome),
                  label: "AI Support",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: "Centers",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: "Bookings",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car_outlined),
                  activeIcon: Icon(Icons.directions_car),
                  label: "Vehicles",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//