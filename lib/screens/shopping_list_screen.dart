import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allItems = appState.shoppingList;
    final filteredItems = allItems.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(query) || 
             item.category.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, appState),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildMainList(context, appState, filteredItems)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildSidebarSections(context, appState)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildSidebarSections(context, appState),
                    const SizedBox(height: 24),
                    _buildMainList(context, appState, filteredItems),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
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
            Text(
              'shoppingList', // Explicitly matching image
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your household budget, shopping lists, and kitchen inventory in one place.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddItemDialog(context, appState),
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.tr('add_item')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildMainList(BuildContext context, AppState appState, List<ShoppingItem> items) {
    return Column(
      children: [
        // Search Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: context.tr('search'),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                context.tr('no_items_found'),
                style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildShoppingItemCard(context, appState, item);
            },
          ),
      ],
    );
  }

  Widget _buildShoppingItemCard(BuildContext context, AppState appState, ShoppingItem item) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: item.isBought,
          activeColor: AppTheme.amber,
          onChanged: (_) => appState.toggleShoppingItem(item.id),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
            color: item.isBought ? AppTheme.textSecondary : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(item.category, style: const TextStyle(fontSize: 11)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.rose, size: 20),
          onPressed: () => appState.deleteShoppingItem(item.id),
        ),
      ),
    );
  }

  Widget _buildSidebarSections(BuildContext context, AppState appState) {
    final items = appState.shoppingList;
    final total = items.length;
    final bought = items.where((i) => i.isBought).length;
    final remaining = total - bought;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Stats Purple Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.indigo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('quick_stats'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildPurpleStatRow(context.tr('total_items'), total.toString(), Colors.white),
              const SizedBox(height: 16),
              _buildPurpleStatRow('Bought', bought.toString(), AppTheme.emeraldLight),
              const SizedBox(height: 16),
              _buildPurpleStatRow('Remaining', remaining.toString(), AppTheme.amberLight),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Automation Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sync, color: AppTheme.indigo, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('automation'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Switch(
                      value: appState.autoAddToInventory,
                      onChanged: (v) => appState.setAutoAddToInventory(v),
                      activeColor: AppTheme.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('auto_add_desc'),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurpleStatRow(String title, String count, Color countColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Text(
          count,
          style: TextStyle(color: countColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    String category = 'GROCERIES';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shopping Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              items: ['GROCERIES', 'HOUSEHOLD', 'PHARMACY', 'OTHER'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (v) => category = v ?? 'OTHER',
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                appState.addShoppingItem(ShoppingItem(
                  name: nameController.text,
                  category: category,
                ));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
