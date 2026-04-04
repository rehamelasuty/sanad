import '../../domain/entities/market_tick.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketTickModel  —  data-layer model
//
// Extends the domain entity only to add a JSON factory.
// The rest of the codebase works with [MarketTick] (pure domain).
//
// Server tick JSON format (compact keys to minimise payload size):
//   {
//     "s":  "AAPL",          // symbol
//     "n":  "AAPL Capital",  // name
//     "p":  189.50,          // price
//     "c":  0.45,            // absolute change
//     "cp": 0.238,           // percentage change
//     "v":  1250000,         // volume
//     "t":  1712345678900    // unix timestamp ms
//   }
// ─────────────────────────────────────────────────────────────────────────────

class MarketTickModel extends MarketTick {
  const MarketTickModel({
    required super.symbol,
    required super.name,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.volume,
    required super.timestamp,
  });

  factory MarketTickModel.fromMap(Map<String, dynamic> map) {
    return MarketTickModel(
      symbol:        map['s']  as String,
      name:          map['n']  as String,
      price:         (map['p']  as num).toDouble(),
      change:        (map['c']  as num).toDouble(),
      changePercent: (map['cp'] as num).toDouble(),
      volume:        (map['v']  as num).toInt(),
      timestamp:     DateTime.fromMillisecondsSinceEpoch(map['t'] as int),
    );
  }

  /// Convenience — parse a raw [Map] that came back from the parser isolate.
  static List<MarketTickModel> listFromMaps(List<Map<String, dynamic>> maps) =>
      maps.map(MarketTickModel.fromMap).toList();
}
