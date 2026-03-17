import 'package:flutter/material.dart';
import 'package:gear_up/vehicle_owner/pages/ai_recommendation_page.dart';
import 'package:gear_up/vehicle_owner/pages/browse_centers_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_bookings_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_vehicles_page.dart';
import 'package:gear_up/vehicle_owner/pages/product_page.dart';
import 'package:gear_up/vehicle_owner/pages/profile_page.dart';

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
      backgroundColor: const Color(0xFFEFF6FF),

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2563EB),

        title: const Text(
          "GearUp",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Colors.white,
            tooltip: "Products",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductsPage()),
              );
            },
          ),
        ],

        /// subtle divider (pro look)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.2)),
        ),
      ),

      /// BODY
      body: pages[selectedIndex],

      /// BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,

          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.grey,

          selectedFontSize: 12,
          unselectedFontSize: 11,

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AI"),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Centers"),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: "Vehicles",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
//