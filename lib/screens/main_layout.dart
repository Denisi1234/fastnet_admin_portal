import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/screens/dashboard_screen.dart';
import 'package:admin_portal/screens/users_screen.dart';
import 'package:admin_portal/screens/listings_screen.dart';
import 'package:admin_portal/screens/settings_screen.dart';
import 'package:admin_portal/screens/tickets_screen.dart';
import 'package:admin_portal/screens/login_screen.dart';
import 'package:admin_portal/services/api_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const UsersScreen(),
    const ListingsScreen(),
    const TicketsScreen(),
    const SettingsScreen(),
  ];

  String _getUserInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'AD';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser ?? {'name': 'Administrator', 'role': 'admin'};
    final userName = user['name'] ?? 'Administrator';
    final userRole = user['role'] == 'admin' ? 'Super Admin' : user['role'] ?? 'Admin';
    final initials = _getUserInitials(userName);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            backgroundColor: AppTheme.surface,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: MediaQuery.of(context).size.width >= 800,
            minExtendedWidth: 250,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.hub, color: AppTheme.primary, size: 36),
                  if (MediaQuery.of(context).size.width >= 800) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'FASTNET Admin',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            selectedIconTheme: const IconThemeData(color: AppTheme.primary),
            unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
            selectedLabelTextStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
            unselectedLabelTextStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            useIndicator: false,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.home_work_outlined),
                selectedIcon: Icon(Icons.home_work),
                label: Text('Listings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.support_agent_outlined),
                selectedIcon: Icon(Icons.support_agent),
                label: Text('Tickets'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: PopupMenuButton<String>(
                    offset: const Offset(50, 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await ApiService.logout();
                        if (!mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else if (value == 'theme') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme switched!')));
                      } else if (value == 'profile') {
                        setState(() => _selectedIndex = 4); // Go to settings
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.person_outline), title: Text('Edit Profile'), contentPadding: EdgeInsets.zero)),
                      const PopupMenuItem(value: 'theme', child: ListTile(leading: Icon(Icons.dark_mode_outlined), title: Text('Switch Theme'), contentPadding: EdgeInsets.zero)),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Logout', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
                    ],
                    child: MediaQuery.of(context).size.width >= 800
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.textPrimary,
                                  child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14), overflow: TextOverflow.ellipsis),
                                      Text(userRole, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.expand_less, color: AppTheme.textSecondary, size: 20),
                              ],
                            ),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.textPrimary,
                            child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.border),
          // Main Content Area
          Expanded(
            child: Container(
              color: AppTheme.background,
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
