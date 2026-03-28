import 'package:flutter/material.dart';
import 'package:gear_up/service-center/pages/add_product_page.dart';
import 'package:gear_up/service-center/pages/center_profile_page.dart';
import 'package:gear_up/service-center/pages/sales_dashboard_page.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

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
        return "Dashboard Overview";
      case 1:
        return "Service Management";
      case 2:
        return "Live Bookings";
      case 3:
        return "Product Inventory";
      case 4:
        return "Performance Metrics";
      case 5:
        return "Center Profile";
      default:
        return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,

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
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        getPageTitle(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ServiceTheme.textPrimary,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: ServiceTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ServiceTheme.accent.withOpacity(0.1)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: ServiceTheme.accent,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Verified Center",
                              style: TextStyle(
                                color: ServiceTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9), // Slate 100
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 30,
                            color: Colors.black.withOpacity(0.04),
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
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