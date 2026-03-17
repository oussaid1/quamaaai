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
    amount: json['amount'],
    category: json['category'],
    storeName: json['storeName'],
    date: DateTime.parse(json['date']),
  );
}

class ShoppingItem {
  final String id;
  final String name;
  final bool isBought;
  final String category;

  ShoppingItem({
    String? id,
    required this.name,
    this.isBought = false,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isBought': isBought,
    'category': category,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'],
    name: json['name'],
    isBought: json['isBought'],
    category: json['category'],
  );
}

class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;

  InventoryItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.unit,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unit': unit,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'],
    name: json['name'],
    quantity: json['quantity'],
    unit: json['unit'],
  );
}

class Store {
  final String id;
  final String name;
  final double credit;

  Store({
    String? id,
    required this.name,
    required this.credit,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'credit': credit,
  };

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json['id'],
    name: json['name'],
    credit: json['credit'],
  );
}
