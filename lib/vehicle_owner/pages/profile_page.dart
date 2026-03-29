import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/vehicle_owner/auth/owner_login_page.dart';
import 'package:gear_up/vehicle_owner/pages/my_oders_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<DocumentSnapshot> getUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OwnerLoginPage()),
      (route) => false,
    );
  }

  Widget infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Profile not found"));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Column(
          children: [
            /// 🔵 PREMIUM HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  /// AVATAR WITH RING
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFF1F5F9),
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: const Color(0xFF1E293B).withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// NAME
                  Text(
                    data['name'] ?? "Guest User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// EMAIL
                  Text(
                    data['email'] ?? "",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ✏️ EDIT PROFILE BUTTON
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                physics: const BouncingScrollPhysics(),
                children: [
                  /// SECTION TITLE
                  _sectionTitle("Personal Information"),

                  const SizedBox(height: 16),

                  infoTile(Icons.phone_rounded, "Phone Number", data['phone'] ?? "Not provided"),
                  infoTile(Icons.location_on_rounded, "Location", data['address'] ?? "Not provided"),
                  infoTile(Icons.map_rounded, "District", data['district'] ?? "Not provided"),

                  const SizedBox(height: 32),

                  /// SECTION TITLE
                  _sectionTitle("Account Settings"),

                  const SizedBox(height: 16),

                  /// ORDERS
                  _settingTile(
                    icon: Icons.shopping_bag_rounded,
                    title: "My Product Orders",
                    subtitle: "Track your gear purchases",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  /// LOGOUT
                  _settingTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    isDestructive: true,
                    onTap: () => logout(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    Color primaryColor = isDestructive ? Colors.redAccent : const Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: primaryColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: const Color(0xFFCBD5E1),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
////