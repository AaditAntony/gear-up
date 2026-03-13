import 'package:flutter/material.dart';
import 'package:gear_up/service-center/pages/add_product_page.dart';
import 'package:gear_up/service-center/pages/center_profile_page.dart';
import 'package:gear_up/service-center/pages/sales_dashboard_page.dart';

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
        return const ServiceHomePage();
      case 1:
        return const AddServicesPage();
      case 2:
        return const MyBookingsPage();
      case 3:
        return const AddProductPage();
      case 4:
        return const SalesDashboardPage();
      case 5:
        return const CenterProfilePage();
      default:
        return const ServiceHomePage();
    }
  }

  String getPageTitle() {
    switch (selectedIndex) {
      case 0:
        return "Dashboard";
      case 1:
        return "Add Services";
      case 2:
        return "My Bookings";
      case 3:
        return "Add Products";
      case 4:
        return "Sales Board";
      case 5:
        return "Profile";
      default:
        return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),

      body: Row(
        children: [
          /// SIDEBAR
          ServiceCenterSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          /// MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [

                /// TOP HEADER
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.settings,
                        color: Color(0xFFF97316),
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      Text(
                        getPageTitle(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.build,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Service Center",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                /// PAGE CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(.05),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: getSelectedPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}