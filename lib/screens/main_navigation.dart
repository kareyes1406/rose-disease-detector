import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'diagnosis_screen.dart';
import 'history_screen.dart';
import 'export_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DiagnosisScreen(),
    const HistoryScreen(),
    const ExportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: AppTheme.cardBorder, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          indicatorColor: AppTheme.primary.withOpacity(0.25),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.camera_alt, color: AppTheme.primary),
              label: 'Diagnóstico',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
              label: 'Historial',
            ),
            NavigationDestination(
              icon: Icon(Icons.picture_as_pdf_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.picture_as_pdf, color: AppTheme.primary),
              label: 'Exportar PDF',
            ),
          ],
        ),
      ),
    );
  }
}
