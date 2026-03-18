import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
                    childAspectRatio: 0.7, // Adjusted for more content including multiple quotas
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
              'Manage credits, debts, and spending quotas with your local stores.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddStoreDialog(context, appState),
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.tr('add_item')),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
        ),
      ],
    );
  }

  Widget _buildStoreCard(BuildContext context, AppState appState, Store store) {
    final currencyFormat = NumberFormat.simpleCurrency();
    final Color color = store.credit >= 0 ? AppTheme.emerald : AppTheme.rose;
    final String status = store.credit >= 0 
        ? '${currencyFormat.format(store.credit)} ${context.tr('credit')}' 
        : '${currencyFormat.format(store.credit.abs())} ${context.tr('debt')}';

    final storeExpenses = appState.expenses.where((e) => e.storeName == store.name).toList();
    
    // Calculate spent for different periods
    final now = DateTime.now();
    final todaySpent = storeExpenses.where((e) => e.amount > 0 && e.date.year == now.year && e.date.month == now.month && e.date.day == now.day).fold<double>(0, (sum, e) => sum + e.amount);
    
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklySpent = storeExpenses.where((e) => e.amount > 0 && e.date.isAfter(weekAgo)).fold<double>(0, (sum, e) => sum + e.amount);
    
    final monthlySpent = storeExpenses.where((e) => e.amount > 0 && e.date.year == now.year && e.date.month == now.month).fold<double>(0, (sum, e) => sum + e.amount);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showStoreDetailDialog(context, appState, store),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.store_outlined, color: color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppTheme.textSecondary),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(context.tr('edit')),
                        onTap: () => Future.delayed(Duration.zero, () => _showAddStoreDialog(context, appState, existingStore: store)),
                      ),
                      PopupMenuItem(
                        child: Text(context.tr('delete'), style: const TextStyle(color: AppTheme.rose)),
                        onTap: () => appState.deleteStore(store.id),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildQuotaProgress('Daily', todaySpent, store.dailyQuota, currencyFormat),
              const SizedBox(height: 12),
              _buildQuotaProgress('Weekly', weeklySpent, store.weeklyQuota, currencyFormat),
              const SizedBox(height: 12),
              _buildQuotaProgress('Monthly', monthlySpent, store.monthlyQuota, currencyFormat),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    status,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showPaymentDialog(context, appState, store),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Add Payment', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaProgress(String label, double spent, double quota, NumberFormat format) {
    final progress = (quota > 0 ? spent / quota : 0.0).clamp(0.0, 1.0);
    final color = progress > 0.9 ? AppTheme.rose : (progress > 0.7 ? AppTheme.amber : AppTheme.emerald);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            Text('${format.format(spent)} / ${format.format(quota)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  void _showStoreDetailDialog(BuildContext context, AppState appState, Store store) {
    final storeExpenses = appState.expenses.where((e) => e.storeName == store.name).toList();
    final currencyFormat = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat('MMM d, yyyy');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(store.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStoreStat(context, context.tr('credit'), currencyFormat.format(store.credit), store.credit >= 0 ? AppTheme.emerald : AppTheme.rose),
                  const SizedBox(width: 24),
                  _buildStoreStat(context, 'Total Transactions', storeExpenses.length.toString(), AppTheme.indigo),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Transactions History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Flexible(
                child: storeExpenses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('No transactions for this store.')),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: storeExpenses.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final expense = storeExpenses[index];
                          final isPayment = expense.amount < 0;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: (isPayment ? AppTheme.emerald : AppTheme.indigo).withOpacity(0.1),
                              child: Icon(isPayment ? Icons.payments_outlined : Icons.shopping_bag_outlined, 
                                          color: isPayment ? AppTheme.emerald : AppTheme.indigo, size: 18),
                            ),
                            title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(dateFormat.format(expense.date)),
                            trailing: Text(
                              (isPayment ? '+' : '') + currencyFormat.format(expense.amount.abs()),
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: isPayment ? AppTheme.emerald : AppTheme.textPrimary
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                       Navigator.pop(context);
                       _showPaymentDialog(context, appState, store);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emerald),
                    child: const Text('Add Payment'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, AppState appState, Store store) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment for ${store.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Credit/Debt: ${NumberFormat.simpleCurrency().format(store.credit)}', 
                 style: TextStyle(color: store.credit >= 0 ? AppTheme.emerald : AppTheme.rose, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                hintText: 'Enter amount paid',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            const Text('Recording a payment will increase your store credit (or decrease debt).', 
                       style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                appState.updateStore(store.copyWith(credit: store.credit + amount));
                appState.addExpense(Expense(
                  description: 'Payment to ${store.name}',
                  amount: -amount,
                  category: 'OTHER',
                  storeName: store.name,
                  date: DateTime.now(),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStat(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context, AppState appState, {Store? existingStore}) {
    final nameController = TextEditingController(text: existingStore?.name);
    final creditController = TextEditingController(text: existingStore?.credit.toString() ?? '0.0');
    final dailyQuotaController = TextEditingController(text: existingStore?.dailyQuota.toString() ?? '50.0');
    final weeklyQuotaController = TextEditingController(text: existingStore?.weeklyQuota.toString() ?? '200.0');
    final monthlyQuotaController = TextEditingController(text: existingStore?.monthlyQuota.toString() ?? '500.0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingStore == null ? context.tr('add_item') : context.tr('edit')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: context.tr('name'))),
              TextField(
                controller: creditController,
                decoration: InputDecoration(labelText: '${context.tr('credit')} (use - for debt)'),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              ),
              const SizedBox(height: 16),
              const Text('Spending Quotas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              TextField(
                controller: dailyQuotaController,
                decoration: const InputDecoration(labelText: 'Daily Quota'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: weeklyQuotaController,
                decoration: const InputDecoration(labelText: 'Weekly Quota'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: monthlyQuotaController,
                decoration: const InputDecoration(labelText: 'Monthly Quota'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final credit = double.tryParse(creditController.text) ?? 0.0;
              final dq = double.tryParse(dailyQuotaController.text) ?? 50.0;
              final wq = double.tryParse(weeklyQuotaController.text) ?? 200.0;
              final mq = double.tryParse(monthlyQuotaController.text) ?? 500.0;
              
              if (nameController.text.isNotEmpty) {
                if (existingStore == null) {
                  appState.addStore(Store(name: nameController.text, credit: credit, dailyQuota: dq, weeklyQuota: wq, monthlyQuota: mq));
                } else {
                  appState.updateStore(Store(id: existingStore.id, name: nameController.text, credit: credit, dailyQuota: dq, weeklyQuota: wq, monthlyQuota: mq));
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }
}
