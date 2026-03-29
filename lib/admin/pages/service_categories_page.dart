import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategoriesPage extends StatefulWidget {
  const ServiceCategoriesPage({super.key});

  @override
  State<ServiceCategoriesPage> createState() => _ServiceCategoriesPageState();
}

class _ServiceCategoriesPageState extends State<ServiceCategoriesPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Future<void> addCategory() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('service_categories').add({
      'name': nameController.text.trim(),
      'basePrice': double.tryParse(priceController.text.trim()) ?? 0,
      'createdAt': Timestamp.now(),
    });

    nameController.clear();
    priceController.clear();
  }

  Future<void> deleteCategory(String id) async {
    await FirebaseFirestore.instance
        .collection('service_categories')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PAGE HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Service Portfolio",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Define and catalog the service offerings for the platform.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.category_rounded, color: Color(0xFF8B5CF6)),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ADD CATEGORY FORM (Modernized)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CATEGORY DESIGNATION",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: nameController,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              decoration: InputDecoration(
                                hintText: "e.g. Premium Periodic Maintenance",
                                hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.5), fontSize: 14),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "BASE UNIT PRICE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                              decoration: InputDecoration(
                                prefixText: "₹ ",
                                prefixStyle: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900),
                                hintText: "0.00",
                                hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.5), fontSize: 14),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            elevation: 8,
                            shadowColor: const Color(0xFF1E293B).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: addCategory,
                          child: Row(
                            children: const [
                              Icon(Icons.add_task_rounded, size: 20),
                              const SizedBox(width: 12),
                              Text("Register Category", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                sectionHeader("Catalog Distribution"),

                const SizedBox(height: 32),

                /// CATEGORY LIST
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('service_categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var categories = snapshot.data!.docs;

                    if (categories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20),
                                ],
                              ),
                              child: Icon(Icons.inventory_rounded, size: 64, color: Colors.grey[200]),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "The catalog is currently empty.",
                              style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        var category = categories[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.layers_rounded,
                                  color: Color(0xFF8B5CF6),
                                  size: 26,
                                ),
                              ),

                              const SizedBox(width: 24),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category['name'] ?? "Unnamed",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        Text(
                                          "Standardized Price:",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: const Color(0xFF1E293B).withOpacity(0.4),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "₹${category['basePrice']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              /// DELETE ACTION
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                    onPressed: () => deleteCategory(category.id),
                                    tooltip: "Remove Category",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget sectionHeader(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
