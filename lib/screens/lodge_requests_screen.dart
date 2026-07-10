import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/api_service.dart';

class LodgeRequestsScreen extends StatefulWidget {
  const LodgeRequestsScreen({super.key});

  @override
  State<LodgeRequestsScreen> createState() => _LodgeRequestsScreenState();
}

class _LodgeRequestsScreenState extends State<LodgeRequestsScreen> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _statusFilter = 'All';
  String _typeFilter = 'All';

  static const List<String> _statusOptions = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchAdminLodgeRequests();
    if (mounted) {
      setState(() {
        _requests = list;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  List<String> get _typeOptions {
    final types = <String>{'All'};
    for (final r in _requests) {
      if (r['type'] != null) types.add(r['type'].toString());
    }
    return types.toList();
  }

  void _applyFilters() {
    setState(() {
      _filtered = _requests.where((r) {
        final matchStatus =
            _statusFilter == 'All' || r['status'] == _statusFilter;
        final matchType =
            _typeFilter == 'All' || r['type'] == _typeFilter;
        return matchStatus && matchType;
      }).toList();
    });
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
        return AppTheme.warning;
      case 'In Progress':
        return const Color(0xFF1A56DB);
      case 'Completed':
        return AppTheme.success;
      case 'Cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    final s = dateStr.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '-';
    final num value =
        amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'TSh $formatted';
  }

  void _showDetailDialog(Map<String, dynamic> request) {
    String selectedStatus = request['status'] ?? 'Pending';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${request['id'] ?? ''}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Service Request',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Room', request['room_number']?.toString() ?? '-'),
                _detailRow('Type', request['type'] ?? '-'),
                _detailRow('Description', request['description'] ?? '-'),
                _detailRow('Price', _formatCurrency(request['price'])),
                _detailRow('Requested', _formatDate(request['created_at'])),
                const SizedBox(height: 20),
                const Text(
                  'Update Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Pending', 'In Progress', 'Completed', 'Cancelled']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _statusColor(s),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(s,
                                    style: TextStyle(
                                        color: _statusColor(s),
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDlg(() => selectedStatus = val);
                  },
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
              onPressed: () {
                Navigator.pop(ctx);
                // Optimistically update local state
                setState(() {
                  final idx = _requests.indexWhere(
                      (r) => r['id'] == request['id']);
                  if (idx != -1) {
                    _requests[idx] = {..._requests[idx], 'status': selectedStatus};
                    _applyFilters();
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Request status updated to $selectedStatus'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                    'Lodge Service Requests',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filtered.length} request${_filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _loadRequests,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceHighlight,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter rows
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                const SizedBox(width: 8),
                ..._statusOptions.map((s) {
                  final isActive = _statusFilter == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: isActive,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _statusFilter = s);
                          _applyFilters();
                        }
                      },
                      selectedColor: AppTheme.textPrimary,
                      labelStyle: TextStyle(
                        color:
                            isActive ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
                const SizedBox(width: 16),
                const Text(
                  'Type:',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                const SizedBox(width: 8),
                ..._typeOptions.map((t) {
                  final isActive = _typeFilter == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: isActive,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _typeFilter = t);
                          _applyFilters();
                        }
                      },
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color:
                            isActive ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
                        : _filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.room_service_outlined,
                                        size: 64,
                                        color: AppTheme.textSecondary),
                                    SizedBox(height: 16),
                                    Text(
                                      'No service requests found.',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
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
                                    dataRowMaxHeight: 68,
                                    dataRowMinHeight: 68,
                                    columns: const [
                                      DataColumn(
                                          label: Text('Request ID',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Room',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Type',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Price',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Status',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Created',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ],
                                    rows: _filtered.map((req) {
                                      final status = req['status'] ?? 'Pending';
                                      final color = _statusColor(status);
                                      return DataRow(
                                        onSelectChanged: (_) =>
                                            _showDetailDialog(req),
                                        cells: [
                                          DataCell(Text('#${req['id'] ?? ''}',
                                              style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                          DataCell(Text(
                                              req['room_number']?.toString() ??
                                                  '-',
                                              style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppTheme.surfaceHighlight,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: AppTheme.border),
                                              ),
                                              child: Text(req['type'] ?? '-',
                                                  style: const TextStyle(
                                                      color:
                                                          AppTheme.textSecondary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                          DataCell(Text(
                                              _formatCurrency(req['price']),
                                              style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color:
                                                    color.withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(
                                              _formatDate(req['created_at']),
                                              style: const TextStyle(
                                                  color:
                                                      AppTheme.textSecondary))),
                                        ],
                                      );
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
                          'Showing ${_filtered.length} of ${_requests.length} requests',
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
