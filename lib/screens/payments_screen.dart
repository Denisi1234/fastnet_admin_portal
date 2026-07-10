import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/api_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _statusFilter = 'All';

  static const List<String> _statuses = [
    'All',
    'Successful',
    'Pending',
    'Failed',
    'Refunded',
  ];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchAdminPayments();
    if (mounted) {
      setState(() {
        _payments = list;
        _isLoading = false;
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _statusFilter == 'All'
          ? List.from(_payments)
          : _payments.where((p) => p['status'] == _statusFilter).toList();
    });
  }

  double get _totalRevenue {
    return _payments
        .where((p) => p['status'] == 'Successful')
        .fold(0.0, (sum, p) {
      final amt = p['amount'];
      return sum + (amt is num ? amt.toDouble() : double.tryParse(amt.toString()) ?? 0.0);
    });
  }

  int get _successfulCount =>
      _payments.where((p) => p['status'] == 'Successful').length;

  int get _pendingCount =>
      _payments.where((p) => p['status'] == 'Pending').length;

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'TSh 0';
    final num value =
        amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'TSh $formatted';
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    final s = dateStr.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Successful':
        return AppTheme.success;
      case 'Pending':
        return AppTheme.warning;
      case 'Failed':
        return AppTheme.danger;
      case 'Refunded':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _statCard(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
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
              const Text(
                'Payments',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loadPayments,
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
          const SizedBox(height: 28),

          // Summary stat cards
          Row(
            children: [
              _statCard(
                icon: Icons.payments_outlined,
                label: 'Total Revenue',
                value: _formatCurrency(_totalRevenue),
                color: AppTheme.success,
              ),
              const SizedBox(width: 16),
              _statCard(
                icon: Icons.check_circle_outline,
                label: 'Successful',
                value: _successfulCount.toString(),
                color: const Color(0xFF1A56DB),
              ),
              const SizedBox(width: 16),
              _statCard(
                icon: Icons.pending_outlined,
                label: 'Pending',
                value: _pendingCount.toString(),
                color: AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statuses.map((s) {
                final isActive = _statusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isActive,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _statusFilter = s);
                        _applyFilter();
                      }
                    },
                    selectedColor: AppTheme.textPrimary,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

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
                        : _filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.payments_outlined,
                                        size: 64,
                                        color: AppTheme.textSecondary),
                                    SizedBox(height: 16),
                                    Text(
                                      'No payments found.',
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
                                          label: Text('Payment ID',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Booking Ref',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Guest',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Amount',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      DataColumn(
                                          label: Text('Gateway',
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
                                          label: Text('Date',
                                              style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ],
                                    rows: _filtered.map((payment) {
                                      final status =
                                          payment['status'] ?? 'Pending';
                                      final color = _statusColor(status);
                                      return DataRow(cells: [
                                        DataCell(
                                          Text(
                                            '#${payment['id'] ?? ''}',
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '#${payment['booking_id'] ?? '-'}',
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            payment['guest_name'] ?? '-',
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatCurrency(payment['amount']),
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceHighlight,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: AppTheme.border),
                                            ),
                                            child: Text(
                                              payment['gateway'] ?? '-',
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
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
                                        DataCell(
                                          Text(
                                            _formatDate(
                                                payment['created_at'] ??
                                                    payment['date']),
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ],
                              ),
                  ),
                  const Divider(height: 1, thickness: 1, color: AppTheme.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${_filtered.length} of ${_payments.length} payments',
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
