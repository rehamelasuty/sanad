import 'package:equatable/equatable.dart';

enum TransactionType { buy, sell, deposit, withdraw, murabaha }

class TransactionItem extends Equatable {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.isCredit = true,
    this.status = 'مكتمل',
  });

  final String id;
  final String title;
  final String subtitle;
  final TransactionType type;
  final double amount; // always positive; use isCredit for direction
  final DateTime createdAt;
  final bool isCredit;
  final String status;

  String get iconEmoji {
    switch (type) {
      case TransactionType.buy:
        return '📈';
      case TransactionType.sell:
        return '📉';
      case TransactionType.deposit:
        return '💳';
      case TransactionType.withdraw:
        return '🏧';
      case TransactionType.murabaha:
        return '💰';
    }
  }

  @override
  List<Object?> get props => [id, title, type, amount, createdAt];
}
