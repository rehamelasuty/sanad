import '../../domain/entities/ipo_listing.dart';

class IpoLocalDataSource {
  List<IpoListing> getIpoListings() {
    final now = DateTime.now();
    return [
      IpoListing(
        id: 'IPO-001',
        symbol: 'SRCO',
        name: 'شركة سرco للتقنية',
        sector: 'تقنية المعلومات',
        offeringPrice: 32.00,
        minShares: 10,
        status: IpoStatus.current,
        subscriptionRate: 2.84,
        closingDate: now.add(const Duration(days: 3)),
        allocationDate: now.add(const Duration(days: 7)),
        isShariaCompliant: true,
      ),
      IpoListing(
        id: 'IPO-002',
        symbol: 'TECO',
        name: 'شركة تيكو للطاقة المتجددة',
        sector: 'الطاقة',
        offeringPrice: 18.50,
        minShares: 50,
        status: IpoStatus.upcoming,
        subscriptionRate: 0.0,
        closingDate: now.add(const Duration(days: 14)),
        allocationDate: now.add(const Duration(days: 21)),
        isShariaCompliant: true,
      ),
      IpoListing(
        id: 'IPO-003',
        symbol: 'HLTH',
        name: 'مجموعة هيلث للرعاية الصحية',
        sector: 'الرعاية الصحية',
        offeringPrice: 45.00,
        minShares: 5,
        status: IpoStatus.closed,
        subscriptionRate: 1.95,
        closingDate: now.subtract(const Duration(days: 10)),
        allocationDate: now.subtract(const Duration(days: 5)),
        isShariaCompliant: false,
      ),
    ];
  }
}
