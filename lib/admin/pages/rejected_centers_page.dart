import 'package:flutter/material.dart';
import '../widgets/base_center_list_page.dart';

class RejectedCentersPage extends StatelessWidget {
  const RejectedCentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseCenterListPage(
      title: "Rejected Centers",
      subtitle: "List of service center applications that were rejected",
      status: "rejected",
      showSearch: false,
    );
  }
}
