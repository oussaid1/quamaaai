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
          _buildHeader(context, appState),
          const SizedBox(height: 32),
          _buildSummaryCards(context, monthlyIncome, totalSpent, remaining),
          const SizedBox(height: 32),
          _buildTransactionsList(context, appState, filteredExpenses),
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
            Text(
              context.tr('budget'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your household budget, shopping lists, and kitchen inventory in one place.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showEditIncomeDialog(context, appState),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(context.tr('edit_budget')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddExpenseDialog(context, appState),
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.tr('add_expense')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.rose,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, double income, double spent, double remaining) {
    final currencyFormat = NumberFormat.simpleCurrency();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildStatCard(context, context.tr('monthly_income'), currencyFormat.format(income), AppTheme.textPrimary),
              const SizedBox(height: 16),
              _buildStatCard(context, context.tr('total_spent'), currencyFormat.format(spent), AppTheme.rose),
              const SizedBox(height: 16),
              _buildStatCard(context, context.tr('remaining'), currencyFormat.format(remaining), remaining < 0 ? AppTheme.rose : AppTheme.emerald),
            ],
          );
        }

        int crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3.5,
          children: [
            _buildStatCard(context, context.tr('monthly_income'), currencyFormat.format(income), AppTheme.textPrimary),
            _buildStatCard(context, context.tr('total_spent'), currencyFormat.format(spent), AppTheme.rose),
            _buildStatCard(context, context.tr('remaining'), currencyFormat.format(remaining), remaining < 0 ? AppTheme.rose : AppTheme.emerald),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String amount, Color amountColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, AppState appState, List<Expense> expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Text(
                  context.tr('recent_transactions'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: context.tr('search'),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.border),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_alt_outlined, size: 20, color: AppTheme.textSecondary),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Table Header and Body
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: _headerStyle(),
                dataTextStyle: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                columnSpacing: 32,
                columns: [
                  DataColumn(label: Text(context.tr('date'))),
                  DataColumn(label: Text(context.tr('description'))),
                  DataColumn(label: Text(context.tr('category'))),
                  const DataColumn(label: Text('STORE')),
                  DataColumn(label: Text(context.tr('amount'))),
                  const DataColumn(label: Text('')),
                ],
                rows: expenses.map((e) => _buildDataRow(context, appState, e)).toList(),
              ),
            ),
            if (expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: Text('No transactions yet.', style: TextStyle(color: AppTheme.textSecondary))),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: AppTheme.textSecondary,
      letterSpacing: 1.2,
    );
  }

  DataRow _buildDataRow(BuildContext context, AppState appState, Expense expense) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.simpleCurrency();

    return DataRow(
      cells: [
        DataCell(Text(dateFormat.format(expense.date), style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.normal))),
        DataCell(Text(expense.description)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.indigoLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              expense.category,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
          ),
        ),
        DataCell(Text(expense.storeName ?? '-', style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(Text(currencyFormat.format(expense.amount), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.rose, size: 20),
            onPressed: () => _showDeleteConfirmation(context, appState, expense),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseDialog(BuildContext context, AppState appState) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'OTHER';
    String? storeName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              items: ['FOOD', 'SHOPPING', 'BILLS', 'OTHER'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (v) => category = v ?? 'OTHER',
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: storeName,
              items: appState.stores.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
              onChanged: (v) => storeName = v,
              decoration: const InputDecoration(labelText: 'Store (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (descController.text.isNotEmpty && amount > 0) {
                appState.addExpense(Expense(
                  description: descController.text,
                  amount: amount,
                  category: category,
                  storeName: storeName,
                  date: DateTime.now(),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppState appState, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appState.deleteExpense(expense.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
            child: const Text('Delete'),
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

