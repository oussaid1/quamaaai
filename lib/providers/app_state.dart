import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  
  List<Expense> _expenses = [];
  List<ShoppingItem> _shoppingList = [];
  List<InventoryItem> _inventory = [];
  List<Store> _stores = [];
  bool _autoAddToInventory = false;
  double _monthlyIncome = 5000.0;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  List<Expense> get expenses => _expenses;
  List<ShoppingItem> get shoppingList => _shoppingList;
  List<InventoryItem> get inventory => _inventory;
  List<Store> get stores => _stores;
  bool get autoAddToInventory => _autoAddToInventory;
  double get monthlyIncome => _monthlyIncome;

  AppState() {
    _loadState();
  }

  // --- Persistence ---

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Locale
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) _locale = Locale(languageCode);

    // Load ThemeMode
    final String? themeStr = prefs.getString('themeMode');
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeStr, orElse: () => ThemeMode.system);
    }

    _autoAddToInventory = prefs.getBool('autoAddToInventory') ?? false;
    _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 5000.0;

    // Load Data
    _expenses = _loadList(prefs, 'expenses', (m) => Expense.fromJson(m));
    _shoppingList = _loadList(prefs, 'shoppingList', (m) => ShoppingItem.fromJson(m));
    _inventory = _loadList(prefs, 'inventory', (m) => InventoryItem.fromJson(m));
    _stores = _loadList(prefs, 'stores', (m) => Store.fromJson(m));

    notifyListeners();
  }

  List<T> _loadList<T>(SharedPreferences prefs, String key, T Function(Map<String, dynamic>) fromJson) {
    final String? jsonStr = prefs.getString(key);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveState(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data is bool) {
      await prefs.setBool(key, data);
    } else if (data is double) {
      await prefs.setDouble(key, data);
    } else {
      await prefs.setString(key, jsonEncode(data));
    }
  }

  // --- Settings ---

  Future<void> setAutoAddToInventory(bool value) async {
    _autoAddToInventory = value;
    _saveState('autoAddToInventory', value);
    notifyListeners();
  }

  Future<void> setMonthlyIncome(double value) async {
    _monthlyIncome = value;
    _saveState('monthlyIncome', value);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    notifyListeners();
  }

  // --- CRUD: Expenses ---

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveState('expenses', _expenses);
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _saveState('expenses', _expenses);
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _saveState('expenses', _expenses);
    notifyListeners();
  }

  // --- CRUD: Shopping List ---

  void addShoppingItem(ShoppingItem item) {
    _shoppingList.add(item);
    _saveState('shoppingList', _shoppingList);
    notifyListeners();
  }

  void updateShoppingItem(ShoppingItem item) {
    final index = _shoppingList.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shoppingList[index] = item;
      _saveState('shoppingList', _shoppingList);
      notifyListeners();
    }
  }

  void toggleShoppingItem(String id) {
    final index = _shoppingList.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _shoppingList[index];
      final newBoughtState = !item.isBought;
      
      _shoppingList[index] = ShoppingItem(
        id: item.id,
        name: item.name,
        category: item.category,
        isBought: newBoughtState,
      );

      // Automation: Add to inventory if enabled and marked as bought
      if (_autoAddToInventory && newBoughtState) {
        final invIndex = _inventory.indexWhere((inv) => inv.name.toLowerCase() == item.name.toLowerCase());
        if (invIndex != -1) {
          final invItem = _inventory[invIndex];
          _inventory[invIndex] = InventoryItem(
            id: invItem.id,
            name: invItem.name,
            quantity: invItem.quantity + item.quantity,
            unit: invItem.unit, // Keep inventory unit
          );
        } else {
          _inventory.add(InventoryItem(
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
          ));
        }
        _saveState('inventory', _inventory);
      }

      _saveState('shoppingList', _shoppingList);
      notifyListeners();
    }
  }

  void deleteShoppingItem(String id) {
    _shoppingList.removeWhere((i) => i.id == id);
    _saveState('shoppingList', _shoppingList);
    notifyListeners();
  }

  // --- CRUD: Inventory ---

  void addInventoryItem(InventoryItem item) {
    _inventory.add(item);
    _saveState('inventory', _inventory);
    notifyListeners();
  }

  void updateInventoryItem(InventoryItem item) {
    final index = _inventory.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _inventory[index] = item;
      _saveState('inventory', _inventory);
      notifyListeners();
    }
  }

  void deleteInventoryItem(String id) {
    _inventory.removeWhere((i) => i.id == id);
    _saveState('inventory', _inventory);
    notifyListeners();
  }

  // --- CRUD: Stores ---

  void addStore(Store store) {
    _stores.add(store);
    _saveState('stores', _stores);
    notifyListeners();
  }

  void updateStore(Store store) {
    final index = _stores.indexWhere((s) => s.id == store.id);
    if (index != -1) {
      _stores[index] = store;
      _saveState('stores', _stores);
      notifyListeners();
    }
  }

  void deleteStore(String id) {
    _stores.removeWhere((s) => s.id == id);
    _saveState('stores', _stores);
    notifyListeners();
  }

  // --- Export / Import ---

  String exportData() {
    final Map<String, dynamic> data = {
      'expenses': _expenses,
      'shoppingList': _shoppingList,
      'inventory': _inventory,
      'stores': _stores,
      'monthlyIncome': _monthlyIncome,
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonStr) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (data.containsKey('expenses')) _expenses = (data['expenses'] as List).map((i) => Expense.fromJson(i)).toList();
      if (data.containsKey('shoppingList')) _shoppingList = (data['shoppingList'] as List).map((i) => ShoppingItem.fromJson(i)).toList();
      if (data.containsKey('inventory')) _inventory = (data['inventory'] as List).map((i) => InventoryItem.fromJson(i)).toList();
      if (data.containsKey('stores')) _stores = (data['stores'] as List).map((i) => Store.fromJson(i)).toList();
      if (data.containsKey('monthlyIncome')) _monthlyIncome = (data['monthlyIncome'] as num).toDouble();
      
      _saveState('expenses', _expenses);
      _saveState('shoppingList', _shoppingList);
      _saveState('inventory', _inventory);
      _saveState('stores', _stores);
      _saveState('monthlyIncome', _monthlyIncome);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Import error: $e');
    }
  }
}

