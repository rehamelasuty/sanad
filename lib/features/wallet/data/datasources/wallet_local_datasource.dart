import '../../domain/entities/deposit_method.dart';

class WalletLocalDataSource {
  List<DepositMethod> getDepositMethods() {
    return const [
      DepositMethod(
        id: 'METH-001',
        name: 'تحويل بنكي (آيبان)',
        type: DepositMethodType.bankTransfer,
        subtitle: 'بنك العربي الوطني — SA44 ****1234',
        isFast: false,
        feeLabel: 'بدون رسوم',
      ),
      DepositMethod(
        id: 'METH-002',
        name: 'بطاقة مدى',
        type: DepositMethodType.madaCard,
        subtitle: 'فوري — بدون حد أدنى',
        isFast: true,
        feeLabel: 'بدون رسوم',
      ),
      DepositMethod(
        id: 'METH-003',
        name: 'Apple Pay',
        type: DepositMethodType.applePay,
        subtitle: 'فوري — حتى SAR 10,000',
        isFast: true,
        feeLabel: 'بدون رسوم',
      ),
      DepositMethod(
        id: 'METH-004',
        name: 'STC Pay',
        type: DepositMethodType.stcPay,
        subtitle: 'فوري — حتى SAR 5,000',
        isFast: true,
        feeLabel: 'بدون رسوم',
      ),
    ];
  }
}
