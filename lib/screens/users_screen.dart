import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchUsers();
    if (mounted) {
      setState(() {
        _users = list;
        _isLoading = false;
      });
    }
  }

  void _toggleUserStatus(int index) async {
    final user = _users[index];
    String nextStatus = 'Active';
    if (user['status'] == 'Active') {
      nextStatus = 'Suspended';
    } else if (user['status'] == 'Pending Verification') {
      nextStatus = 'Active';
    } else {
      nextStatus = 'Active';
    }

    final success = await ApiService.updateUserStatus(user['id'], nextStatus);
    if (success) {
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user['name']} status is now $nextStatus'), backgroundColor: AppTheme.textPrimary),
      );
    }
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Guest';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Role'),
                  items: ['Guest', 'Host', 'Admin'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedRole = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final role = selectedRole.toLowerCase();
                  
                  String mappedRole = 'customer';
                  if (role == 'host') {
                    mappedRole = 'owner';
                  } else if (role == 'admin') {
                    mappedRole = 'admin';
                  }

                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  
                  final success = await ApiService.addUser({
                    'name': name,
                    'email': email,
                    'password': 'password123', // default temp password
                    'role': mappedRole,
                    'status': 'Active',
                  });

                  if (success) {
                    _loadUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name added successfully!'), backgroundColor: AppTheme.success),
                    );
                  } else {
                    _loadUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add user.'), backgroundColor: AppTheme.danger),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Management',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton(
                onPressed: _showAddUserDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add User', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search users by name, email, or role...',
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Filters'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            side: const BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: AppTheme.border),
                  // Table / Loading
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
                        : _users.isEmpty
                            ? const Center(child: Text('No users registered.', style: TextStyle(color: AppTheme.textSecondary)))
                            : ListView(
                                children: [
                                  DataTable(
                                    headingRowColor: MaterialStateProperty.all(AppTheme.surfaceHighlight),
                                    dividerThickness: 1,
                                    dataRowMaxHeight: 70,
                                    dataRowMinHeight: 70,
                                    columns: const [
                                      DataColumn(label: Text('Name', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                                      DataColumn(label: Text('Role', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                                      DataColumn(label: Text('Status', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                                      DataColumn(label: Text('Joined', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                                      DataColumn(label: Text('Actions', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                                    ],
                                    rows: _users.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var user = entry.value;
                                      Color statusColor;
                                      switch (user['status']) {
                                        case 'Active':
                                          statusColor = AppTheme.success;
                                          break;
                                        case 'Suspended':
                                          statusColor = AppTheme.danger;
                                          break;
                                        default:
                                          statusColor = AppTheme.warning;
                                      }

                                      final roleStr = user['role'] == 'owner'
                                          ? 'Host'
                                          : (user['role'] == 'customer' ? 'Guest' : 'Admin');
                                      final joinedStr = user['created_at'] != null
                                          ? user['created_at'].toString().substring(0, 10)
                                          : 'Unknown';

                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(user['name'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                                                Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                              ],
                                            )
                                          ),
                                          DataCell(Text(roleStr, style: const TextStyle(color: AppTheme.textSecondary))),
                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  user['status'] ?? 'Active',
                                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(joinedStr, style: const TextStyle(color: AppTheme.textSecondary))),
                                          DataCell(
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () => _toggleUserStatus(index),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: user['status'] == 'Suspended' ? AppTheme.success : AppTheme.danger,
                                                  ),
                                                  child: Text(
                                                    user['status'] == 'Suspended' ? 'Unsuspend' : (user['status'] == 'Pending Verification' ? 'Approve' : 'Suspend'), 
                                                    style: const TextStyle(fontWeight: FontWeight.bold)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                  ),
                  // Pagination
                  const Divider(height: 1, thickness: 1, color: AppTheme.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Showing ${_users.length} entries', style: const TextStyle(color: AppTheme.textSecondary)),
                        Row(
                          children: [
                            const IconButton(
                              icon: Icon(Icons.chevron_left, color: AppTheme.border),
                              onPressed: null,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                              onPressed: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
