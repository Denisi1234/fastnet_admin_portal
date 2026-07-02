import 'dart:async';

class ApiService {
  /// Simulates a network request delay
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Fetches a list of all users from the backend
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    await _simulateNetworkDelay();
    return [
      {'id': 1, 'name': 'Alice Smith', 'role': 'Host', 'status': 'Active', 'joined': 'Jan 12, 2023', 'email': 'alice@example.com'},
      {'id': 2, 'name': 'Bob Jones', 'role': 'Guest', 'status': 'Active', 'joined': 'Mar 05, 2023', 'email': 'bob@example.com'},
      {'id': 3, 'name': 'Charlie Brown', 'role': 'Guest', 'status': 'Suspended', 'joined': 'Jun 22, 2023', 'email': 'charlie@example.com'},
      {'id': 4, 'name': 'Diana Prince', 'role': 'Host', 'status': 'Pending Verification', 'joined': 'Aug 10, 2023', 'email': 'diana@example.com'},
      {'id': 5, 'name': 'Evan Wright', 'role': 'Guest', 'status': 'Active', 'joined': 'Sep 01, 2023', 'email': 'evan@example.com'},
    ];
  }

  /// Updates a user's status in the database
  static Future<bool> updateUserStatus(int userId, String newStatus) async {
    await _simulateNetworkDelay();
    // Simulate success
    return true;
  }

  /// Adds a new user to the system
  static Future<bool> addUser(Map<String, dynamic> userData) async {
    await _simulateNetworkDelay();
    // Simulate success
    return true;
  }
}
