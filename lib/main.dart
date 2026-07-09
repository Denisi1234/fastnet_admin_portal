import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/screens/login_screen.dart';
import 'package:admin_portal/core/settings_controller.dart';
import 'package:admin_portal/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const AdminPortalApp());
}

class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsController.instance.isRtlNotifier,
      builder: (context, isRtl, child) {
        return ValueListenableBuilder<double>(
          valueListenable: SettingsController.instance.textScaleNotifier,
          builder: (context, textScale, child) {
            return MaterialApp(
              title: 'FASTNET Admin',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              builder: (context, child) {
                return Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(textScale),
                    ),
                    child: child!,
                  ),
                );
              },
              home: const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
