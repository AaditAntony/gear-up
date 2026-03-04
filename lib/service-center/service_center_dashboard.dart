import 'package:flutter/material.dart';

import 'widgets/service_center_sidebar.dart';
import 'pages/center_home_page.dart';
import 'pages/add_services_page.dart';
import 'pages/my_bookings_page.dart';

class ServiceCenterDashboard extends StatefulWidget {
  const ServiceCenterDashboard({super.key});

  @override
  State<ServiceCenterDashboard> createState() => _ServiceCenterDashboardState();
}

class _ServiceCenterDashboardState extends State<ServiceCenterDashboard> {
  int selectedIndex = 0;

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const CenterHomePage();
      case 1:
        return const AddServicesPage();
      case 2:
        return const MyBookingsPage();
      default:
        return const CenterHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ServiceCenterSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }
}
