import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/api_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _statusFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _statuses = [
    'All',
    'Pending',
    'Confirmed',
    'Checked In',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchAdminBookings();
    if (mounted) {
      setState(() {
        _bookings = list;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _bookings.where((b) {
        final matchesStatus =
            _statusFilter == 'All' || b['status'] == _statusFilter;
        final query = _searchQuery.toLowerCase();
        final matchesSearch = query.isEmpty ||
            (b['guest_name'] ?? '').toString().toLowerCase().contains(query) ||
            (b['property_name'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (b['id'] ?? '').toString().toLowerCase().contains(query);
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Pending':
        return AppTheme.warning;
      case 'Confirmed':
        return const Color(0xFF1A56DB);
      case 'Checked In':
        return AppTheme.success;
      case 'Completed':
        return AppTheme.textSecondary;
      case 'Cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'TSh 0';
    final num value = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
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

  int _calcNights(dynamic checkIn, dynamic checkOut) {
    try {
      final ci = DateTime.parse(checkIn.toString());
      final co = DateTime.parse(checkOut.toString());
      return co.difference(ci).inDays;
    } catch (_) {
      return 0;
    }
  }

  void _showBookingDetail(Map<String, dynamic> booking) {
    String selectedStatus = booking['status'] ?? 'Pending';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  '#${booking['id'] ?? ''}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Guest', booking['guest_name'] ?? '-'),
                _detailRow('Property', booking['property_name'] ?? '-'),
                _detailRow('Check-in', _formatDate(booking['check_in'])),
                _detailRow('Check-out', _formatDate(booking['check_out'])),
                _detailRow(
                  'Nights',
                  '${_calcNights(booking['check_in'], booking['check_out'])} nights',
                ),
                _detailRow(
                  'Total Price',
                  _formatCurrency(booking['total_price']),
                ),
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
                  items: [
                    'Pending',
                    'Confirmed',
                    'Checked In',
                    'Completed',
                    'Cancelled'
                  ].map((s) {
                    return DropdownMenuItem(
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
                    );
                  }).toList(),
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
              onPressed: () async {
                Navigator.pop(ctx);
                final id = booking['id'];
                if (id != null) {
                  final bookingId = id is int ? id : int.tryParse(id.toString()) ?? 0;
                  final success = await ApiService.updateBookingStatus(bookingId, selectedStatus);
                  if (mounted) {
                    if (success) {
                      _loadBookings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking status updated to $selectedStatus'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update status.'),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                    }
                  }
                }
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
                    'Bookings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filtered.length} booking${_filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _loadBookings,
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

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statuses.map((status) {
                final isActive = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isActive,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _statusFilter = status);
                        _applyFilters();
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

          // Table container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Search by guest name, property or booking ID...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppTheme.border),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: AppTheme.border),

                  // Data
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
                                    Icon(Icons.book_online_outlined,
                                        size: 64,
                                        color: AppTheme.textSecondary),
                                    SizedBox(height: 16),
                                    Text(
                                      'No bookings found.',
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
                                    dataRowMaxHeight: 72,
                                    dataRowMinHeight: 72,
                                    columns: const [
                                      DataColumn(
                                        label: Text('Booking',
                                            style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      DataColumn(
                                        label: Text('Guest',
                                            style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      DataColumn(
                                        label: Text('Property',
                                            style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      DataColumn(
                                        label: Text('Check-in / Check-out',
                                            style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      DataColumn(
                                        label: Text('Total',
                                            style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      DataColumn(
                                        label: Text('Status',
                                            style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                    rows: _filtered.map((booking) {
                                      final status =
                                          booking['status'] ?? 'Pending';
                                      final color = _statusColor(status);
                                      final nights = _calcNights(
                                          booking['check_in'],
                                          booking['check_out']);

                                      return DataRow(
                                        onSelectChanged: (_) =>
                                            _showBookingDetail(booking),
                                        cells: [
                                          DataCell(
                                            Text(
                                              '#${booking['id'] ?? ''}',
                                              style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              booking['guest_name'] ?? '-',
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: 160,
                                              child: Text(
                                                booking['property_name'] ?? '-',
                                                style: const TextStyle(
                                                    color:
                                                        AppTheme.textSecondary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _formatDate(
                                                      booking['check_in']),
                                                  style: const TextStyle(
                                                      color:
                                                          AppTheme.textPrimary,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  '→ ${_formatDate(booking['check_out'])}  ($nights nights)',
                                                  style: const TextStyle(
                                                      color:
                                                          AppTheme.textSecondary,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              _formatCurrency(
                                                  booking['total_price']),
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.1),
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
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                  ),

                  // Footer
                  const Divider(height: 1, thickness: 1, color: AppTheme.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${_filtered.length} of ${_bookings.length} bookings',
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
