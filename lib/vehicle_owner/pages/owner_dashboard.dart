import 'package:flutter/material.dart';
import 'package:gear_up/vehicle_owner/pages/ai_recommendation_page.dart';
import 'package:gear_up/vehicle_owner/pages/browse_centers_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_bookings_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_vehicles_page.dart';
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

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: "AI",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Centers",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Bookings",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Vehicles",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}