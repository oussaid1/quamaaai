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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('settings'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          
          _buildPremiumSection(
            context,
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              _buildSettingTile(
                title: 'Theme Mode',
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
                title: 'Language',
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
            title: 'Data Management',
            icon: Icons.storage_outlined,
            children: [
              _buildSettingTile(
                title: 'Export Data',
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
                title: 'Import Data',
                subtitle: 'Restore your records from clipboard JSON',
                onTap: () async {
                  final data = await Clipboard.getData(ClipboardData.mimeText);
                  if (data?.text != null) {
                    await appState.importData(data!.text!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data imported successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No data found in clipboard')),
                    );
                  }
                },
                trailing: const Icon(Icons.download_outlined, size: 20),
              ),
              _buildSettingTile(
                title: 'Auto Inventory',
                subtitle: 'Add to inventory on shopping purchase',
                trailing: Switch(
                  value: appState.autoAddToInventory,
                  onChanged: (v) => appState.setAutoAddToInventory(v),
                ),
              ),
              _buildSettingTile(
                title: 'Monthly Income',
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
                title: 'Cloud Sync',
                subtitle: 'Automatically back up data to the cloud',
                trailing: Switch(value: false, onChanged: (v) {}),
              ),
              _buildSettingTile(
                title: context.tr('logout'),
                subtitle: 'Safely sign out of HomeHub',
                textColor: AppTheme.rose,
                onTap: () {},
                trailing: const Icon(Icons.logout, size: 20, color: AppTheme.rose),
              ),
            ],
          ),
        ],
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
        title: const Text('Edit Monthly Income'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Income Amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 5000.0;
              appState.setMonthlyIncome(val);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

