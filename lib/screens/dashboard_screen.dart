import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildSummaryCards(context, appState),
          const SizedBox(height: 32),
          _buildBottomSection(context, appState),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('welcome_back'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('welcome_subtitle'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, AppState appState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 800) {
          return Column(
            children: [
              _buildBudgetCard(context, appState),
              const SizedBox(height: 24),
              _buildAlertsCard(context, appState),
              const SizedBox(height: 24),
              _buildStoreCreditCard(context, appState),
            ],
          );
        }

        int crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 2.2,
          children: [
            _buildBudgetCard(context, appState),
            _buildAlertsCard(context, appState),
            _buildStoreCreditCard(context, appState),
          ],
        );
      },
    );
  }

  Widget _buildBudgetCard(BuildContext context, AppState appState) {
    final totalSpent = appState.expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final income = 5000.0;
    final remaining = income - totalSpent;
    final percentage = (totalSpent / income).clamp(0.0, 1.0);
    final currencyFormat = NumberFormat.simpleCurrency();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up, color: AppTheme.emerald),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('remaining_budget'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(remaining),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: remaining < 0 ? AppTheme.rose : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage, 
                    backgroundColor: AppTheme.border.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(percentage > 0.9 ? AppTheme.rose : AppTheme.emerald),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(percentage * 100).toStringAsFixed(1)}% spent of ${currencyFormat.format(income)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsCard(BuildContext context, AppState appState) {
    final outOfStockCount = appState.inventory.where((i) => i.quantity <= 0).length;
    final lowStockCount = appState.inventory.where((i) => i.quantity > 0 && i.quantity < 2).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.amberLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppTheme.amber),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('kitchen_alerts'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAlertRow('Low Stock', lowStockCount.toString(), AppTheme.amberLight, AppTheme.amber),
                const SizedBox(height: 8),
                _buildAlertRow(context.tr('out_of_stock'), outOfStockCount.toString(), AppTheme.roseLight, AppTheme.rose),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow(String title, String count, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: iconColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, 
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStoreCreditCard(BuildContext context, AppState appState) {
    final stores = appState.stores;
    final totalCredit = stores.fold<double>(0, (sum, s) => sum + s.credit);
    final currencyFormat = NumberFormat.simpleCurrency();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.indigoLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store_outlined, color: AppTheme.indigo),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('total_store_credit'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(totalCredit),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: totalCredit >= 0 ? AppTheme.emerald : AppTheme.rose,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${stores.length} ${context.tr('across_stores')}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, AppState appState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildShoppingListWidget(context, appState)),
              const SizedBox(width: 24),
              Expanded(child: _buildStoreQuotasWidget(context, appState)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildShoppingListWidget(context, appState),
              const SizedBox(height: 24),
              _buildStoreQuotasWidget(context, appState),
            ],
          );
        }
      },
    );
  }

  Widget _buildShoppingListWidget(BuildContext context, AppState appState) {
    final items = appState.shoppingList.where((i) => !i.isBought).take(5).toList();

    return Card(
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
                    const Icon(Icons.shopping_cart_outlined, color: AppTheme.amber),
                    const SizedBox(width: 8),
                    Text(context.tr('shopping_list'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextButton(
                  onPressed: () {}, // Handled by shell navigation usually
                  child: Text(context.tr('view_all'), style: const TextStyle(color: AppTheme.indigo)),
                ),
              ],
            ),
            const Divider(),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(context.tr('no_items_found'), style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                ),
              )
            else
              ...items.map((item) => CheckboxListTile(
                value: false,
                onChanged: (_) => appState.toggleShoppingItem(item.id),
                title: Text(item.name, style: const TextStyle(fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreQuotasWidget(BuildContext context, AppState appState) {
    final stores = appState.stores.take(3).toList();

    return Card(
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
                    const Icon(Icons.store_outlined, color: AppTheme.skyBlue),
                    const SizedBox(width: 8),
                    Text(context.tr('store_quotas'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(context.tr('view_all'), style: const TextStyle(color: AppTheme.indigo)),
                ),
              ],
            ),
            const Divider(),
            if (stores.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: Text('No store data.', style: TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic))),
              )
            else
              ...stores.map((store) {
                // Mocking quota as 500 for visualization
                final progress = (store.credit.abs() / 500.0).clamp(0.0, 1.0);
                return _buildQuotaItem(store.name, progress, store.credit);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaItem(String name, double progress, double credit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(credit >= 0 ? 'Credit: \$${credit.toStringAsFixed(2)}' : 'Debt: \$${credit.abs().toStringAsFixed(2)}', 
                   style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.border.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(credit >= 0 ? AppTheme.emerald : AppTheme.rose),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

