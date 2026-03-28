import 'package:flutter/material.dart';
import '../widgets/base_center_list_page.dart';

class BlockedCentersPage extends StatelessWidget {
  const BlockedCentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseCenterListPage(
      title: "Blocked Centers",
      subtitle: "List of service centers that are currently blocked from the platform",
      status: "blocked",
      showSearch: false,
    );
  }
}
