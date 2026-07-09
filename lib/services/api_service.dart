import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _token;
  static Map<String, dynamic>? currentUser;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('admin_api_token');
      final userJson = prefs.getString('admin_user_data');
      if (userJson != null) {
        currentUser = jsonDecode(userJson) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('SharedPreferences init error: $e');
    }
  }

  static Future<void> saveSession(String token, Map<String, dynamic> user) async {
    _token = token;
    currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_api_token', token);
      await prefs.setString('admin_user_data', jsonEncode(user));
    } catch (e) {
      debugPrint('SharedPreferences saveSession error: $e');
    }
  }

  static Future<void> clearSession() async {
    _token = null;
    currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_api_token');
      await prefs.remove('admin_user_data');
    } catch (e) {
      debugPrint('SharedPreferences clearSession error: $e');
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static bool get isLoggedIn => _token != null;

  // ---------------------------------------------------------
  // AUTHENTICATION METHODS
  // ---------------------------------------------------------

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;

        // Verify if this is an administrator
        if (user['role'] != 'admin') {
          throw Exception('Unauthorized. Only administrators can log in here.');
        }

        final token = data['access_token'] as String;
        await saveSession(token, user);
        return data;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to log in.');
      }
    } catch (e) {
      debugPrint('API Admin Login Error: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: _headers,
        );
      }
    } catch (e) {
      debugPrint('API Logout Error: $e');
    } finally {
      await clearSession();
    }
  }

  // ---------------------------------------------------------
  // USER METHODS
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Users Error: $e');
    }
    return [];
  }

  static Future<bool> updateUserStatus(int userId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: _headers,
        body: jsonEncode({'status': newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Update User Status Error: $e');
    }
    return false;
  }

  static Future<bool> addUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: _headers,
        body: jsonEncode(userData),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('API Add User Error: $e');
    }
    return false;
  }

  // ---------------------------------------------------------
  // PROPERTY METHODS
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/properties'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Properties Error: $e');
    }
    return [];
  }

  static Future<bool> updatePropertyStatus(int propertyId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/properties/$propertyId/status'),
        headers: _headers,
        body: jsonEncode({'status': newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Update Property Status Error: $e');
    }
    return false;
  }

  // ---------------------------------------------------------
  // SUPPORT TICKETS METHODS
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Tickets Error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> sendTicketMessage(int ticketId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/messages'),
        headers: _headers,
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('API Send Ticket Message Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateTicketStatus(int ticketId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tickets/$ticketId/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('API Update Ticket Status Error: $e');
    }
    return null;
  }
}
