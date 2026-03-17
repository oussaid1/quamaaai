import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'budget_screen.dart';
import 'shopping_list_screen.dart';
import 'inventory_screen.dart';
import 'stores_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BudgetScreen(),
    const ShoppingListScreen(),
    const InventoryScreen(),
    const StoresScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if wide enough for a permanent sidebar
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.indigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Q', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text(context.tr('app_name'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          // Vertical divider
          if (isDesktop) Container(width: 1, color: AppTheme.border),
          // Main content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.indigo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Q', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Text(
                context.tr('app_name'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNavItem(0, context.tr('dashboard'), Icons.dashboard_outlined),
              _buildNavItem(1, context.tr('budget'), Icons.account_balance_wallet_outlined),
              _buildNavItem(2, context.tr('shopping_list'), Icons.shopping_cart_outlined),
              _buildNavItem(3, context.tr('inventory'), Icons.inventory_2_outlined),
              _buildNavItem(4, context.tr('stores'), Icons.store_outlined),
              _buildNavItem(5, context.tr('statistics'), Icons.bar_chart_outlined),
              _buildNavItem(6, context.tr('settings'), Icons.settings_outlined),
            ],
          ),
        ),
        // Footer / Logout
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              // TODO: Implement logout
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppTheme.textSecondary),
                  const SizedBox(width: 16),
                  Text(
                    context.tr('logout'),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          // Close drawer if on mobile
          if (MediaQuery.of(context).size.width < 800) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.indigoLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.indigo : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.indigo : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
