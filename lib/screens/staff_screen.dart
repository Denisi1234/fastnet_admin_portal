import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/api_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;

  static const List<String> _roles = [
    'Manager',
    'Receptionist',
    'Cleaner',
    'Security',
    'Driver',
  ];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchAdminStaff();
    if (mounted) {
      setState(() {
        _staff = list;
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    final s = dateStr.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'Manager':
        return AppTheme.primary;
      case 'Receptionist':
        return const Color(0xFF1A56DB);
      case 'Cleaner':
        return AppTheme.success;
      case 'Security':
        return AppTheme.warning;
      case 'Driver':
        return const Color(0xFF7C3AED);
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? existing}) {
    final nameController =
        TextEditingController(text: existing?['name'] ?? '');
    final phoneController =
        TextEditingController(text: existing?['phone'] ?? '');
    String selectedRole = existing?['role'] ?? _roles.first;
    final isEditing = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Staff Member' : 'Add Staff Member',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.badge_outlined,
                        color: AppTheme.textSecondary),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _roleColor(role),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(role),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDlg(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                setState(() => _isLoading = true);

                bool success;
                if (isEditing) {
                  final id = existing!['id'];
                  final staffId =
                      id is int ? id : int.tryParse(id.toString()) ?? 0;
                  success = await ApiService.updateStaffMember(staffId, {
                    'name': name,
                    'role': selectedRole,
                    'phone': phone,
                  });
                } else {
                  success = await ApiService.addStaffMember({
                    'name': name,
                    'role': selectedRole,
                    'phone': phone,
                  });
                }

                await _loadStaff();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? (isEditing
                              ? '$name updated successfully!'
                              : '$name added to staff!')
                          : 'Operation failed. Please try again.'),
                      backgroundColor:
                          success ? AppTheme.success : AppTheme.danger,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isEditing ? 'Save Changes' : 'Add Staff'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Staff Member',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${member['name'] ?? 'this staff member'}? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final id = member['id'];
              final staffId =
                  id is int ? id : int.tryParse(id.toString()) ?? 0;
              final success = await ApiService.deleteStaffMember(staffId);
              await _loadStaff();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '${member['name']} removed from staff.'
                        : 'Failed to delete. Please try again.'),
                    backgroundColor:
                        success ? AppTheme.textPrimary : AppTheme.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Staff Management',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_staff.length} staff member${_staff.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _loadStaff,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Staff',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary))
                        : _staff.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.badge_outlined,
                                        size: 64,
                                        color: AppTheme.textSecondary),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No staff members yet.',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => _showAddEditDialog(),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add First Staff Member'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.textPrimary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                children: [
                                  DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                        AppTheme.surfaceHighlight),
                                    dividerThickness: 1,
                                    dataRowMaxHeight: 72,
                                    dataRowMinHeight: 72,
                                    columns: const [
                                      DataColumn(
                                          label: Text('Staff Member',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Role',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Phone',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Added',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Actions',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ],
                                    rows: _staff.map((member) {
                                      final role = member['role'] ?? 'Staff';
                                      final roleColor = _roleColor(role);
                                      final name = member['name'] ?? '-';
                                      final initials = name.isNotEmpty
                                          ? name
                                              .trim()
                                              .split(' ')
                                              .where((p) => p.isNotEmpty)
                                              .map((p) => p[0])
                                              .take(2)
                                              .join()
                                              .toUpperCase()
                                          : '?';

                                      return DataRow(cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: roleColor
                                                    .withValues(alpha: 0.15),
                                                child: Text(
                                                  initials,
                                                  style: TextStyle(
                                                    color: roleColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: const TextStyle(
                                                      color: AppTheme.textPrimary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '#${member['id'] ?? ''}',
                                                    style: const TextStyle(
                                                      color:
                                                          AppTheme.textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  roleColor.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              role,
                                              style: TextStyle(
                                                color: roleColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            member['phone'] ?? '-',
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatDate(member['created_at']),
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                tooltip: 'Edit',
                                                onPressed: () =>
                                                    _showAddEditDialog(
                                                        existing: member),
                                                icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 20),
                                                color: AppTheme.textSecondary,
                                                hoverColor: AppTheme
                                                    .surfaceHighlight,
                                              ),
                                              IconButton(
                                                tooltip: 'Delete',
                                                onPressed: () =>
                                                    _confirmDelete(member),
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 20),
                                                color: AppTheme.danger,
                                                hoverColor: AppTheme.danger
                                                    .withValues(alpha: 0.08),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ],
                              ),
                  ),
                  const Divider(
                      height: 1, thickness: 1, color: AppTheme.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${_staff.length} staff members',
                          style:
                              const TextStyle(color: AppTheme.textSecondary),
                        ),
                        Row(
                          children: [
                            const IconButton(
                              icon: Icon(Icons.chevron_left,
                                  color: AppTheme.border),
                              onPressed: null,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.chevron_right,
                                  color: AppTheme.textPrimary),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
