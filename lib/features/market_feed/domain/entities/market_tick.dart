import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketTick  —  domain entity
//
// Represents a single price-update event for one stock symbol.
// This is a pure domain object: no JSON, no framework dependencies.
// ─────────────────────────────────────────────────────────────────────────────

enum TickDirection {
  up,    // price rose  (change > 0)
  down,  // price fell  (change < 0)
  flat,  // no change   (change == 0)
}

class MarketTick extends Equatable {
  const MarketTick({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.timestamp,
  });

  final String   symbol;        // e.g. "AAPL", "2222"
  final String   name;          // e.g. "AAPL Capital"
  final double   price;         // current market price (SAR)
  final double   change;        // absolute change from last tick
  final double   changePercent; // percentage change from last tick
  final int      volume;        // traded volume
  final DateTime timestamp;     // server-side timestamp of this tick

  /// Derived direction — computed from [change].
  TickDirection get direction {
    if (change > 0) return TickDirection.up;
    if (change < 0) return TickDirection.down;
    return TickDirection.flat;
  }

  @override
  List<Object?> get props => [
    symbol, name, price, change, changePercent, volume, timestamp,
  ];
}
