import 'package:equatable/equatable.dart';

enum DepositMethodType { bankTransfer, madaCard, applePay, stcPay }

class DepositMethod extends Equatable {
  const DepositMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.subtitle,
    this.isFast = true,
    this.feeLabel = 'بدون رسوم',
  });

  final String id;
  final String name;
  final DepositMethodType type;
  final String subtitle;
  final bool isFast;
  final String feeLabel;

  String get iconEmoji {
    switch (type) {
      case DepositMethodType.bankTransfer:
        return '🏦';
      case DepositMethodType.madaCard:
        return '💳';
      case DepositMethodType.applePay:
        return '🍎';
      case DepositMethodType.stcPay:
        return '📱';
    }
  }

  @override
  List<Object?> get props => [id, type];
}
