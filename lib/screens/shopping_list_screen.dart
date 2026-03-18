import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    final shoppingList = appState.shoppingList;
    final inventory = appState.inventory;

    final manualToBuy = shoppingList.where((item) => !item.isBought).toList();
    final boughtItems = shoppingList.where((item) => item.isBought).toList();

    final suggestedItems = inventory.where((item) => item.isConsumed || item.isExpired).map((inv) {
      return ShoppingItem(
        id: 'suggested_${inv.id}',
        name: inv.name,
        category: 'RESTOCK',
        quantity: inv.quantity > 0 ? inv.quantity : 1.0,
        unit: inv.unit,
        isBought: false,
        price: 0.0,
      );
    }).toList();

    final deduplicatedSuggestions = suggestedItems.where((suggested) {
      return !manualToBuy.any((manual) => manual.name.toLowerCase() == suggested.name.toLowerCase());
    }).toList();

    final toBuyItems = [...manualToBuy, ...deduplicatedSuggestions];

    final filteredToBuy = _filterItems(toBuyItems, _searchQuery);
    final filteredBought = _filterItems(boughtItems, _searchQuery);

    final double totalToBuy = filteredToBuy.fold(0, (sum, item) => sum + item.total);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, appState),
        backgroundColor: AppTheme.amber,
        icon: const Icon(Icons.add),
        label: Text(context.tr('add_item')),
      ),
      body: SingleChildScrollView(
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
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildSearchBar(context),
                            const SizedBox(height: 24),
                            _buildSection(context, appState, context.tr('things_to_buy'), filteredToBuy, isToBuy: true, total: totalToBuy, showDesc: true),
                            const SizedBox(height: 32),
                            _buildSection(context, appState, context.tr('things_bought'), filteredBought, isToBuy: false),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildSidebarSections(context, appState, totalToBuy)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildSidebarSections(context, appState, totalToBuy),
                      const SizedBox(height: 24),
                      _buildSearchBar(context),
                      const SizedBox(height: 24),
                      _buildSection(context, appState, context.tr('things_to_buy'), filteredToBuy, isToBuy: true, total: totalToBuy, showDesc: true),
                      const SizedBox(height: 32),
                      _buildSection(context, appState, context.tr('things_bought'), filteredBought, isToBuy: false),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<ShoppingItem> _filterItems(List<ShoppingItem> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) => item.name.toLowerCase().contains(q) || item.category.toLowerCase().contains(q)).toList();
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
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
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: context.tr('search'),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, AppState appState, String title, List<ShoppingItem> items, {required bool isToBuy, double? total, bool showDesc = false}) {
    final currencyFormat = NumberFormat.simpleCurrency();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
                ),
                if (isToBuy) ...[
                   const SizedBox(width: 8),
                   IconButton(
                     onPressed: () => _showAddItemDialog(context, appState),
                     icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.amber),
                     padding: EdgeInsets.zero,
                     constraints: const BoxConstraints(),
                   ),
                ],
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isToBuy ? AppTheme.amber : AppTheme.emerald).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    items.length.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToBuy ? AppTheme.amber : AppTheme.emerald,
                    ),
                  ),
                ),
              ],
            ),
            if (isToBuy && total != null && total > 0)
              Text(
                'Total: ${currencyFormat.format(total)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
          ],
        ),
        if (showDesc) ...[
          const SizedBox(height: 4),
          Text(
            context.tr('pending_items_desc'),
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 16),
        if (isToBuy) ...[
          InkWell(
            onTap: () => _showAddItemDialog(context, appState),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border.withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 20, color: AppTheme.textSecondary),
                  const SizedBox(width: 12),
                  Text(context.tr('add_item'), style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
        if (items.isEmpty && !isToBuy)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border.withOpacity(0.5)),
            ),
            child: const Center(
              child: Text(
                'No items in this section',
                style: TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSuggested = item.id.startsWith('suggested_');
              return _buildShoppingItemCard(context, appState, item, isSuggested, isToBuy);
            },
          ),
      ],
    );
  }

  Widget _buildShoppingItemCard(BuildContext context, AppState appState, ShoppingItem item, bool isSuggested, bool isToBuy) {
    final currencyFormat = NumberFormat.simpleCurrency();
    
    if (isToBuy) {
      return Dismissible(
        key: Key(item.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: AppTheme.emerald.withOpacity(0.8),
          child: const Icon(Icons.check, color: Colors.white),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: AppTheme.rose.withOpacity(0.8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.edit, color: Colors.white),
              SizedBox(width: 16),
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
             _handleToggleBought(context, appState, item);
             return false;
          } else {
             final action = await showDialog<String>(
               context: context,
               builder: (context) => AlertDialog(
                 title: const Text('Actions'),
                 actions: [
                    TextButton(onPressed: () => Navigator.pop(context, 'edit'), child: Text(context.tr('edit'))),
                    TextButton(onPressed: () => Navigator.pop(context, 'delete'), child: Text(context.tr('delete'), style: const TextStyle(color: AppTheme.rose))),
                 ],
               ),
             );
             if (action == 'edit') {
               _showAddItemDialog(context, appState, existingItem: isSuggested ? null : item, initialName: isSuggested ? item.name : null);
               return false;
             } else if (action == 'delete') {
               final confirm = await showDialog<bool>(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: Text(context.tr('confirm_delete')),
                   content: Text(context.tr('sure_delete')),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('cancel'))),
                     TextButton(onPressed: () => Navigator.pop(context, true), child: Text(context.tr('delete'), style: const TextStyle(color: AppTheme.rose))),
                   ],
                 ),
               );
               return confirm ?? false;
             }
             return false;
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            if (!isSuggested) appState.deleteShoppingItem(item.id);
          }
        },
        child: _itemCard(context, appState, item, isSuggested, currencyFormat),
      );
    } else {
      return _itemCard(context, appState, item, isSuggested, currencyFormat);
    }
  }

  Widget _itemCard(BuildContext context, AppState appState, ShoppingItem item, bool isSuggested, NumberFormat currencyFormat) {
    return Card(
      elevation: 0,
      color: isSuggested ? AppTheme.roseLight.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSuggested ? AppTheme.rose.withOpacity(0.2) : AppTheme.border.withOpacity(0.5)),
      ),
      child: ListTile(
        onTap: () {
           if (isSuggested) {
             _showAddItemDialog(context, appState, initialName: item.name, initialQty: item.quantity, initialUnit: item.unit);
           } else {
             _showAddItemDialog(context, appState, existingItem: item);
           }
        },
        leading: Checkbox(
          value: item.isBought,
          activeColor: AppTheme.amber,
          onChanged: (_) {
            if (isSuggested) {
              final newItem = ShoppingItem(
                name: item.name,
                category: item.category,
                quantity: item.quantity,
                unit: item.unit,
                isBought: true,
                price: 0.0,
              );
              appState.addShoppingItem(newItem);
            } else {
              _handleToggleBought(context, appState, item);
            }
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  decoration: item.isBought ? TextDecoration.lineThrough : null,
                  color: item.isBought ? AppTheme.textSecondary : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSuggested)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.rose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('PENDING', style: TextStyle(fontSize: 9, color: AppTheme.rose, fontWeight: FontWeight.bold)),
              ),
            if (!item.id.startsWith('suggested_') && item.total > 0)
              Text(
                currencyFormat.format(item.total),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: item.isBought ? AppTheme.textSecondary : AppTheme.indigo,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(item.category, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.textSecondary, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
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
            Text(
              context.tr('shopping_list'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('shopping_desc'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleToggleBought(BuildContext context, AppState appState, ShoppingItem item) async {
    if (!item.isBought && appState.autoAddToInventory) {
      final DateTime? expiryDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: context.tr('set_expiry'),
      );
      appState.toggleShoppingItem(item.id, expiryDate: expiryDate);
    } else {
      appState.toggleShoppingItem(item.id);
    }
  }

  Widget _buildSidebarSections(BuildContext context, AppState appState, double totalToBuy) {
    final items = appState.shoppingList;
    final totalCount = items.length;
    final boughtCount = items.where((i) => i.isBought).length;
    final remainingCount = totalCount - boughtCount;
    final currencyFormat = NumberFormat.simpleCurrency();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.indigo, Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.indigo.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('estimated_total').toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(totalToBuy),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
              ),
              const SizedBox(height: 24),
              _buildPurpleStatRow(context.tr('things_to_buy'), remainingCount.toString(), Colors.white),
              const Divider(color: Colors.white24, height: 24),
              _buildPurpleStatRow(context.tr('things_bought'), boughtCount.toString(), Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 24),
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

  void _showAddItemDialog(BuildContext context, AppState appState, {ShoppingItem? existingItem, String? initialName, double? initialQty, String? initialUnit, bool forceBought = false}) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        appState: appState, 
        existingItem: existingItem,
        initialName: initialName,
        initialQty: initialQty,
        initialUnit: initialUnit,
        forceBought: forceBought,
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final AppState appState;
  final ShoppingItem? existingItem;
  final String? initialName;
  final double? initialQty;
  final String? initialUnit;
  final bool forceBought;

  const _AddItemDialog({required this.appState, this.existingItem, this.initialName, this.initialQty, this.initialUnit, this.forceBought = false});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late double _quantity;
  late String _unit;
  late String _category;
  String? _selectedStore;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingItem?.name ?? widget.initialName);
    _priceController = TextEditingController(text: widget.existingItem?.price.toString() ?? '0.0');
    _quantity = widget.existingItem?.quantity ?? widget.initialQty ?? 1.0;
    _unit = widget.existingItem?.unit ?? widget.initialUnit ?? 'pcs';
    _category = widget.existingItem?.category ?? 'GROCERIES';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingItem == null ? (widget.forceBought ? context.tr('mark_as_bought') : context.tr('add_item')) : context.tr('edit')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: context.tr('item_name')),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('quantity'), style: const TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _quantity = (_quantity - 0.5).clamp(0.5, 999.0)),
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.indigo),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity += 0.5),
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.indigo),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: context.tr('price_per_unit'), prefixText: '\$'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    items: ['kg', 'g', 'l', 'pcs', 'pack', 'box'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                    decoration: InputDecoration(labelText: context.tr('unit')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    items: ['GROCERIES', 'HOUSEHOLD', 'PHARMACY', 'OTHER'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                    onChanged: (v) => setState(() => _category = v ?? 'OTHER'),
                    decoration: InputDecoration(labelText: context.tr('category')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedStore,
              items: [
                DropdownMenuItem(value: null, child: Text(context.tr('no_store'))),
                ...widget.appState.stores.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))),
              ],
              onChanged: (v) => setState(() => _selectedStore = v),
              decoration: InputDecoration(labelText: context.tr('store_optional')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final price = double.tryParse(_priceController.text) ?? 0.0;
              final bool isBought = widget.forceBought || (widget.existingItem?.isBought ?? false);
              
              if (widget.existingItem == null) {
                widget.appState.addShoppingItem(ShoppingItem(
                  name: _nameController.text,
                  category: _category,
                  quantity: _quantity,
                  unit: _unit,
                  price: price,
                  isBought: isBought,
                ));
              } else {
                widget.appState.updateShoppingItem(ShoppingItem(
                  id: widget.existingItem!.id,
                  name: _nameController.text,
                  category: _category,
                  isBought: isBought,
                  quantity: _quantity,
                  unit: _unit,
                  price: price,
                ));
              }
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: widget.forceBought ? AppTheme.amber : AppTheme.indigo),
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}
