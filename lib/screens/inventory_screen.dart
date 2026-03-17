import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allItems = appState.inventory;
    final filteredItems = allItems.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, appState),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kitchen Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: context.tr('search'),
                            prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (filteredItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Text(context.tr('no_items_found'), style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 32,
                        columns: const [
                          DataColumn(label: Text('NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: Text('QUANTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: Text('UNIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: Text('')),
                        ],
                        rows: filteredItems.map((item) => DataRow(
                          cells: [
                            DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text(item.quantity.toString())),
                            DataCell(Text(item.unit.toUpperCase())),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.indigo),
                                    onPressed: () => _showAddItemDialog(context, appState, existingItem: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.rose, size: 20),
                                    onPressed: () => appState.deleteInventoryItem(item.id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
          )
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
            Text(context.tr('inventory'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Keep track of what you have in your kitchen to avoid overbuying.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddItemDialog(context, appState),
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.tr('add_item')),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emerald),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, AppState appState, {InventoryItem? existingItem}) {
    final nameController = TextEditingController(text: existingItem?.name);
    final qtyController = TextEditingController(text: existingItem?.quantity.toString());
    String unit = existingItem?.unit ?? 'kg';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingItem == null ? 'Add Inventory Item' : 'Edit Inventory Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
            TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: unit,
              items: ['kg', 'g', 'l', 'pcs', 'pack'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (v) => unit = v ?? 'pcs',
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0.0;
              if (nameController.text.isNotEmpty && qty > 0) {
                if (existingItem == null) {
                  appState.addInventoryItem(InventoryItem(
                    name: nameController.text,
                    quantity: qty,
                    unit: unit,
                  ));
                } else {
                  appState.updateInventoryItem(InventoryItem(
                    id: existingItem.id,
                    name: nameController.text,
                    quantity: qty,
                    unit: unit,
                  ));
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emerald),
            child: Text(existingItem == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}

