import 'package:flutter/material.dart';
import '../widgets/base_center_list_page.dart';

class ApprovedCentersPage extends StatelessWidget {
  const ApprovedCentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseCenterListPage(
      title: "Approved Centers",
      subtitle: "List of all approved service centers on the platform",
      status: "approved",
      showSearch: true,
    );
  }
}
