import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('settings'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          
          if (user != null) ...[
            _buildUserInfo(user),
            const SizedBox(height: 32),
          ],
          
          _buildPremiumSection(
            context,
            title: context.tr('appearance'),
            icon: Icons.palette_outlined,
            children: [
              _buildSettingTile(
                title: context.tr('theme_mode'),
                subtitle: 'Customize how the app looks on your device',
                trailing: DropdownButton<ThemeMode>(
                  value: appState.themeMode,
                  underline: const SizedBox(),
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) appState.changeTheme(newValue);
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
                  ],
                ),
              ),
              _buildSettingTile(
                title: context.tr('language'),
                subtitle: 'Choose your preferred language',
                trailing: DropdownButton<String>(
                  value: appState.locale.languageCode,
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) appState.changeLanguage(newValue);
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildPremiumSection(
            context,
            title: context.tr('data_management'),
            icon: Icons.storage_outlined,
            children: [
              _buildSettingTile(
                title: context.tr('export_data'),
                subtitle: 'Copy all your data as JSON to clipboard',
                onTap: () {
                  final data = appState.exportData();
                  Clipboard.setData(ClipboardData(text: data));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data exported to clipboard!')),
                  );
                },
                trailing: const Icon(Icons.copy_outlined, size: 20),
              ),
              _buildSettingTile(
                title: context.tr('import_data'),
                subtitle: 'Restore your records from clipboard JSON',
                onTap: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    await appState.importData(data!.text!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data imported successfully!')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No data found in clipboard')),
                      );
                    }
                  }
                },
                trailing: const Icon(Icons.download_outlined, size: 20),
              ),
              _buildSettingTile(
                title: context.tr('automation'),
                subtitle: context.tr('auto_add_desc'),
                trailing: Switch(
                  value: appState.autoAddToInventory,
                  onChanged: (v) => appState.setAutoAddToInventory(v),
                ),
              ),
              _buildSettingTile(
                title: context.tr('monthly_income'),
                subtitle: 'Set your monthly budget limit',
                trailing: Text('\$${appState.monthlyIncome.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emerald)),
                onTap: () => _showIncomeDialog(context, appState),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildPremiumSection(
            context,
            title: 'Account',
            icon: Icons.person_outline,
            children: [
              _buildSettingTile(
                title: context.tr('cloud_sync'),
                subtitle: 'Automatically back up data to the cloud',
                trailing: Switch(value: user != null, onChanged: (v) {}),
              ),
              _buildSettingTile(
                title: context.tr('logout'),
                subtitle: 'Safely sign out of HomeHub',
                textColor: AppTheme.rose,
                onTap: () => appState.signOut(),
                trailing: const Icon(Icons.logout, size: 20, color: AppTheme.rose),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(dynamic user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null ? const Icon(Icons.person, size: 30) : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.indigo),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.indigo),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.border, width: 0.5)),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  void _showIncomeDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: appState.monthlyIncome.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('edit_monthly_income')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: context.tr('income_amount')),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 5000.0;
              appState.setMonthlyIncome(val);
              Navigator.pop(context);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }
}
