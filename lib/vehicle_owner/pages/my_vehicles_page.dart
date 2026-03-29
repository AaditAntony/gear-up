/// ONLY UI + UX + SMALL UTIL LOGIC ADDED
/// FIREBASE LOGIC NOT CHANGED

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({super.key});

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  final vehicleNumberController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final mileageController = TextEditingController();

  String? fuelType;
  DateTime? lastServiceDate;

  Future<void> pickServiceDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => lastServiceDate = picked);
    }
  }

  Future<void> addVehicle() async {
    if (vehicleNumberController.text.isEmpty ||
        brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        mileageController.text.isEmpty ||
        fuelType == null ||
        lastServiceDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('vehicles').add({
      "userId": uid,
      "vehicleNumber": vehicleNumberController.text.trim(),
      "brand": brandController.text.trim(),
      "model": modelController.text.trim(),
      "fuelType": fuelType,
      "year": int.parse(yearController.text),
      "mileage": int.parse(mileageController.text),
      "lastServiceDate": Timestamp.fromDate(lastServiceDate!),
      "createdAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  Future<void> deleteVehicle(String id) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(id).delete();
  }

  /// HEALTH
  int calculateHealth(Map data) {
    int score = 100;

    int year = int.tryParse(data['year']?.toString() ?? '0') ?? 0;
    int mileage = int.tryParse(data['mileage']?.toString() ?? '0') ?? 0;

    Timestamp? ts = data['lastServiceDate'] as Timestamp?;
    DateTime lastService = ts?.toDate() ?? DateTime.now();

    int age = DateTime.now().year - year;
    int months = DateTime.now().difference(lastService).inDays ~/ 30;

    if (age >= 5) score -= 25;
    if (mileage >= 40000) score -= 25;
    if (months >= 6) score -= 25;

    return score.clamp(0, 100);
  }

  int monthsSinceService(dynamic ts) {
    if (ts == null || ts is! Timestamp) return 0;
    return DateTime.now().difference(ts.toDate()).inDays ~/ 30;
  }

  Color healthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }


  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PAGE HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "My Garage",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Monitor your vehicle health and service status",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: showAddVehicleSheet,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  tooltip: "Add Vehicle",
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vehicles')
                .where('userId', isEqualTo: uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        "Your garage is empty",
                        style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: showAddVehicleSheet,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Add Your First Vehicle"),
                      ),
                    ],
                  ),
                );
              }

              var vehicles = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: vehicles.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  var doc = vehicles[index];
                  var data = doc.data() as Map<String, dynamic>;

                  int score = calculateHealth(data);
                  Color color = healthColor(score);
                  int months = monthsSinceService(data['lastServiceDate']);
                  bool needsService = months >= 6;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// CARD HEADER
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.directions_car_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['vehicleNumber'] ?? "N/A",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2563EB),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${data['brand']} ${data['model']}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (val) {
                                  if (val == "delete") deleteVehicle(doc.id);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                        SizedBox(width: 10),
                                        Text("Remove Vehicle", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// HEALTH INDICATOR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Vehicle Health Score",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                "$score%",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              minHeight: 10,
                              color: color,
                              backgroundColor: const Color(0xFFF1F5F9),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// INFO GRID
                          Row(
                            children: [
                              _infoTile(Icons.speed_rounded, "${data['mileage']} km", "Odometer"),
                              const SizedBox(width: 12),
                              _infoTile(Icons.local_gas_station_rounded, data['fuelType'] ?? "N/A", "Fuel Type"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoTile(
                                Icons.history_rounded,
                                "$months months ago",
                                "Last Service",
                                isWarning: needsService,
                              ),
                              const SizedBox(width: 12),
                              _infoTile(Icons.event_rounded, data['year'].toString(), "Release Year"),
                            ],
                          ),

                          if (needsService)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      "Service is due for this vehicle. Over 6 months since last check.",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String value, String label, {bool isWarning = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isWarning ? Colors.redAccent.withOpacity(0.2) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: isWarning ? Colors.redAccent : const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isWarning ? Colors.redAccent : const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isWarning ? Colors.redAccent : const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }

  /// RESTORED AND MODERNIZED SHEET
  void showAddVehicleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                left: 32,
                right: 32,
                top: 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Vehicle",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _inputLabel("VEHICLE REGISTRATION"),
                    _field(vehicleNumberController, "e.g. KL-01-AB-1234", Icons.tag_rounded),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel("BRAND"),
                              _field(brandController, "e.g. Honda", Icons.branding_watermark_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel("MODEL"),
                              _field(modelController, "e.g. Activa", Icons.model_training_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _inputLabel("FUEL TYPE"),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: DropdownButtonFormField<String>(
                        value: fuelType,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_gas_station_rounded, color: Color(0xFF64748B), size: 18),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.all(18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                          DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                          DropdownMenuItem(value: "Electric", child: Text("Electric")),
                          DropdownMenuItem(value: "Hybrid", child: Text("Hybrid")),
                        ],
                        onChanged: (value) => setSheetState(() => fuelType = value),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel("MFG YEAR"),
                              _field(yearController, "2023", Icons.calendar_today_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputLabel("MILEAGE (KM)"),
                              _field(mileageController, "12000", Icons.speed_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _inputLabel("LAST SERVICE DATE"),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2015),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setSheetState(() => lastServiceDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.history_rounded, color: Color(0xFF64748B), size: 18),
                            const SizedBox(width: 12),
                            Text(
                              lastServiceDate == null ? "Select Date" : lastServiceDate.toString().split(" ")[0],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: lastServiceDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: addVehicle,
                        child: const Text(
                          "Add Vehicle to Garage",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                        ),
                      ),
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
////