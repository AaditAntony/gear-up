import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/auth/login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  bool isSuperAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAdminType();
  }

  Future<void> checkAdminType() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      isSuperAdmin = userDoc['isSuperAdmin'] ?? false;
      isLoading = false;
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget getSelectedPage() {
    if (selectedIndex == 0) {
      return const Center(
        child: Text("Admin Dashboard Home", style: TextStyle(fontSize: 20)),
      );
    } else if (selectedIndex == 1) {
      return const Center(
        child: Text(
          "Service Categories Section",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else if (selectedIndex == 2) {
      return const Center(
        child: Text(
          "View All Bookings Section",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else if (selectedIndex == 3 && isSuperAdmin) {
      return const ApproveAdminsPage();
    } else if (selectedIndex == 4) {
      return const ApproveServiceCentersPage();
    }
    return const Center(child: Text("Section"));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Admin Panel",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                ListTile(
                  title: const Text("Dashboard"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),

                ListTile(
                  title: const Text("Service Categories"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),

                ListTile(
                  title: const Text("View Bookings"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),

                if (isSuperAdmin)
                  ListTile(
                    title: const Text("Approve Admins"),
                    onTap: () {
                      setState(() {
                        selectedIndex = 3;
                      });
                    },
                  ),
                ListTile(
                  title: const Text("Approve Service Centers"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 4;
                    });
                  },
                ),
                const Spacer(),

                ListTile(title: const Text("Logout"), onTap: logout),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: getSelectedPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class ApproveAdminsPage extends StatefulWidget {
  const ApproveAdminsPage({super.key});

  @override
  State<ApproveAdminsPage> createState() => _ApproveAdminsPageState();
}

class _ApproveAdminsPageState extends State<ApproveAdminsPage> {
  Future<void> approveAdmin(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isApproved': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin approved successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .where('isApproved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pending admin approvals."));
        }

        var admins = snapshot.data!.docs;

        return ListView.builder(
          itemCount: admins.length,
          itemBuilder: (context, index) {
            var admin = admins[index];
            String uid = admin.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(admin['name'] ?? ''),
                subtitle: Text(admin['email'] ?? ''),
                trailing: ElevatedButton(
                  onPressed: () => approveAdmin(uid),
                  child: const Text("Approve"),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ApproveServiceCentersPage extends StatelessWidget {
  const ApproveServiceCentersPage({super.key});

  Future<void> approveCenter(String uid) async {
    await FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .update({'status': 'approved'});

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isApproved': true,
    });
  }

  Future<void> rejectCenter(String uid) async {
    await FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .update({'status': 'rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_center_details')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No pending service center approvals."),
          );
        }

        var centers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: centers.length,
          itemBuilder: (context, index) {
            var center = centers[index];
            String uid = center.id;

            String phone = center['phone'] ?? '';
            String location = center['location'] ?? '';
            String description = center['description'] ?? '';
            String image1 = center['image1'];
            String image2 = center['image2'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone: $phone"),
                    Text("Location: $location"),
                    const SizedBox(height: 5),
                    Text("Description: $description"),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Image.memory(
                          base64Decode(image1),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 20),
                        Image.memory(
                          base64Decode(image2),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await approveCenter(uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Service Center Approved"),
                              ),
                            );
                          },
                          child: const Text("Approve"),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await rejectCenter(uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Service Center Rejected"),
                              ),
                            );
                          },
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
