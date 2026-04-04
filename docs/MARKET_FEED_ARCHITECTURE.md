# Market Feed Architecture

Real-time market data pipeline — from simulated WebSocket server to pixel.

---

## Table of Contents

1. [Why the App Freezes (the problem)](#why-the-app-freezes)
2. [Architecture Overview](#architecture-overview)
3. [Server: Geometric Brownian Motion Simulator](#server)
4. [Data Layer: Buffer + Persistent Isolate](#data-layer)
5. [Presentation Layer: BlocSelector](#presentation-layer)
6. [Performance Comparison](#performance-comparison)
7. [Running the Server](#running-the-server)
8. [File Map](#file-map)

---

## Why the App Freezes

When the market opens, prices update simultaneously for thousands of stocks.
A naive implementation receives every WebSocket message and immediately:

1. **Parses JSON on the main thread** — `jsonDecode` is CPU-bound.  
   A 300-stock batch (~25 KB) takes **3–8 ms** on a mid-range phone.
   At 10 messages/second that's **80 ms** of pure main-thread blocking → jank.

2. **Emits a Bloc state per message** — every emit triggers `BlocBuilder`,
   which diffs and rebuilds the entire list widget tree.

3. **No deduplication** — if the server sends the same symbol twice in 50 ms
   both messages cause separate rebuild cycles.

**The fix has three parts:**

| Problem | Solution |
|---|---|
| JSON parsing blocks main thread | Persistent background Isolate |
| Too many state emits | Buffer + 100 ms flush timer |
| Whole list rebuilds | BlocSelector per tile |

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│  SERVER  (separate Dart process)                                     │
│                                                                      │
│  MarketSimulator                                                     │
│   1 000 stocks, GBM, Δt=100 ms                                      │
│   ──────────────►  WebSocket :8080                                  │
│   first msg = full snapshot (1 000 stocks)                          │
│   every 100 ms = delta batch (~300 stocks)                          │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  WebSocket (JSON)
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│  DATA LAYER  (Flutter app)                                           │
│                                                                      │
│  MarketWebSocketDatasource                                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  WS stream                                                    │   │
│  │   ──► TickParserWorker (background Isolate)                  │   │
│  │         ──► Map<symbol, tick> buffer                         │   │
│  │               ──► Timer.flush() every 100 ms                 │   │
│  │                     ──► Stream<List<MarketTickModel>>        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  MarketFeedRepositoryImpl                                            │
│   • wraps datasource in TaskEither for error handling               │
│   • upcasts MarketTickModel → MarketTick                            │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  Stream<List<MarketTick>>  (≤10 Hz)
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                  │
│                                                                      │
│  MarketFeedCubit                                                     │
│   • merges batch into Map<symbol, tick>  (O(batch_size), fast)      │
│   • emits MarketFeedConnected with incremented _version             │
│   • Timer.periodic(1s) → updatesPerSecond                           │
│                                                                      │
│  MarketFeedScreen                                                    │
│   • BlocBuilder (buildWhen: symbols changed) → ListView             │
│     Each item:                                                       │
│      StockTickTile(symbol)                                           │
│       └─ BlocSelector → state.tickMap[symbol]                       │
│           └─ rebuilds ONLY when this symbol's price changes         │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Server

### File: `server/bin/server.dart`

Dart shelf WebSocket server on port **8080**.

- On new client connect → send **full snapshot** (1 000 stocks as JSON array)
- Every 100 ms → broadcast **delta batch** (~300 stocks that changed)
- Dead connections silently removed from the `Set<WebSocketChannel>`

### File: `server/lib/simulator.dart`

Simulates 1 000 stocks using **Geometric Brownian Motion (GBM)**.

#### GBM Formula

$$
S(t + \Delta t) = S(t) + S(t)\left(\mu \cdot \Delta t + \sigma \sqrt{\Delta t} \cdot Z\right)
$$

Where:

- $S$ — stock price
- $\mu = 0.00005$ — drift (small positive bias, like a rising market)
- $\sigma = 0.002$ — volatility
- $\Delta t = 1$ (one tick)
- $Z \sim \mathcal{N}(0, 1)$ — standard normal random variable

#### Box-Muller Transform

The server generates Gaussian random numbers from uniform `Random`:

```dart
double _gaussian() {
  final u1 = _rng.nextDouble();
  final u2 = _rng.nextDouble();
  return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
}
```

#### Compact JSON Keys

To reduce network payload, the server uses single-character keys:

| Key | Meaning |
|-----|---------|
| `s` | symbol |
| `n` | name |
| `p` | price |
| `c` | change (absolute) |
| `cp` | changePercent |
| `v` | volume |
| `t` | timestamp (milliseconds) |

---

## Data Layer

### `TickParserWorker` — Persistent Background Isolate

**Why not `compute()`?**

`compute()` spawns a **new Isolate per call**. Isolate spawn costs 5–15 ms.
At 10 messages/second that's 50–150 ms of overhead per second, eating into
the frame budget. A persistent Isolate is spawned once and reused:

```
compute() approach (bad):
  msg 1 → spawn isolate (12ms) → parse (2ms) → kill isolate
  msg 2 → spawn isolate (12ms) → parse (2ms) → kill isolate
  ...

Persistent Isolate (good):
  init → spawn isolate (12ms, once)
  msg 1 → send to port (0.01ms) → parse (2ms)
  msg 2 → send to port (0.01ms) → parse (2ms)
  ...
```

**Two-ReceivePort Handshake Pattern:**

```dart
// Main isolate creates two ports:
//   handshakePort — to receive the worker's SendPort
//   resultsPort   — to receive parsed tick batches

final handshakePort = ReceivePort();
final resultsPort   = ReceivePort();

await Isolate.spawn(
  _tickParserEntryPoint,
  [handshakePort.sendPort, resultsPort.sendPort],
);

// Worker sends its own SendPort back via handshakePort:
_workerSendPort = await handshakePort.first as SendPort;
```

This avoids using `Isolate.exit()` (which kills the isolate after one use)
and enables a long-lived bidirectional channel.

### `MarketWebSocketDatasource` — Buffer + Flush

**Why buffer?**

The server broadcasts to all clients simultaneously. Network jitter can cause
two messages to arrive within a few milliseconds. Without a buffer, both
would trigger separate state emits and rebuilds.

With a `Map<String, tick>` buffer:

```
t=0ms   WS msg arrives → { AAPL: 182.5, MSFT: 391.2, ... 300 stocks }
t=0ms   Buffer: { AAPL: 182.5, MSFT: 391.2, ... }

t=80ms  WS msg arrives → { AAPL: 182.7, GOOG: 140.1, ... 300 stocks }
t=80ms  Buffer: { AAPL: 182.7, MSFT: 391.2, GOOG: 140.1, ... }
         (AAPL deduplicated — only latest kept)

t=100ms Timer fires → flush buffer → emit List of ~600 unique stocks
t=100ms Buffer cleared
```

Result: **at most 10 state emits per second**, regardless of network burst.

**Reconnect with Truncated Exponential Backoff:**

```
attempt 1 → wait 2s
attempt 2 → wait 4s
attempt 3 → wait 8s
attempt 4 → wait 16s
attempt 5 → wait 30s (capped)
attempt 6 → emit FeedConnectionStatus.failed
```

---

## Presentation Layer

### `MarketFeedConnected` — Version-Based Equality

State equality is intentionally **NOT** value-based for `MarketFeedConnected`.
Every `copyWith()` increments `_version`:

```dart
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    (other is MarketFeedConnected && _version == other._version);
```

This means every emit is "different" to the Bloc engine → propagates to listeners.
`BlocSelector` then does **fine-grained** equality on the small value it extracts.

### `StockTickTile` — BlocSelector

Without `BlocSelector`, every 100 ms batch would rebuild all **1 000 tiles**.
That's the same as the original freeze — just moved to the UI layer.

With `BlocSelector`:

```dart
BlocSelector<MarketFeedCubit, MarketFeedState, MarketTick?>(
  selector: (state) =>
      state is MarketFeedConnected ? state.tickMap[symbol] : null,
  builder: (context, tick) {
    // Only runs when THIS symbol's tick changes.
    return _TileContent(tick: tick);
  },
)
```

Per 100 ms batch:
- All 1 000 selectors run (just a Map lookup — negligible)
- Only ~300 selectors return a different value
- Only ~15–20 tiles are **visible** on screen at once
- Of those visible tiles, only the ones that actually changed **rebuild**

**Result: typically 5–15 widget rebuilds per frame instead of 1 000.**

### Price-Change Flash Animation

`StockTickTile` uses `AnimationController` with `SingleTickerProviderStateMixin`:

```
Price changes → _flashCtrl.forward(from: 0)
              → Container background fades from green/red → transparent
              → duration: 600ms, curve: easeOut
```

`RepaintBoundary` wraps the animated content so that when one tile animates,
neighbouring tiles in the list are **not repainted**.

---

## Performance Comparison

| Metric | Naive | This Implementation |
|--------|-------|---------------------|
| JSON parsing | Main thread, per-message | Background Isolate |
| State emits/sec | Up to 100+ | Capped at 10 |
| Widget rebuilds/frame | 1 000 | ~5–15 visible |
| Isolate spawn cost | 5–15ms × N msgs | 1× at init |
| Duplicate tick handling | Rebuilds twice | Deduplicated in buffer |
| Reconnect strategy | None | Truncated exp. backoff |
| Repaint scope | Entire list | RepaintBoundary per tile |

---

## Running the Server

```bash
# Install dependencies
cd server
dart pub get

# Run the WebSocket server (port 8080)
dart run bin/server.dart
```

Server output:
```
Market simulator: 1000 stocks initialised.
WebSocket server listening on ws://localhost:8080
```

The Flutter app connects to `ws://localhost:8080` by default.
To change the URL, pass it to `MarketFeedCubit.connectToFeed(wsUrl: ...)`.

---

## File Map

```
server/
  pubspec.yaml                          Dart server dependencies
  bin/server.dart                       Entry point, shelf WebSocket handler
  lib/simulator.dart                    GBM market simulator

lib/features/market_feed/
  domain/
    entities/market_tick.dart           MarketTick, TickDirection
    repositories/market_feed_repository.dart  Abstract repo + FeedConnectionStatus
    usecases/market_feed_usecases.dart  4 use-cases (connect/watch/disconnect)

  data/
    models/market_tick_model.dart       JSON ↔ MarketTick mapping
    workers/tick_parser_worker.dart     Persistent Isolate for JSON parsing
    datasources/market_websocket_datasource.dart  WS lifecycle + buffer/flush
    repositories/market_feed_repository_impl.dart  TaskEither wrapper

  presentation/
    cubit/market_feed_state.dart        Sealed states, version-based equality
    cubit/market_feed_cubit.dart        Merge logic, UPS sampler
    widgets/stock_tick_tile.dart        BlocSelector + flash animation
    screens/market_feed_screen.dart     Full UI with stats bar

docs/
  MARKET_FEED_ARCHITECTURE.md          This document
```
