import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final String? storeName;
  final DateTime date;

  Expense({
    String? id,
    required this.description,
    required this.amount,
    required this.category,
    this.storeName,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category,
    'storeName': storeName,
    'date': date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    description: json['description'],
    amount: (json['amount'] as num).toDouble(),
    category: json['category'],
    storeName: json['storeName'],
    date: DateTime.parse(json['date']),
  );

  Expense copyWith({
    String? description,
    double? amount,
    String? category,
    String? storeName,
    DateTime? date,
  }) => Expense(
    id: id,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    storeName: storeName ?? this.storeName,
    date: date ?? this.date,
  );
}

class ShoppingItem {
  final String id;
  final String name;
  final bool isBought;
  final String category;
  final double quantity;
  final String unit;
  final double price;
  final String? storeName;

  ShoppingItem({
    String? id,
    required this.name,
    this.isBought = false,
    required this.category,
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.price = 0.0,
    this.storeName,
  }) : id = id ?? const Uuid().v4();

  double get total => quantity * price;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isBought': isBought,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'price': price,
    'storeName': storeName,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'],
    name: json['name'],
    isBought: json['isBought'] ?? false,
    category: json['category'],
    quantity: (json['quantity'] ?? 1.0).toDouble(),
    unit: json['unit'] ?? 'pcs',
    price: (json['price'] ?? 0.0).toDouble(),
    storeName: json['storeName'],
  );

  ShoppingItem copyWith({
    String? name,
    bool? isBought,
    String? category,
    double? quantity,
    String? unit,
    double? price,
    String? storeName,
  }) => ShoppingItem(
    id: id,
    name: name ?? this.name,
    isBought: isBought ?? this.isBought,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    price: price ?? this.price,
    storeName: storeName ?? this.storeName,
  );
}

class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final bool isConsumed;

  InventoryItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.isConsumed = false,
  }) : id = id ?? const Uuid().v4();

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isExpiringSoon => expiryDate != null && 
      !isExpired && 
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 3)));

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'expiryDate': expiryDate?.toIso8601String(),
    'isConsumed': isConsumed,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'],
    name: json['name'],
    quantity: (json['quantity'] ?? 0.0).toDouble(),
    unit: json['unit'] ?? 'pcs',
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    isConsumed: json['isConsumed'] ?? false,
  );

  InventoryItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    bool? isConsumed,
  }) => InventoryItem(
    id: id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    expiryDate: expiryDate ?? this.expiryDate,
    isConsumed: isConsumed ?? this.isConsumed,
  );
}

class Store {
  final String id;
  final String name;
  final double credit;
  final double dailyQuota;
  final double weeklyQuota;
  final double monthlyQuota;

  Store({
    String? id,
    required this.name,
    required this.credit,
    this.dailyQuota = 50.0,
    this.weeklyQuota = 200.0,
    this.monthlyQuota = 500.0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'credit': credit,
    'dailyQuota': dailyQuota,
    'weeklyQuota': weeklyQuota,
    'monthlyQuota': monthlyQuota,
  };

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json['id'],
    name: json['name'],
    credit: (json['credit'] ?? 0.0).toDouble(),
    dailyQuota: (json['dailyQuota'] ?? 50.0).toDouble(),
    weeklyQuota: (json['weeklyQuota'] ?? 200.0).toDouble(),
    monthlyQuota: (json['monthlyQuota'] ?? 500.0).toDouble(),
  );

  Store copyWith({
    String? name,
    double? credit,
    double? dailyQuota,
    double? weeklyQuota,
    double? monthlyQuota,
  }) => Store(
    id: id,
    name: name ?? this.name,
    credit: credit ?? this.credit,
    dailyQuota: dailyQuota ?? this.dailyQuota,
    weeklyQuota: weeklyQuota ?? this.weeklyQuota,
    monthlyQuota: monthlyQuota ?? this.monthlyQuota,
  );
}
