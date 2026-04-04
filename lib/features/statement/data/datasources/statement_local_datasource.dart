import '../../domain/entities/transaction_item.dart';

class StatementLocalDataSource {
  List<TransactionItem> getTransactions() {
    final now = DateTime.now();
    return [
      TransactionItem(
        id: 'TXN-001',
        title: 'شراء AAPL',
        subtitle: '10 وحدة × \$189.50',
        type: TransactionType.buy,
        amount: 1895.00,
        createdAt: now.subtract(const Duration(hours: 2)),
        isCredit: false,
        status: 'مكتمل',
      ),
      TransactionItem(
        id: 'TXN-002',
        title: 'عائد مرابحة',
        subtitle: 'مرابحة التقنية — الشهر الثالث',
        type: TransactionType.murabaha,
        amount: 1240.00,
        createdAt: now.subtract(const Duration(days: 1)),
        isCredit: true,
        status: 'مكتمل',
      ),
      TransactionItem(
        id: 'TXN-003',
        title: 'إيداع بنكي',
        subtitle: 'بنك العربي الوطني — IBAN',
        type: TransactionType.deposit,
        amount: 5000.00,
        createdAt: now.subtract(const Duration(days: 2)),
        isCredit: true,
        status: 'مكتمل',
      ),
      TransactionItem(
        id: 'TXN-004',
        title: 'بيع MSFT',
        subtitle: '8 وحدة × \$207.60',
        type: TransactionType.sell,
        amount: 1660.80,
        createdAt: now.subtract(const Duration(days: 5)),
        isCredit: true,
        status: 'مكتمل',
      ),
      TransactionItem(
        id: 'TXN-005',
        title: 'شراء VOO',
        subtitle: '3 وحدة × \$145.80',
        type: TransactionType.buy,
        amount: 437.40,
        createdAt: now.subtract(const Duration(days: 8)),
        isCredit: false,
        status: 'مكتمل',
      ),
      TransactionItem(
        id: 'TXN-006',
        title: 'سحب',
        subtitle: 'تحويل إلى الحساب البنكي',
        type: TransactionType.withdraw,
        amount: 2000.00,
        createdAt: now.subtract(const Duration(days: 12)),
        isCredit: false,
        status: 'مكتمل',
      ),
    ];
  }
}
