import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allExpenses = appState.expenses;
    final filteredExpenses = allExpenses.where((e) {
      final query = _searchQuery.toLowerCase();
      return e.description.toLowerCase().contains(query) || 
             e.category.toLowerCase().contains(query) ||
             (e.storeName?.toLowerCase().contains(query) ?? false);
    }).toList();

    final totalSpent = allExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final monthlyIncome = appState.monthlyIncome;
    final remaining = monthlyIncome - totalSpent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionHeader(context, appState),
          const SizedBox(height: 24),
          _buildSummaryCards(context, monthlyIncome, totalSpent, remaining),
          const SizedBox(height: 32),
          _buildTransactionsSection(context, appState, filteredExpenses),
        ],
      ),
    );
  }

  Widget _buildActionHeader(BuildContext context, AppState appState) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => _showEditIncomeDialog(context, appState),
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.indigo),
          label: Text(context.tr('edit_budget'), style: const TextStyle(color: AppTheme.textPrimary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showAddExpenseDialog(context, appState),
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.tr('add_expense')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.rose,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, double income, double spent, double remaining) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);
    return Column(
      children: [
        _buildStatCard(context, context.tr('monthly_income').toUpperCase(), currencyFormat.format(income), AppTheme.textPrimary),
        const SizedBox(height: 16),
        _buildStatCard(context, context.tr('total_spent').toUpperCase(), currencyFormat.format(spent), AppTheme.rose),
        const SizedBox(height: 16),
        _buildStatCard(context, context.tr('remaining').toUpperCase(), currencyFormat.format(remaining), AppTheme.emerald),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String amount, Color amountColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, AppState appState, List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('recent_transactions'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: context.tr('search'),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_alt_outlined, size: 20, color: AppTheme.textSecondary),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: Text(context.tr('no_transactions'), style: const TextStyle(color: AppTheme.textSecondary))),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final e = expenses[index];
              return _buildTransactionCard(context, appState, e);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, AppState appState, Expense expense) {
    final currencyFormat = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.indigoLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.indigo, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${dateFormat.format(expense.date)} • ${expense.category}', 
                     style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            currencyFormat.format(expense.amount),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
             icon: const Icon(Icons.more_vert, size: 20, color: AppTheme.textSecondary),
             itemBuilder: (context) => [
               PopupMenuItem(child: Text(context.tr('edit')), onTap: () => Future.delayed(Duration.zero, () => _showAddExpenseDialog(context, appState, existingExpense: expense))),
               PopupMenuItem(child: Text(context.tr('delete'), style: const TextStyle(color: AppTheme.rose)), onTap: () => Future.delayed(Duration.zero, () => _showDeleteConfirmation(context, appState, expense))),
             ],
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, AppState appState, {Expense? existingExpense}) {
    final descController = TextEditingController(text: existingExpense?.description);
    final amountController = TextEditingController(text: existingExpense?.amount.toString());
    String category = existingExpense?.category ?? 'OTHER';
    String? storeName = existingExpense?.storeName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingExpense == null ? context.tr('add_expense') : context.tr('edit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descController, decoration: InputDecoration(labelText: context.tr('description'))),
            TextField(controller: amountController, decoration: InputDecoration(labelText: context.tr('amount')), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              items: ['FOOD', 'SHOPPING', 'BILLS', 'OTHER'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (v) => category = v ?? 'OTHER',
              decoration: InputDecoration(labelText: context.tr('category')),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: storeName,
              items: [
                const DropdownMenuItem(value: null, child: Text('No Store')),
                ...appState.stores.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
              ],
              onChanged: (v) => storeName = v,
              decoration: InputDecoration(labelText: context.tr('stores')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (descController.text.isNotEmpty && amount > 0) {
                if (existingExpense == null) {
                  appState.addExpense(Expense(
                    description: descController.text,
                    amount: amount,
                    category: category,
                    storeName: storeName,
                    date: DateTime.now(),
                  ));
                } else {
                  appState.updateExpense(Expense(
                    id: existingExpense.id,
                    description: descController.text,
                    amount: amount,
                    category: category,
                    storeName: storeName,
                    date: existingExpense.date,
                  ));
                }
              }
              Navigator.pop(context);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppState appState, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('delete')),
        content: Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              appState.deleteExpense(expense.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }
  void _showEditIncomeDialog(BuildContext context, AppState appState) {
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
