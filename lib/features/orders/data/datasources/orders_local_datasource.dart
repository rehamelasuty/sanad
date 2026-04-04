import '../../../trade/domain/entities/order.dart';

class OrdersLocalDataSource {
  List<Order> getOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: 'ORD-001',
        symbol: 'AAPL',
        side: OrderSide.buy,
        type: OrderType.market,
        status: OrderStatus.filled,
        quantity: 10,
        limitPrice: 189.50,
        createdAt: now.subtract(const Duration(hours: 2)),
        filledPrice: 189.50,
        filledAt: now.subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'ORD-002',
        symbol: '2222',
        side: OrderSide.buy,
        type: OrderType.limit,
        status: OrderStatus.pending,
        quantity: 50,
        limitPrice: 29.85,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Order(
        id: 'ORD-003',
        symbol: 'MSFT',
        side: OrderSide.sell,
        type: OrderType.market,
        status: OrderStatus.cancelled,
        quantity: 8,
        limitPrice: 207.60,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'ORD-004',
        symbol: 'NVDA',
        side: OrderSide.buy,
        type: OrderType.limit,
        status: OrderStatus.filled,
        quantity: 5,
        limitPrice: 175.20,
        createdAt: now.subtract(const Duration(days: 2)),
        filledPrice: 174.80,
        filledAt: now.subtract(const Duration(days: 2)),
      ),
      Order(
        id: 'ORD-005',
        symbol: 'VOO',
        side: OrderSide.buy,
        type: OrderType.market,
        status: OrderStatus.filled,
        quantity: 3,
        limitPrice: 145.80,
        createdAt: now.subtract(const Duration(days: 3)),
        filledPrice: 145.80,
        filledAt: now.subtract(const Duration(days: 3)),
      ),
      Order(
        id: 'ORD-006',
        symbol: 'AAPL',
        side: OrderSide.sell,
        type: OrderType.limit,
        status: OrderStatus.filled,
        quantity: 4,
        limitPrice: 93.70,
        createdAt: now.subtract(const Duration(days: 5)),
        filledPrice: 93.70,
        filledAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}
