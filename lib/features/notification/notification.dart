import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  final NotificationService notificationService;

  const NotificationPage({
    Key? key,
    required this.userId,
    required this.notificationService,
  }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = widget.notificationService.fetchNotifications(widget.userId);
  }

  String timeSince(String sendAt) {
    final notificationTime = DateTime.parse(sendAt); // Parse the SendAt timestamp
    final currentTime = DateTime.now();
    final difference = currentTime.difference(notificationTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d, yyyy').format(notificationTime); // Fallback to full date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['NotiMessage']), // Dynamic message
                subtitle: Text(notification['NotiType']),
                trailing: Text(timeSince(notification['SendAt'])),
              );
            },
          );
        },
      ),
    );
  }
}
