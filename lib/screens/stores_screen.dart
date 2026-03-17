import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allStores = appState.stores;
    final filteredStores = allStores.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, appState),
          const SizedBox(height: 32),
          
          // Search Bar
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: context.tr('search'),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (filteredStores.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0),
                child: Column(
                  children: [
                    const Icon(Icons.store_outlined, size: 64, color: AppTheme.textSecondary),
                    const SizedBox(height: 16),
                    Text(context.tr('no_items_found'), style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];
                    return _buildStoreCard(context, appState, store);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('stores'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Manage credits and debts with your local stores.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddStoreDialog(context, appState),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Store'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
        ),
      ],
    );
  }

  Widget _buildStoreCard(BuildContext context, AppState appState, Store store) {
    final Color color = store.credit >= 0 ? AppTheme.emerald : AppTheme.rose;
    final String status = store.credit >= 0 ? '\$${store.credit.toStringAsFixed(2)} Credit' : '\$${store.credit.abs().toStringAsFixed(2)} Debt';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.store_outlined, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.textSecondary),
                  onPressed: () => appState.deleteStore(store.id),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.indigo),
                  onPressed: () => _showAddStoreDialog(context, appState, existingStore: store),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context, AppState appState, {Store? existingStore}) {
    final nameController = TextEditingController(text: existingStore?.name);
    final creditController = TextEditingController(text: existingStore?.credit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingStore == null ? 'Add Store' : 'Edit Store'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Store Name')),
            TextField(
              controller: creditController,
              decoration: const InputDecoration(labelText: 'Credit/Debt (use - for debt)'),
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final credit = double.tryParse(creditController.text) ?? 0.0;
              if (nameController.text.isNotEmpty) {
                if (existingStore == null) {
                  appState.addStore(Store(name: nameController.text, credit: credit));
                } else {
                  appState.updateStore(Store(id: existingStore.id, name: nameController.text, credit: credit));
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
            child: Text(existingStore == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}

