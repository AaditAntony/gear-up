import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _markRead();
  }

  void _markRead() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    NotificationService.markAllAsRead(uid);
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2563EB), size: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_none_rounded, size: 48, color: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Stay Updated",
                      style: TextStyle(fontSize: 20, color: Color(0xFF1E293B), fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "We'll notify you here when there are updates on your service bookings or vehicle health.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), height: 1.5, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            itemCount: docs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              bool isRead = data['isRead'] ?? false;
              DateTime? time = (data['timestamp'] as Timestamp?)?.toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  border: Border.all(
                    color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFF2563EB).withOpacity(0.1),
                    width: isRead ? 1 : 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isRead ? const Color(0xFFF8FAFC) : const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getIcon(data['title']),
                          color: isRead ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                          size: 24,
                        ),
                      ),
                      if (!isRead)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    data['title'] ?? "System Update",
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                      fontSize: 15,
                      color: isRead ? const Color(0xFF475569) : const Color(0xFF2563EB),
                      letterSpacing: -0.3,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        data['message'] ?? "",
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          height: 1.4,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: const Color(0xFFCBD5E1)),
                          const SizedBox(width: 4),
                          Text(
                            time != null ? DateFormat('MMM d, h:mm a').format(time) : "Just now",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
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
      ),
    );
  }

  IconData _getIcon(String? title) {
    if (title == null) return Icons.notifications_rounded;
    String t = title.toLowerCase();
    if (t.contains("started")) return Icons.build_circle_rounded;
    if (t.contains("completed") || t.contains("finished")) return Icons.check_circle_rounded;
    if (t.contains("approved") || t.contains("accepted")) return Icons.verified_rounded;
    if (t.contains("rejected")) return Icons.cancel_rounded;
    return Icons.info_rounded;
  }
}
