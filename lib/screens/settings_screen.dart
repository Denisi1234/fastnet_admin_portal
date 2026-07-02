import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/core/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTab = 0;
  
  // General State
  bool _maintenanceMode = false;
  bool _autoApproveHosts = true;
  
  // Financial State
  double _commissionRate = 15.0;
  
  // Security State
  bool _require2FA = true;
  double _sessionTimeout = 30.0;
  
  // Notification State
  bool _emailDailyDigest = true;
  bool _emailNewTickets = true;
  bool _emailLargeBookings = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings Inner Sidebar
                  Container(
                    width: 250,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: AppTheme.border)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      children: [
                        _buildMenuTab(0, 'General', Icons.settings_outlined),
                        _buildMenuTab(1, 'Financials', Icons.attach_money),
                        _buildMenuTab(2, 'Security & Access', Icons.security),
                        _buildMenuTab(3, 'Notifications', Icons.notifications_none),
                        _buildMenuTab(4, 'Accessibility & i18n', Icons.accessibility_new),
                      ],
                    ),
                  ),
                  
                  // Settings Content
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        color: isSelected ? AppTheme.surfaceHighlight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    Widget content;
    switch (_selectedTab) {
      case 0:
        content = _buildGeneralSettings();
        break;
      case 1:
        content = _buildFinancialSettings();
        break;
      case 2:
        content = _buildSecuritySettings();
        break;
      case 3:
        content = _buildNotificationSettings();
        break;
      case 4:
        content = _buildAccessibilitySettings();
        break;
      default:
        content = const SizedBox.shrink();
    }
    
    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        content,
        const SizedBox(height: 48),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('General Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Manage your platform\'s core behavior and support info.', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        _buildSectionHeader('Platform Status'),
        _buildToggleRow(
          'Maintenance Mode', 
          'Disables the mobile app for all users and shows a maintenance screen.', 
          _maintenanceMode, 
          (val) => setState(() => _maintenanceMode = val)
        ),
        const Divider(height: 32, color: AppTheme.border),
        _buildSectionHeader('User Onboarding'),
        _buildToggleRow(
          'Auto-Approve New Hosts', 
          'If disabled, new hosts must be manually verified by an admin before they can list properties.', 
          _autoApproveHosts, 
          (val) => setState(() => _autoApproveHosts = val)
        ),
        const Divider(height: 32, color: AppTheme.border),
        _buildSectionHeader('Support Information'),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support Email Address', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            SizedBox(
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. support@fastnet.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                controller: TextEditingController(text: 'support@fastnet.com'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Financial Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Manage your platform commission, payouts, and fees.', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        _buildSectionHeader('Revenue Model'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Platform Commission Rate', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('The percentage taken from each booking before payout to the host.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: _commissionRate,
                    min: 5,
                    max: 30,
                    divisions: 25,
                    label: '${_commissionRate.round()}%',
                    activeColor: AppTheme.primary,
                    onChanged: (value) => setState(() => _commissionRate = value),
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.centerRight,
                  child: Text('${_commissionRate.round()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                ),
              ],
            )
          ],
        ),
        const Divider(height: 32, color: AppTheme.border),
        _buildSectionHeader('Payouts'),
        _buildToggleRow(
          'Automated Host Payouts', 
          'Automatically send funds to hosts 24 hours after a guest checks in.', 
          true, 
          (val) {}
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security & Access', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Protect your admin portal and manage staff permissions.', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        _buildSectionHeader('Authentication'),
        _buildToggleRow(
          'Require 2FA for Admins', 
          'Force all staff members to use Two-Factor Authentication when logging into this portal.', 
          _require2FA, 
          (val) => setState(() => _require2FA = val)
        ),
        const Divider(height: 32, color: AppTheme.border),
        _buildSectionHeader('Session Management'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Admin Session Timeout', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Automatically log out admins after this many minutes of inactivity.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: _sessionTimeout,
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '${_sessionTimeout.round()}',
                    activeColor: AppTheme.primary,
                    onChanged: (value) => setState(() => _sessionTimeout = value),
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.centerRight,
                  child: Text('${_sessionTimeout.round()} min', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                ),
              ],
            )
          ],
        ),
        const Divider(height: 32, color: AppTheme.border),
        _buildSectionHeader('Active Staff Members'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceHighlight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: AppTheme.textPrimary, child: const Text('Y', style: TextStyle(color: Colors.white))),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You (Super Admin)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text('admin@fastnet.com', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.border),
                ),
                child: const Text('Manage Roles'),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Choose what events you want to be notified about.', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        _buildSectionHeader('Email Alerts'),
        _buildToggleRow(
          'Daily Revenue Digest', 
          'Receive a morning email summarizing the previous day\'s bookings and revenue.', 
          _emailDailyDigest, 
          (val) => setState(() => _emailDailyDigest = val)
        ),
        _buildToggleRow(
          'New Support Tickets', 
          'Send an email instantly when a guest or host opens a new high-priority dispute.', 
          _emailNewTickets, 
          (val) => setState(() => _emailNewTickets = val)
        ),
        _buildToggleRow(
          'High-Value Booking Alert', 
          'Get notified whenever a single booking exceeds \$1,000 in value.', 
          _emailLargeBookings, 
          (val) => setState(() => _emailLargeBookings = val)
        ),
      ],
    );
  }

  Widget _buildAccessibilitySettings() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        SettingsController.instance.isRtlNotifier,
        SettingsController.instance.textScaleNotifier,
        SettingsController.instance.isKiswahiliNotifier,
      ]),
      builder: (context, _) {
        final isRtl = SettingsController.instance.isRtlNotifier.value;
        final textScale = SettingsController.instance.textScaleNotifier.value;
        final isKiswahili = SettingsController.instance.isKiswahiliNotifier.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Accessibility & i18n', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Configure language, layout directions, and visual text scaling for the admin portal.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            _buildSectionHeader('Internationalization (i18n)'),
            _buildToggleRow(
              'Language (English / Kiswahili)', 
              isKiswahili ? 'Currently using Kiswahili as the primary language.' : 'Currently using English as the primary language.', 
              isKiswahili, 
              (val) => SettingsController.instance.toggleKiswahili(val)
            ),
            const Divider(height: 32, color: AppTheme.border),
            _buildSectionHeader('Accessibility & Layout'),
            _buildToggleRow(
              'Right-to-Left (RTL) Layout', 
              'Flip the entire dashboard layout to support RTL languages (like Arabic).', 
              isRtl, 
              (val) => SettingsController.instance.toggleRtl(val)
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Dynamic Text Scaling', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Globally increase the font size across the entire portal for better readability.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: textScale,
                        min: 1.0,
                        max: 2.0,
                        divisions: 10,
                        label: '${textScale.toStringAsFixed(1)}x',
                        activeColor: AppTheme.primary,
                        onChanged: (value) => SettingsController.instance.updateTextScale(value),
                      ),
                    ),
                    Container(
                      width: 60,
                      alignment: Alignment.centerRight,
                      child: Text('${textScale.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved successfully.'), backgroundColor: AppTheme.success),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.textPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
