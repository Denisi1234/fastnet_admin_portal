import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    const bool isProduction = false;
    if (isProduction) return 'https://api.fastnet.co.tz/api';
    return 'http://localhost:8000/api';
  }

  static String? _token;
  static Map<String, dynamic>? currentUser;

  static const Duration _timeout = Duration(seconds: 15);

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
      ).timeout(_timeout);
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
        ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
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
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('API Update Ticket Status Error: $e');
    }
    return null;
  }

  // ---------------------------------------------------------
  // ADMIN BOOKINGS METHODS
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchAdminBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/bookings'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Admin Bookings Error: $e');
    }
    return [];
  }

  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/bookings/$bookingId/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Update Booking Status Error: $e');
    }
    return false;
  }

  // ---------------------------------------------------------
  // ADMIN PAYMENTS METHODS
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchAdminPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/payments'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Admin Payments Error: $e');
    }
    return [];
  }

  // ---------------------------------------------------------
  // ADMIN LODGE SERVICE REQUESTS
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchAdminLodgeRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lodge-requests'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Admin Lodge Requests Error: $e');
    }
    return [];
  }

  // ---------------------------------------------------------
  // ADMIN STAFF MANAGEMENT
  // ---------------------------------------------------------

  static Future<List<Map<String, dynamic>>> fetchAdminStaff() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/staff'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('API Fetch Admin Staff Error: $e');
    }
    return [];
  }

  static Future<bool> addStaffMember(Map<String, dynamic> staffData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/staff'),
        headers: _headers,
        body: jsonEncode(staffData),
      ).timeout(_timeout);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('API Add Staff Error: $e');
    }
    return false;
  }

  static Future<bool> updateStaffMember(int id, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/staff/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Update Staff Error: $e');
    }
    return false;
  }

  static Future<bool> deleteStaffMember(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/staff/$id'),
        headers: _headers,
      ).timeout(_timeout);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('API Delete Staff Error: $e');
    }
    return false;
  }
}
