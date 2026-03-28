import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

class EditCenterProfilePage extends StatefulWidget {
  const EditCenterProfilePage({super.key});

  @override
  State<EditCenterProfilePage> createState() => _EditCenterProfilePageState();
}

class _EditCenterProfilePageState extends State<EditCenterProfilePage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();
  final TextEditingController googleMapLinkController = TextEditingController();

  String? selectedDistrict;
  bool isLoading = true;
  bool isSaving = false;

  Uint8List? imageBytes;
  String? imageBase64;

  final List<String> districts = [
    "Thiruvananthapuram", "Kollam", "Pathanamthitta", "Alappuzha", "Kottayam",
    "Ernakulam", "Thrissur", "Palakkad", "Malappuram", "Kozhikode",
    "Wayanad", "Kannur", "Kasaragod",
  ];

  Future<void> loadProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .get();

    if (doc.exists) {
      var data = doc.data()!;

      phoneController.text = data['phone'] ?? "";
      locationController.text = data['location'] ?? "";
      googleMapLinkController.text = data['googleMapLink'] ?? "";
      descriptionController.text = data['description'] ?? "";
      workingHoursController.text = data['workingHours'] ?? "";

      selectedDistrict = data['district'];

      if (data['image'] != null) {
        imageBase64 = data['image'];
        imageBytes = base64Decode(data['image']);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    Uint8List bytes = await file.readAsBytes();

    setState(() {
      imageBytes = bytes;
      imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> updateProfile() async {
    setState(() => isSaving = true);
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .update({
            "phone": phoneController.text.trim(),
            "location": locationController.text.trim(),
            "googleMapLink": googleMapLinkController.text.trim(),
            "description": descriptionController.text.trim(),
            "workingHours": workingHoursController.text.trim(),
            "district": selectedDistrict,
            "image": imageBase64,
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: ServiceTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ServiceTheme.background,
      appBar: AppBar(
        title: const Text("Edit Center Profile", style: TextStyle(color: ServiceTheme.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ServiceTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: ServiceTheme.cardDecoration,
                child: Column(
                  children: [
                    /// PROFILE IMAGE
                    Center(
                      child: Column(
                        children: [
                           const Text("OFFICIAL WORKSHOP AVATAR", style: ServiceTheme.label),
                           const SizedBox(height: 16),
                           InkWell(
                             onTap: pickImage,
                             borderRadius: BorderRadius.circular(60),
                             child: Stack(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(4),
                                   decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ServiceTheme.accent.withOpacity(0.2), width: 3)),
                                   child: CircleAvatar(
                                     radius: 50,
                                     backgroundColor: ServiceTheme.background,
                                     backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
                                     child: imageBytes == null ? const Icon(Icons.storefront_rounded, size: 40, color: ServiceTheme.textSecondary) : null,
                                   ),
                                 ),
                                 Positioned(
                                   bottom: 0,
                                   right: 0,
                                   child: Container(
                                     padding: const EdgeInsets.all(8),
                                     decoration: const BoxDecoration(color: ServiceTheme.accent, shape: BoxShape.circle),
                                     child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// FORM FIELDS
                    _buildLabel("CONTACT NUMBER"),
                    _buildTextField(phoneController, Icons.phone_rounded, "Enter public phone number"),
                    
                    const SizedBox(height: 24),
                    _buildLabel("PHYSICAL LOCATION"),
                    _buildTextField(locationController, Icons.location_on_rounded, "Detailed workshop address"),
                    
                    const SizedBox(height: 24),
                    _buildLabel("OPERATIONAL DISTRICT"),
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map_rounded, size: 20, color: ServiceTheme.accent),
                        filled: true,
                        fillColor: ServiceTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: districts.map((district) {
                        return DropdownMenuItem(value: district, child: Text(district, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedDistrict = value),
                    ),

                    const SizedBox(height: 24),
                    _buildLabel("DIGITAL FOOTPRINT (GOOGLE MAPS)"),
                    _buildTextField(googleMapLinkController, Icons.add_location_alt_rounded, "Paste share link from Google Maps"),

                    const SizedBox(height: 24),
                    _buildLabel("BUSINESS HOURS"),
                    _buildTextField(workingHoursController, Icons.access_time_filled_rounded, "e.g. 09:00 AM - 07:00 PM"),

                    const SizedBox(height: 24),
                    _buildLabel("BUSINESS DESCRIPTION"),
                    _buildTextField(descriptionController, Icons.description_rounded, "Tell customers about your expertise...", maxLines: 3),

                    const SizedBox(height: 48),

                    /// UPDATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ServiceTheme.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSaving ? null : updateProfile,
                        icon: isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          isSaving ? "Saving..." : "Apply All Changes",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: ServiceTheme.label),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: ServiceTheme.accent),
        filled: true,
        fillColor: ServiceTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
