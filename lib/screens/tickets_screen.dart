import 'dart:async';
import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/support_service.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  String _searchQuery = '';
  String _statusFilter = 'All';
  Map<String, dynamic>? _drawerSelectedTicket;

  List<Map<String, dynamic>> _tickets = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadTickets();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final list = await SupportService.instance.loadTickets();
    if (mounted) {
      setState(() {
        _tickets = list;
        if (_drawerSelectedTicket != null) {
          final ticketId = _drawerSelectedTicket!['id'];
          final found = _tickets.firstWhere((t) => t['id'] == ticketId, orElse: () => {});
          if (found.isNotEmpty) {
            _drawerSelectedTicket = found;
          }
        }
      });
    }
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    setState(() {
      _drawerSelectedTicket = ticket;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _drawerSelectedTicket == null) return;
    
    final text = _messageController.text.trim();
    _messageController.clear();
    await SupportService.instance.sendMessage(_drawerSelectedTicket!['id'], 'Agent', text);
    _loadTickets();
  }


  @override
  Widget build(BuildContext context) {
    final filteredTickets = _tickets.where((ticket) {
      final idMatches = ticket['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final userMatches = ticket['user'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final issueMatches = ticket['issue'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final statusMatches = _statusFilter == 'All' || ticket['status'] == _statusFilter;
      return (idMatches || userMatches || issueMatches) && statusMatches;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _buildTicketDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Support Tickets',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: AppTheme.textSecondary),
                      hintText: 'Search tickets...',
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            // Filter Tabs Row
            Row(
              children: ['All', 'Open', 'In Progress', 'Resolved'].map((status) {
                final isActive = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isActive,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _statusFilter = status;
                        });
                      }
                    },
                    selectedColor: AppTheme.textPrimary,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: filteredTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_number_outlined, size: 64, color: AppTheme.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No tickets found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredTickets.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          Color statusColor;
                          switch (ticket['status']) {
                            case 'Open':
                              statusColor = AppTheme.danger;
                              break;
                            case 'In Progress':
                              statusColor = AppTheme.warning;
                              break;
                            default:
                              statusColor = AppTheme.success;
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.surfaceHighlight,
                              child: Text(ticket['user'][0], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            ),
                            title: Row(
                              children: [
                                Text(ticket['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                const SizedBox(width: 8),
                                Text(ticket['issue'], style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Reported by ${ticket['user']} • ${ticket['date']}', style: const TextStyle(color: AppTheme.textSecondary)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    ticket['status'],
                                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () => _showTicketDetails(ticket),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.surfaceHighlight,
                                    foregroundColor: AppTheme.textPrimary,
                                    elevation: 0,
                                  ),
                                  child: const Text('View Chat'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDrawer() {
    if (_drawerSelectedTicket == null) return const Drawer();

    final ticket = _drawerSelectedTicket!;
    Color statusColor;
    switch (ticket['status']) {
      case 'Open':
        statusColor = AppTheme.danger;
        break;
      case 'In Progress':
        statusColor = AppTheme.warning;
        break;
      default:
        statusColor = AppTheme.success;
    }

    final messages = ticket['messages'] as List<Map<String, dynamic>>;

    return Drawer(
      width: 450,
      child: SafeArea(
        child: Column(
          children: [
            // Header Details
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            ticket['id'],
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          const Text('Discussion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // User Details & Dropdown status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['user'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Role: ${ticket['role']}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: ticket['status'],
                        dropdownColor: AppTheme.surface,
                        onChanged: (newStatus) async {
                          if (newStatus != null) {
                            await SupportService.instance.updateStatus(ticket['id'], newStatus);
                            _loadTickets();
                          }
                        },
                        items: ['Open', 'In Progress', 'Resolved'].map((status) {
                          Color color;
                          if (status == 'Open') {
                            color = AppTheme.danger;
                          } else if (status == 'In Progress') {
                            color = AppTheme.warning;
                          } else {
                            color = AppTheme.success;
                          }
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Issue Description:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ticket['description'],
                          style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Chat Discussion Bubbles
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isAgent = msg['sender'] == 'Agent';
                  final isSystem = msg['sender'] == 'System';

                  if (isSystem) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHighlight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                        ),
                      ),
                    );
                  }

                  return Align(
                    alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAgent ? AppTheme.textPrimary : AppTheme.surfaceHighlight,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isAgent ? const Radius.circular(12) : const Radius.circular(0),
                          bottomRight: isAgent ? const Radius.circular(0) : const Radius.circular(12),
                        ),
                        border: isAgent ? null : Border.all(color: AppTheme.border),
                      ),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'],
                            style: TextStyle(color: isAgent ? Colors.white : AppTheme.textPrimary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              msg['time'],
                              style: TextStyle(color: isAgent ? Colors.white60 : Colors.black45, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // Message Input bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
