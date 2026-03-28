import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

class AddServicesPage extends StatefulWidget {
  const AddServicesPage({super.key});

  @override
  State<AddServicesPage> createState() => _AddServicesPageState();
}

class _AddServicesPageState extends State<AddServicesPage> {
  String? selectedCategoryId;
  String? selectedCategoryName;

  final TextEditingController priceController = TextEditingController();

  Future<void> addService() async {
    if (selectedCategoryId == null ||
        selectedCategoryName == null ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select category and enter price")),
      );
      return;
    }

    String centerId = FirebaseAuth.instance.currentUser!.uid;

    var existing = await FirebaseFirestore.instance
        .collection('center_services')
        .where('centerId', isEqualTo: centerId)
        .where('categoryId', isEqualTo: selectedCategoryId)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service already added")));
      return;
    }

    await FirebaseFirestore.instance.collection('center_services').add({
      'centerId': centerId,
      'categoryId': selectedCategoryId,
      'categoryName': selectedCategoryName,
      'price': double.tryParse(priceController.text.trim()) ?? 0,
      'createdAt': Timestamp.now(),
    });

    priceController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Service added successfully")));
  }

  Future<void> deleteService(String docId) async {
    await FirebaseFirestore.instance
        .collection('center_services')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT SIDE - ADD FORM
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(Icons.add_task_rounded, color: ServiceTheme.accent, size: 28),
                   SizedBox(width: 12),
                   Text("New Service", style: ServiceTheme.heading1),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Expand your workshop offerings by adding new service categories.", 
                style: ServiceTheme.body,
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(32),
                decoration: ServiceTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SELECT CATEGORY", style: ServiceTheme.label),
                    const SizedBox(height: 12),
                    
                    /// CATEGORY DROPDOWN
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('service_categories')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }

                        var categories = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "Choose a service type",
                            filled: true,
                            fillColor: ServiceTheme.background,
                            prefixIcon: const Icon(Icons.category_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          value: selectedCategoryId,
                          items: categories.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            var selectedDoc = categories.firstWhere(
                              (doc) => doc.id == value,
                            );

                            setState(() {
                              selectedCategoryId = value;
                              selectedCategoryName = selectedDoc['name'];
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text("SERVICE PRICING (INR)", style: ServiceTheme.label),
                    const SizedBox(height: 12),

                    /// PRICE FIELD
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        hintText: "e.g. 1500",
                        filled: true,
                        fillColor: ServiceTheme.background,
                        prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 32),

                    /// ADD BUTTON
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
                        onPressed: addService,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text("Register Service", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        /// RIGHT SIDE - MY SERVICES LIST
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(Icons.inventory_2_outlined, color: ServiceTheme.accent, size: 28),
                   SizedBox(width: 12),
                   Text("Services Inventory", style: ServiceTheme.heading1),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Your current active services for customers.", 
                style: ServiceTheme.body,
              ),

              const SizedBox(height: 32),

              /// SERVICE LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('center_services')
                      .where('centerId', isEqualTo: centerId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var services = snapshot.data!.docs;

                    if (services.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.layers_clear_outlined, size: 64, color: ServiceTheme.border.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            const Text("You haven't added any services yet.", style: ServiceTheme.body),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        var service = services[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
                            boxShadow: ServiceTheme.softShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: ServiceTheme.accent.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.settings_suggest_rounded, color: ServiceTheme.accent, size: 20),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service['categoryName'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: ServiceTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Operational Service",
                                      style: TextStyle(
                                        color: ServiceTheme.textSecondary.withOpacity(0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                "₹${service['price']}",
                                style: const TextStyle(
                                  color: ServiceTheme.accent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(width: 16),
                              Container(width: 1, height: 24, color: ServiceTheme.border.withOpacity(0.5)),
                              const SizedBox(width: 8),

                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: ServiceTheme.error, size: 20),
                                onPressed: () => deleteService(service.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
