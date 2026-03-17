import 'package:flutter/material.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'QuamaaAi',
      'dashboard': 'Dashboard',
      'budget': 'Budget',
      'shopping_list': 'Shopping List',
      'inventory': 'Inventory',
      'stores': 'Stores',
      'statistics': 'Statistics',
      'settings': 'Settings',
      'logout': 'Logout',
      'welcome_back': 'Welcome back',
      'welcome_subtitle': 'Here\'s what\'s happening in your home today.',
      'remaining_budget': 'REMAINING BUDGET',
      'kitchen_alerts': 'KITCHEN ALERTS',
      'expiring_soon': 'Expiring Soon',
      'out_of_stock': 'Out of Stock',
      'total_store_credit': 'TOTAL STORE CREDIT',
      'across_stores': 'Across stores',
      'store_quotas': 'Store Quotas',
      'view_all': 'View All',
      'no_items_found': 'No items found',
      'monthly_quota': 'Monthly Quota',
      'add_item': '+ Add Item',
      'search': 'Search...',
      'quick_stats': 'quickStats',
      'total_items': 'Total Items',
      'low_stock': 'lowStock',
      'automation': 'Automation',
      'auto_add_desc': 'Auto-add to inventory on purchase',
      'monthly_income': 'MONTHLY INCOME',
      'total_spent': 'TOTAL SPENT',
      'remaining': 'REMAINING',
      'recent_transactions': 'Recent Transactions',
      'date': 'DATE',
      'description': 'DESCRIPTION',
      'category': 'CATEGORY',
      'amount': 'AMOUNT',
      'actions': 'ACTIONS',
      'other': 'OTHER',
      'edit_budget': 'Edit Budget',
      'add_expense': '+ Add Expense',
    },
    'ar': {
      'app_name': 'قاماي',
      'dashboard': 'لوحة القيادة',
      'budget': 'الميزانية',
      'shopping_list': 'قائمة التسوق',
      'inventory': 'المخزون',
      'stores': 'المتاجر',
      'statistics': 'الإحصائيات',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'welcome_back': 'مرحباً بعودتك',
      'welcome_subtitle': 'إليك ما يحدث في منزلك اليوم.',
      'remaining_budget': 'الميزانية المتبقية',
      'kitchen_alerts': 'تنبيهات المطبخ',
      'expiring_soon': 'ينتهي قريباً',
      'out_of_stock': 'نفذ من المخزون',
      'total_store_credit': 'إجمالي رصيد المتجر',
      'across_stores': 'عبر المتاجر',
      'store_quotas': 'حصص المتاجر',
      'view_all': 'عرض الكل',
      'no_items_found': 'لم يتم العثور على عناصر',
      'monthly_quota': 'الحصة الشهرية',
      'add_item': '+ إضافة عنصر',
      'search': 'بحث...',
      'quick_stats': 'إحصائيات سريعة',
      'total_items': 'إجمالي العناصر',
      'low_stock': 'مخزون منخفض',
      'automation': 'الأتمتة',
      'auto_add_desc': 'إضافة تلقائية للمخزون عند الشراء',
      'monthly_income': 'الدخل الشهري',
      'total_spent': 'إجمالي المنفق',
      'remaining': 'المتبقي',
      'recent_transactions': 'المعاملات الأخيرة',
      'date': 'التاريخ',
      'description': 'الوصف',
      'category': 'الفئة',
      'amount': 'المبلغ',
      'actions': 'الإجراءات',
      'other': 'أخرى',
      'edit_budget': 'تعديل الميزانية',
      'add_expense': '+ إضافة نفقات',
    }
  };

  static String translate(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final Map<String, String>? currentTranslations = _translations[locale] ?? _translations['en'];
    return currentTranslations?[key] ?? key;
  }
}

// Extension to make it easier to use: context.tr('key')
extension TranslationExtension on BuildContext {
  String tr(String key) => AppTranslations.translate(this, key);
}
