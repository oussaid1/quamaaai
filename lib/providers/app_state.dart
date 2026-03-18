import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  List<Expense> get expenses => _expenses;
  List<ShoppingItem> get shoppingList => _shoppingList;
  List<InventoryItem> get inventory => _inventory;
  List<Store> get stores => _stores;
  bool get autoAddToInventory => _autoAddToInventory;
  double get monthlyIncome => _monthlyIncome;
  User? get user => _user;

  AppState() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadRemoteState();
      } else {
        await _loadLocalState();
      }
      _checkAndSeedShafeiData();
      notifyListeners();
    });
  }

  void _checkAndSeedShafeiData() {
    const String shopName = "الشافعي";
    
    // Add Store if not exists
    if (!_stores.any((s) => s.name == shopName)) {
      _stores.add(Store(
        name: shopName,
        credit: 0.0,
        dailyQuota: 2000.0,
        weeklyQuota: 10000.0,
        monthlyQuota: 30000.0,
      ));
    }

    final List<Map<String, dynamic>> rawData = [
      {
        "Name": "تقاشر",
        "Quantity": 3.0,
        "Price": 200.0,
        "Date": 1768486362
      },
      {
        "Name": "بودي داخلي",
        "Quantity": 2.0,
        "Price": 800.0,
        "Date": 1768486373
      },
      {
        "Name": "سروال قندريسي",
        "Quantity": 2.0,
        "Price": 2400.0,
        "Date": 1768486345
      }
    ];

    for (var data in rawData) {
      final String name = data["Name"];
      final double qty = data["Quantity"];
      final double price = data["Price"];
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(data["Date"] * 1000);

      // Add to Expenses if not already there
      if (!_expenses.any((e) => e.description == name && e.storeName == shopName)) {
        _expenses.add(Expense(
          description: name,
          amount: qty * price,
          category: "SHOPPING",
          storeName: shopName,
          date: date,
        ));
      }

      // Add to Shopping List as bought if not there
      if (!_shoppingList.any((i) => i.name == name && i.storeName == shopName)) {
        _shoppingList.add(ShoppingItem(
          name: name,
          isBought: true,
          category: "CLOTHES",
          quantity: qty,
          unit: "pcs",
          price: price,
          storeName: shopName,
        ));
      }
    }
    
    _saveState();
  }

  // --- Auth ---

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // --- Persistence ---

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) _locale = Locale(languageCode);

    final String? themeStr = prefs.getString('themeMode');
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeStr, orElse: () => ThemeMode.system);
    }

    _autoAddToInventory = prefs.getBool('autoAddToInventory') ?? false;
    _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 5000.0;

    _expenses = _loadList(prefs, 'expenses', (m) => Expense.fromJson(m));
    _shoppingList = _loadList(prefs, 'shoppingList', (m) => ShoppingItem.fromJson(m));
    _inventory = _loadList(prefs, 'inventory', (m) => InventoryItem.fromJson(m));
    _stores = _loadList(prefs, 'stores', (m) => Store.fromJson(m));
  }

  Future<void> _loadRemoteState() async {
    if (_user == null) return;
    
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _autoAddToInventory = data['autoAddToInventory'] ?? false;
      _monthlyIncome = (data['monthlyIncome'] ?? 5000.0).toDouble();
      
      final List<dynamic> expJson = data['expenses'] ?? [];
      _expenses = expJson.map((item) => Expense.fromJson(item as Map<String, dynamic>)).toList();
      
      final List<dynamic> shopJson = data['shoppingList'] ?? [];
      _shoppingList = shopJson.map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>)).toList();
      
      final List<dynamic> invJson = data['inventory'] ?? [];
      _inventory = invJson.map((item) => InventoryItem.fromJson(item as Map<String, dynamic>)).toList();
      
      final List<dynamic> storeJson = data['stores'] ?? [];
      _stores = storeJson.map((item) => Store.fromJson(item as Map<String, dynamic>)).toList();
    }
    
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) _locale = Locale(languageCode);
    final String? themeStr = prefs.getString('themeMode');
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeStr, orElse: () => ThemeMode.system);
    }
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

  Future<void> _saveState() async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).set({
        'autoAddToInventory': _autoAddToInventory,
        'monthlyIncome': _monthlyIncome,
        'expenses': _expenses.map((e) => e.toJson()).toList(),
        'shoppingList': _shoppingList.map((i) => i.toJson()).toList(),
        'inventory': _inventory.map((i) => i.toJson()).toList(),
        'stores': _stores.map((s) => s.toJson()).toList(),
      }, SetOptions(merge: true));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoAddToInventory', _autoAddToInventory);
      await prefs.setDouble('monthlyIncome', _monthlyIncome);
      await prefs.setString('expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
      await prefs.setString('shoppingList', jsonEncode(_shoppingList.map((i) => i.toJson()).toList()));
      await prefs.setString('inventory', jsonEncode(_inventory.map((i) => i.toJson()).toList()));
      await prefs.setString('stores', jsonEncode(_stores.map((s) => s.toJson()).toList()));
    }
  }

  // --- Settings ---

  Future<void> setAutoAddToInventory(bool value) async {
    _autoAddToInventory = value;
    await _saveState();
    notifyListeners();
  }

  Future<void> setMonthlyIncome(double value) async {
    _monthlyIncome = value;
    await _saveState();
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
    _saveState();
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _saveState();
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _saveState();
    notifyListeners();
  }

  // --- CRUD: Shopping List ---

  void addShoppingItem(ShoppingItem item) {
    _shoppingList.add(item);
    _saveState();
    notifyListeners();
  }

  void updateShoppingItem(ShoppingItem item) {
    final index = _shoppingList.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shoppingList[index] = item;
      _saveState();
      notifyListeners();
    }
  }

  void toggleShoppingItem(String id, {DateTime? expiryDate, String? storeName}) {
    final index = _shoppingList.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _shoppingList[index];
      final newBoughtState = !item.isBought;
      
      _shoppingList[index] = item.copyWith(
        isBought: newBoughtState,
        storeName: storeName ?? item.storeName,
      );

      if (newBoughtState) {
        // Record as expense when bought
        addExpense(Expense(
          description: item.name,
          amount: item.total,
          category: item.category,
          storeName: storeName ?? item.storeName,
          date: DateTime.now(),
        ));

        if (_autoAddToInventory) {
          final invIndex = _inventory.indexWhere((inv) => inv.name.toLowerCase() == item.name.toLowerCase());
          if (invIndex != -1) {
            final invItem = _inventory[invIndex];
            _inventory[invIndex] = invItem.copyWith(
              quantity: invItem.quantity + item.quantity,
              expiryDate: expiryDate ?? invItem.expiryDate,
            );
          } else {
            _inventory.add(InventoryItem(
              name: item.name,
              quantity: item.quantity,
              unit: item.unit,
              expiryDate: expiryDate,
            ));
          }
        }
      }

      _saveState();
      notifyListeners();
    }
  }

  void deleteShoppingItem(String id) {
    _shoppingList.removeWhere((i) => i.id == id);
    _saveState();
    notifyListeners();
  }

  // --- CRUD: Inventory ---

  void addInventoryItem(InventoryItem item) {
    _inventory.add(item);
    _saveState();
    notifyListeners();
  }

  void updateInventoryItem(InventoryItem item) {
    final index = _inventory.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _inventory[index] = item;
      _saveState();
      notifyListeners();
    }
  }

  void toggleConsumed(String id) {
    final index = _inventory.indexWhere((i) => i.id == id);
    if (index != -1) {
      _inventory[index] = _inventory[index].copyWith(isConsumed: !_inventory[index].isConsumed);
      _saveState();
      notifyListeners();
    }
  }

  void deleteInventoryItem(String id) {
    _inventory.removeWhere((i) => i.id == id);
    _saveState();
    notifyListeners();
  }

  // --- CRUD: Stores ---

  void addStore(Store store) {
    _stores.add(store);
    _saveState();
    notifyListeners();
  }

  void updateStore(Store store) {
    final index = _stores.indexWhere((s) => s.id == store.id);
    if (index != -1) {
      _stores[index] = store;
      _saveState();
      notifyListeners();
    }
  }

  void deleteStore(String id) {
    _stores.removeWhere((s) => s.id == id);
    _saveState();
    notifyListeners();
  }

  // --- Export / Import ---

  String exportData() {
    final Map<String, dynamic> data = {
      'expenses': _expenses.map((e) => e.toJson()).toList(),
      'shoppingList': _shoppingList.map((i) => i.toJson()).toList(),
      'inventory': _inventory.map((i) => i.toJson()).toList(),
      'stores': _stores.map((s) => s.toJson()).toList(),
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
      
      await _saveState();
      notifyListeners();
    } catch (e) {
      debugPrint('Import error: $e');
    }
  }
}
