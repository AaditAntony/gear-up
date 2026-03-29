import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import 'package:gear_up/service-center/pages/verification_pending_page.dart';

class ServiceCenterFormPage extends StatefulWidget {
  const ServiceCenterFormPage({super.key});

  @override
  State<ServiceCenterFormPage> createState() => _ServiceCenterFormPageState();
}

class _ServiceCenterFormPageState extends State<ServiceCenterFormPage> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternatePhoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController googleMapLinkController = TextEditingController();

  String? selectedDistrict;

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
    "Kasaragod"
  ];

  Uint8List? image1Bytes;
  Uint8List? image2Bytes;

  String? image1Base64;
  String? image2Base64;

  bool isLoading = false;

  Future<void> pickImage(int imageNumber) async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    Uint8List bytes = await pickedFile.readAsBytes();

    if (bytes.length > 500 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image must be under 500 KB")),
      );
      return;
    }

    String base64String = base64Encode(bytes);

    setState(() {
      if (imageNumber == 1) {
        image1Bytes = bytes;
        image1Base64 = base64String;
      } else {
        image2Bytes = bytes;
        image2Base64 = base64String;
      }
    });
  }

  Future<void> submitForm() async {
    if (companyNameController.text.trim().isEmpty ||
        ownerNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        selectedDistrict == null ||
        stateController.text.trim().isEmpty ||
        pincodeController.text.trim().isEmpty ||
        experienceController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        image1Base64 == null ||
        image2Base64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;
      String email = FirebaseAuth.instance.currentUser!.email ?? "";

      await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .set({
        'companyName': companyNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'alternatePhone': alternatePhoneController.text.trim(),
        'location': locationController.text.trim(),
        'district': selectedDistrict,
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'gstNumber': gstController.text.trim(),
        'experienceYears': experienceController.text.trim(),
        'description': descriptionController.text.trim(),
        'googleMapLink': googleMapLinkController.text.trim(),
        'image1': image1Base64,
        'image2': image2Base64,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileCompleted': true,
      });

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application submitted successfully.")),
      );

      // Navigate to VerificationPendingPage instead of popping
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VerificationPendingPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,
      appBar: AppBar(
        title: const Text(
          "Service Center Registration",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: ServiceTheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 800,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ServiceTheme.primary, ServiceTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ServiceTheme.cardShadow,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.business_rounded, color: Colors.white, size: 48),
                      SizedBox(height: 16),
                      Text(
                        "Workshop Enrollment",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Provide your business details to join our network.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: ServiceTheme.cardDecoration,
                  child: Column(
                    children: [
                      _sectionTitle("Basic Information"),
                      const SizedBox(height: 24),
                      _buildField(
                          companyNameController, "Company Name", Icons.business),
                      _buildField(ownerNameController, "Owner Name", Icons.person),
                      Row(
                        children: [
                          Expanded(
                              child: _buildField(
                                  phoneController, "Primary Phone", Icons.phone)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildField(alternatePhoneController,
                                  "Alternate Phone", Icons.phone_android)),
                        ],
                      ),
                      _buildField(
                          locationController, "Street Address", Icons.location_on),
                      _buildField(googleMapLinkController,
                          "Google Maps URL (Optional)", Icons.add_location_alt),

                      const SizedBox(height: 24),
                      _sectionTitle("Location Details"),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedDistrict,
                              decoration: _inputDecoration("District", Icons.map),
                              items: districts.map((district) {
                                return DropdownMenuItem(
                                  value: district,
                                  child: Text(district),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDistrict = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child:
                                  _buildField(stateController, "State", Icons.public)),
                        ],
                      ),
                      _buildField(pincodeController, "Pincode", Icons.pin_drop),

                      const SizedBox(height: 24),
                      _sectionTitle("Business Verification"),
                      const SizedBox(height: 24),
                      _buildField(gstController, "GST Number (Optional)", Icons.receipt),
                      _buildField(experienceController, "Years of Experience",
                          Icons.work_history),
                      _buildField(descriptionController, "Company Description",
                          Icons.description,
                          maxLines: 4),

                      const SizedBox(height: 40),
                      _sectionTitle("Required Documents"),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _imageUploadCard(
                                "Business License", image1Bytes, () => pickImage(1)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _imageUploadCard(
                                "Workshop Image", image2Bytes, () => pickImage(2)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      /// SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ServiceTheme.accent,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: ServiceTheme.accent.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading ? null : submitForm,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded),
                                    SizedBox(width: 12),
                                    Text(
                                      "Submit Application",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: ServiceTheme.accent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: ServiceTheme.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          color: ServiceTheme.textSecondary, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: ServiceTheme.accent),
      filled: true,
      fillColor: ServiceTheme.background.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ServiceTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ServiceTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ServiceTheme.accent, width: 2),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _imageUploadCard(
    String title,
    Uint8List? image,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: ServiceTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ServiceTheme.border, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(image, width: double.infinity, fit: BoxFit.cover),
                ),
              )
            else ...[
              const Icon(Icons.cloud_upload_outlined,
                  size: 40, color: ServiceTheme.accent),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ServiceTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Tap to browse",
                style: TextStyle(fontSize: 11, color: ServiceTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}