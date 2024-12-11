import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl;

  NotificationService(this.baseUrl);

  // Fetch notifications for a user
  Future<List<Map<String, dynamic>>> fetchNotifications(int userId, {String? type}) async {
    final url = Uri.parse('$baseUrl/notifications/$userId${type != null ? '?type=$type' : ''}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['notifications']);
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  // Create a notification
  Future<void> createNotification(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/notifications');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create notification');
    }
  }
}
