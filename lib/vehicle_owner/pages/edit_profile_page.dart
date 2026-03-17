import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String? selectedDistrict;

  bool isLoading = true;

  final List<String> districts = [
    "Thiruvananthapuram",
    "Kollam",
    "Pathanamthitta",
    "Alappuzha",
    "Kottayam",
    "Ernakulam",
    "Thrissur",
    "Palakkad",
    "Malappuram",
    "Kozhikode",
    "Wayanad",
    "Kannur",
    "Kasaragod",
  ];

  Future<void> loadProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      var data = doc.data()!;

      nameController.text = data['name'] ?? "";
      phoneController.text = data['phone'] ?? "";
      addressController.text = data['address'] ?? "";
      selectedDistrict = data['district'];
    }

    setState(() => isLoading = false);
  }

  Future<void> updateProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "district": selectedDistrict,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// HEADER ICON
            const CircleAvatar(
              radius: 35,
              backgroundColor: Color(0xFF2563EB),
              child: Icon(Icons.edit, color: Colors.white, size: 30),
            ),

            const SizedBox(height: 20),

            /// FORM CARD
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(.05),
                  ),
                ],
              ),

              child: Column(
                children: [
                  _buildField(nameController, "Name"),
                  _buildField(phoneController, "Phone"),
                  _buildField(addressController, "Address"),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    decoration: _inputDecoration("District"),
                    items: districts.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedDistrict = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 45,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: updateProfile,
                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
//// done