import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<Map<String, dynamic>> _users = [
    {'id': 1, 'name': 'Alice Smith', 'role': 'Host', 'status': 'Active', 'joined': 'Jan 12, 2023', 'email': 'alice@example.com'},
    {'id': 2, 'name': 'Bob Jones', 'role': 'Guest', 'status': 'Active', 'joined': 'Mar 05, 2023', 'email': 'bob@example.com'},
    {'id': 3, 'name': 'Charlie Brown', 'role': 'Guest', 'status': 'Suspended', 'joined': 'Jun 22, 2023', 'email': 'charlie@example.com'},
    {'id': 4, 'name': 'Diana Prince', 'role': 'Host', 'status': 'Pending Verification', 'joined': 'Aug 10, 2023', 'email': 'diana@example.com'},
    {'id': 5, 'name': 'Evan Wright', 'role': 'Guest', 'status': 'Active', 'joined': 'Sep 01, 2023', 'email': 'evan@example.com'},
  ];

  void _toggleUserStatus(int index) {
    setState(() {
      if (_users[index]['status'] == 'Active') {
        _users[index]['status'] = 'Suspended';
      } else if (_users[index]['status'] == 'Pending Verification') {
        _users[index]['status'] = 'Active';
      } else {
        _users[index]['status'] = 'Active';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_users[index]['name']} is now ${_users[index]['status']}'), backgroundColor: AppTheme.textPrimary),
    );
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
              onPressed: () {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  setState(() {
                    _users.add({
                      'id': _users.length + 1,
                      'name': nameController.text,
                      'email': emailController.text,
                      'role': selectedRole,
                      'status': 'Active',
                      'joined': 'Today',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${nameController.text} added successfully!'), backgroundColor: AppTheme.success),
                  );
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
                  // Table
                  Expanded(
                    child: ListView(
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

                            return DataRow(
                              cells: [
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(user['name'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                                      Text(user['email'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    ],
                                  )
                                ),
                                DataCell(Text(user['role'], style: const TextStyle(color: AppTheme.textSecondary))),
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
                                        user['status'],
                                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(user['joined'], style: const TextStyle(color: AppTheme.textSecondary))),
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
                        const Text('Showing 1 to 5 of 50 entries', style: TextStyle(color: AppTheme.textSecondary)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: AppTheme.border),
                              onPressed: null, // Disabled on first page
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
