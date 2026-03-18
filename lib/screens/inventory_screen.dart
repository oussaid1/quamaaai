import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
                      Text(context.tr('inventory'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                        columns: [
                          DataColumn(label: Text(context.tr('name'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: Text(context.tr('quantity'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: Text(context.tr('expiry_date'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: Text(context.tr('availability'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          DataColumn(label: const Text('')),
                        ],
                        rows: filteredItems.map((item) => DataRow(
                          cells: [
                            DataCell(Text(item.name, style: TextStyle(
                              fontWeight: FontWeight.w500,
                              decoration: item.isConsumed ? TextDecoration.lineThrough : null,
                              color: item.isConsumed ? AppTheme.textSecondary : null,
                            ))),
                            DataCell(Text('${item.quantity} ${item.unit}')),
                            DataCell(Text(item.expiryDate != null ? DateFormat('yyyy-MM-dd').format(item.expiryDate!) : '-')),
                            DataCell(
                              GestureDetector(
                                onTap: () => _showStatusPicker(context, appState, item),
                                child: _buildStatusBadge(item),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart, size: 20, color: AppTheme.amber),
                                    onPressed: () {
                                      appState.addShoppingItem(ShoppingItem(
                                        name: item.name,
                                        category: 'RESTOCK',
                                        quantity: item.quantity > 0 ? item.quantity : 1.0,
                                        unit: item.unit,
                                      ));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${item.name} ${context.tr('added_to_shop')}')),
                                      );
                                    },
                                    tooltip: 'Add to Shopping List',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      item.isConsumed ? Icons.undo : Icons.check_circle_outline,
                                      size: 20, 
                                      color: item.isConsumed ? AppTheme.textSecondary : AppTheme.emerald
                                    ),
                                    onPressed: () => appState.toggleConsumed(item.id),
                                    tooltip: context.tr('consumed'),
                                  ),
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

  void _showStatusPicker(BuildContext context, AppState appState, InventoryItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle, color: AppTheme.emerald),
            title: const Text('In Stock'),
            onTap: () {
              appState.updateInventoryItem(item.copyWith(isConsumed: false));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle, color: AppTheme.rose),
            title: const Text('Out of Stock / Consumed'),
            onTap: () {
              appState.updateInventoryItem(item.copyWith(isConsumed: true));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InventoryItem item) {
    if (item.isConsumed) {
      return _badge('Out of Stock', AppTheme.rose);
    }
    if (item.isExpired) {
      return _badge(context.tr('expired'), AppTheme.rose);
    }
    if (item.isExpiringSoon) {
      return _badge(context.tr('ending_soon'), AppTheme.amber);
    }
    return _badge('In Stock', AppTheme.emerald);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Icon(Icons.edit, size: 10, color: color),
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
            Text(
              context.tr('inventory_desc'),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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
    DateTime? selectedDate = existingItem?.expiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingItem == null ? context.tr('add_item') : context.tr('edit')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController, 
                decoration: InputDecoration(labelText: context.tr('item_name'))
              ),
              TextField(
                controller: qtyController, 
                decoration: InputDecoration(labelText: context.tr('quantity')), 
                keyboardType: TextInputType.number
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: unit,
                items: ['kg', 'g', 'l', 'pcs', 'pack'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                onChanged: (v) => unit = v ?? 'pcs',
                decoration: InputDecoration(labelText: context.tr('unit')),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(context.tr('expiry_date')),
                subtitle: Text(selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '-'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(qtyController.text) ?? 0.0;
                if (nameController.text.isNotEmpty && qty > 0) {
                  if (existingItem == null) {
                    appState.addInventoryItem(InventoryItem(
                      name: nameController.text,
                      quantity: qty,
                      unit: unit,
                      expiryDate: selectedDate,
                    ));
                  } else {
                    appState.updateInventoryItem(existingItem.copyWith(
                      name: nameController.text,
                      quantity: qty,
                      unit: unit,
                      expiryDate: selectedDate,
                    ));
                  }
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emerald),
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }
}
