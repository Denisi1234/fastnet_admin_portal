import 'dart:async';
import 'package:admin_portal/services/api_service.dart';

class SupportService {
  static final SupportService instance = SupportService._internal();
  SupportService._internal();

  Future<void> init() async {
    // No-op for API compatibility
  }

  Future<List<Map<String, dynamic>>> loadTickets() async {
    final backendTickets = await ApiService.fetchTickets();
    return backendTickets.map((t) {
      final userObj = t['user'] ?? {};
      final userName = userObj['name'] ?? 'Unknown User';
      final userRole = userObj['role'] ?? 'Guest';
      
      final messages = (t['messages'] as List<dynamic>?)?.map((m) {
        return {
          'sender': m['sender'] ?? 'User',
          'text': m['text'] ?? '',
          'time': m['time'] ?? 'Just now',
        };
      }).toList() ?? [];

      return {
        'id': '#${t['id']}',
        'user': userName,
        'role': userRole,
        'issue': t['issue'] ?? 'Booking Dispute',
        'status': t['status'] ?? 'Open',
        'date': t['created_at'] != null ? t['created_at'].toString().substring(0, 10) : 'Today',
        'description': t['description'] ?? '',
        'messages': List<Map<String, dynamic>>.from(messages),
        'raw_id': t['id'],
      };
    }).toList();
  }

  Future<void> saveTickets(List<Map<String, dynamic>> tickets) async {
    // No-op as we save directly to database via API
  }

  Future<void> createTicket({
    required String userName,
    required String role,
    required String issue,
    required String description,
    required String initialMessage,
  }) async {
    // Created on backend
  }

  Future<void> sendMessage(String ticketId, String sender, String text) async {
    final cleanIdStr = ticketId.replaceFirst('#', '');
    final cleanId = int.tryParse(cleanIdStr);
    if (cleanId != null) {
      await ApiService.sendTicketMessage(cleanId, text);
    }
  }

  Future<void> updateStatus(String ticketId, String status) async {
    final cleanIdStr = ticketId.replaceFirst('#', '');
    final cleanId = int.tryParse(cleanIdStr);
    if (cleanId != null) {
      await ApiService.updateTicketStatus(cleanId, status);
    }
  }
}
