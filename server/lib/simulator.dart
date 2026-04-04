import 'dart:async';
import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// Market Simulator
//
// Simulates [stockCount] stocks using Geometric Brownian Motion (GBM):
//
//   ΔS = S · (μ·Δt + σ·√Δt · Z)
//
// where:
//   μ  = drift          (tiny upward bias, 0.00005 per tick)
//   σ  = volatility     (0.002 = 0.2% std-dev per tick)
//   Z  = N(0,1) via Box-Muller transform
//   Δt = 1 (one tick = one time unit)
//
// Every [_kTickMs] milliseconds, [_kChangedPerTick] randomly selected stocks
// get a new price. The rest keep their last value.
//
// On first WebSocket connection the full snapshot (all stocks) is returned
// via [getSnapshot()]. After that, only delta batches are broadcast.
// ─────────────────────────────────────────────────────────────────────────────

// ── Constants ─────────────────────────────────────────────────────────────────
const double _kDrift       = 0.00005;  // μ  — slight upward drift per tick
const double _kVolatility  = 0.002;    // σ  — 0.2% price std-dev per tick
const int    _kTickMs      = 100;      // broadcast interval in milliseconds
const int    _kChangedPerTick = 300;   // ~30% of 1000 stocks change each tick

// ── Stock state (mutable, internal only) ─────────────────────────────────────
class _Stock {
  _Stock({
    required this.symbol,
    required this.name,
    required double price,
  })  : price = price,
        previousPrice = price;

  final String symbol;
  final String name;
  double price;
  double previousPrice;
  double volume = 0;
}

// ── Market Simulator ──────────────────────────────────────────────────────────
class MarketSimulator {
  MarketSimulator({required this.stockCount}) {
    _initStocks();
    _startTicking();
  }

  final int stockCount;
  final _random = Random();
  final List<_Stock> _stocks = [];

  // Broadcast stream — emits a JSON-encodable batch on every tick.
  // Listeners receive List<Map<String, dynamic>> (delta — changed stocks only).
  late final StreamController<List<Map<String, dynamic>>> _ctrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get tickStream => _ctrl.stream;

  Timer? _timer;

  // ── Initial full snapshot ────────────────────────────────────────────────
  /// Returns ALL stocks at their current price.  Used to initialise new clients.
  List<Map<String, dynamic>> getSnapshot() =>
      _stocks.map(_stockToMap).toList();

  // ── Lifecycle ────────────────────────────────────────────────────────────
  void dispose() {
    _timer?.cancel();
    _ctrl.close();
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  void _initStocks() {
    for (var i = 0; i < stockCount; i++) {
      final symbol = _generateSymbol(i);
      final stock = _Stock(
        symbol: symbol,
        name: _generateName(symbol, i),
        price: 10.0 + _random.nextDouble() * 990.0, // SAR 10 – 1000
      )..volume = _randomVolume();
      _stocks.add(stock);
    }
  }

  void _startTicking() {
    _timer = Timer.periodic(
      const Duration(milliseconds: _kTickMs),
      (_) => _tick(),
    );
  }

  void _tick() {
    // Pick _kChangedPerTick random stocks to update this tick.
    final indices = List<int>.generate(stockCount, (i) => i)..shuffle(_random);
    final batch = <Map<String, dynamic>>[];

    for (final idx in indices.take(_kChangedPerTick)) {
      final stock = _stocks[idx];
      stock.previousPrice = stock.price;

      // Geometric Brownian Motion (Euler-Maruyama discretization)
      final z = _gaussian();
      stock.price = max(0.01, stock.price + stock.price * (_kDrift + _kVolatility * z));

      // Occasional volume spike (5% chance per updated stock)
      if (_random.nextDouble() < 0.05) stock.volume = _randomVolume();

      batch.add(_stockToMap(stock));
    }

    if (!_ctrl.isClosed) _ctrl.add(batch);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _stockToMap(_Stock s) {
    final change = s.price - s.previousPrice;
    final changePct = s.previousPrice > 0 ? (change / s.previousPrice) * 100 : 0.0;
    return {
      's':  s.symbol,                                           // symbol
      'n':  s.name,                                             // name
      'p':  double.parse(s.price.toStringAsFixed(2)),           // price
      'c':  double.parse(change.toStringAsFixed(3)),            // change
      'cp': double.parse(changePct.toStringAsFixed(3)),         // change %
      'v':  s.volume.toInt(),                                   // volume
      't':  DateTime.now().millisecondsSinceEpoch,              // timestamp ms
    };
  }

  /// Box-Muller transform → standard normal N(0,1).
  double _gaussian() {
    final u1 = max(1e-10, _random.nextDouble());
    final u2 = _random.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  double _randomVolume() => 50000 + _random.nextDouble() * 9950000;

  /// Generates a mix of 4-digit Saudi symbols (1010, 2222 …) and
  /// international letter codes (AAPL, MSFT …).
  String _generateSymbol(int index) {
    if (index % 3 == 0) return (1010 + index * 10).toString();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final len = 3 + (index % 2); // 3 or 4 chars
    final buf = StringBuffer();
    var n = index;
    for (var i = 0; i < len; i++) {
      buf.write(chars[n % chars.length]);
      n ~/= chars.length;
    }
    return buf.toString().padRight(len, 'A');
  }

  String _generateName(String symbol, int index) {
    const sectors = ['Capital', 'Holding', 'Industries', 'Trading', 'Energy',
      'Finance', 'Tech', 'Healthcare', 'Retail', 'Logistics'];
    return '$symbol ${sectors[index % sectors.length]}';
  }
}
