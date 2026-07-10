import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';


class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [
    {
      'id': 1,
      'title': 'Scheduled Maintenance',
      'body': 'The platform will undergo maintenance on July 15 from 2AM–4AM EAT.',
      'audience': 'All Users',
      'sentAt': 'Jul 8, 2026',
      'status': 'Sent',
      'reach': 14205,
    },
    {
      'id': 2,
      'title': 'New Feature: AI Room Recommendations',
      'body': 'We have launched AI-powered room recommendations based on your travel history.',
      'audience': 'Guests',
      'sentAt': 'Jul 5, 2026',
      'status': 'Sent',
      'reach': 10842,
    },
    {
      'id': 3,
      'title': 'Host Payout Policy Update',
      'body': 'Starting August 1, payouts will be processed every Monday instead of bi-weekly.',
      'audience': 'Hosts',
      'sentAt': 'Jul 3, 2026',
      'status': 'Sent',
      'reach': 3363,
    },
    {
      'id': 4,
      'title': 'Ramadan Special Promotions',
      'body': 'Offer your guests special Ramadan deals using the new Promotions tab in your dashboard.',
      'audience': 'Hosts',
      'sentAt': null,
      'status': 'Draft',
      'reach': 0,
    },
  ];

  int _nextId = 5;

  void _showNewAnnouncementDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String selectedAudience = 'All Users';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.campaign, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Announcement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Announcement Title',
                        hintText: 'e.g. Scheduled Maintenance',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Message Body',
                        hintText: 'Write the announcement message here…',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedAudience,
                      decoration: InputDecoration(
                        labelText: 'Target Audience',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                      items: ['All Users', 'Guests Only', 'Hosts Only'].map((a) {
                        return DropdownMenuItem(value: a, child: Text(a));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedAudience = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                OutlinedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    final audience = selectedAudience == 'Guests Only'
                        ? 'Guests'
                        : selectedAudience == 'Hosts Only'
                            ? 'Hosts'
                            : 'All Users';
                    setState(() {
                      _announcements.insert(0, {
                        'id': _nextId++,
                        'title': titleController.text.trim(),
                        'body': bodyController.text.trim().isEmpty
                            ? '(No body provided)'
                            : bodyController.text.trim(),
                        'audience': audience,
                        'sentAt': null,
                        'status': 'Draft',
                        'reach': 0,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved as Draft'), backgroundColor: AppTheme.warning),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Save as Draft', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    final audience = selectedAudience == 'Guests Only'
                        ? 'Guests'
                        : selectedAudience == 'Hosts Only'
                            ? 'Hosts'
                            : 'All Users';
                    final now = DateTime.now();
                    final today = _formatDate(now);
                    setState(() {
                      _announcements.insert(0, {
                        'id': _nextId++,
                        'title': titleController.text.trim(),
                        'body': bodyController.text.trim().isEmpty
                            ? '(No body provided)'
                            : bodyController.text.trim(),
                        'audience': audience,
                        'sentAt': today,
                        'status': 'Sent',
                        'reach': 0,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Announcement sent!'), backgroundColor: AppTheme.success),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAnnouncement(int id) {
    setState(() => _announcements.removeWhere((a) => a['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement deleted'), backgroundColor: AppTheme.danger),
    );
  }

  void _duplicateAnnouncement(Map<String, dynamic> a) {
    setState(() {
      _announcements.insert(0, {
        ...a,
        'id': _nextId++,
        'title': '${a['title']} (Copy)',
        'status': 'Draft',
        'sentAt': null,
        'reach': 0,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement duplicated as Draft'), backgroundColor: AppTheme.textPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Announcements',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Broadcast messages to users',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showNewAnnouncementDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Stats strip ─────────────────────────────────────────────────
          _buildStatsStrip(),
          const SizedBox(height: 32),

          // ── Announcement List ────────────────────────────────────────────
          Expanded(
            child: _announcements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 64, color: AppTheme.border),
                        const SizedBox(height: 16),
                        const Text('No announcements yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Create your first broadcast message using the button above.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildAnnouncementCard(_announcements[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsStrip() {
    final sentCount = _announcements.where((a) => a['status'] == 'Sent').length;
    final draftCount = _announcements.where((a) => a['status'] == 'Draft').length;
    final totalReach = _announcements.fold<int>(0, (sum, a) => sum + (a['reach'] as int));

    return Row(
      children: [
        _buildMiniStat('Total Sent', '$sentCount', Icons.check_circle_outline, AppTheme.success),
        const SizedBox(width: 16),
        _buildMiniStat('Drafts', '$draftCount', Icons.edit_outlined, AppTheme.warning),
        const SizedBox(width: 16),
        _buildMiniStat('Total Reach', '${_formatNumber(totalReach)} users', Icons.people_outline, AppTheme.primary),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> a) {
    final isSent = a['status'] == 'Sent';
    final audience = a['audience'] as String;
    final reach = a['reach'] as int;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title + menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon accent
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 16, top: 2),
                decoration: BoxDecoration(
                  color: isSent ? AppTheme.success.withOpacity(0.08) : AppTheme.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSent ? Icons.campaign : Icons.drafts_outlined,
                  color: isSent ? AppTheme.success : AppTheme.warning,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a['body'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteAnnouncement(a['id'] as int);
                  } else if (value == 'duplicate') {
                    _duplicateAnnouncement(a);
                  } else if (value == 'edit') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit coming soon'), backgroundColor: AppTheme.textPrimary),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, size: 18),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined, size: 18),
                      title: Text('Duplicate'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                      title: Text('Delete', style: TextStyle(color: AppTheme.danger)),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Bottom row: chips + reach + date
          Row(
            children: [
              _buildAudienceChip(audience),
              const SizedBox(width: 10),
              _buildStatusBadge(a['status'] as String),
              const Spacer(),
              if (isSent && reach > 0) ...[
                const Icon(Icons.people_outline, size: 15, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${_formatNumber(reach)} users reached',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 16),
              ],
              const Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                a['sentAt'] != null ? (a['sentAt'] as String) : 'Draft',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceChip(String audience) {
    Color color;
    IconData icon;
    switch (audience) {
      case 'Guests':
        color = const Color(0xFF1976D2);
        icon = Icons.person_outline;
        break;
      case 'Hosts':
        color = AppTheme.warning;
        icon = Icons.home_work_outlined;
        break;
      default: // All Users
        color = const Color(0xFF6A1B9A);
        icon = Icons.public;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            audience,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isSent = status == 'Sent';
    final color = isSent ? AppTheme.success : AppTheme.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return '$n';
  }
}
