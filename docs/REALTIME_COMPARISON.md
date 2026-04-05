# Realtime Transport Comparison: WebSocket vs Ably

A deep-dive into what raw WebSocket gives you and what Ably layers on top —
using two identical `IRealtimeClient` implementations as living evidence.

---

## Table of Contents

1. [What is a WebSocket?](#what-is-a-websocket)
2. [What is Ably?](#what-is-ably)
3. [Architecture Diagram](#architecture-diagram)
4. [Feature Parity Table](#feature-parity-table)
5. [Deep Dive: What You Build Manually with WebSocket](#deep-dive-websocket)
   - [Message Protocol (Envelope)](#1-message-protocol-envelope)
   - [Channel Routing](#2-channel-routing)
   - [Reconnect with Exponential Backoff](#3-reconnect-with-exponential-backoff)
   - [Application-Level Heartbeat](#4-application-level-heartbeat)
   - [Presence Management](#5-presence-management)
   - [Auth / Tokens](#6-auth--tokens)
   - [Re-subscription After Reconnect](#7-re-subscription-after-reconnect)
6. [Deep Dive: What Ably Gives You for Free](#deep-dive-ably)
7. [Code Size Comparison](#code-size-comparison)
8. [Side-by-Side: Same Feature, Two Implementations](#side-by-side)
9. [When to Choose Each](#when-to-choose-each)
10. [File Map](#file-map)

---

## What is a WebSocket?

WebSocket is a **protocol** defined in [RFC 6455](https://datatracker.ietf.org/doc/html/rfc6455).

It upgrades an HTTP connection into a **persistent, full-duplex** TCP channel.
The spec defines:

- How to do the opening handshake (HTTP Upgrade)
- How to frame messages (text / binary)
- How to close cleanly (close frame)
- Ping / Pong control frames (optional, usually at the OS level)

**That's it.** Everything else — reconnect, channels, presence, auth, message IDs —
is **your problem**.

```
Client                            Server
  │  HTTP GET /ws                   │
  │  Upgrade: websocket             │
  │──────────────────────────────►  │
  │                                 │
  │  101 Switching Protocols        │
  │ ◄──────────────────────────────  │
  │                                 │
  │  ← Full-duplex binary frames →  │
  │                                 │
  │  [ close frame ]                │
  │──────────────────────────────►  │
```

---

## What is Ably?

Ably is a **managed realtime infrastructure** service.  Its client SDK
(what you import as `ably_flutter`) speaks to Ably's global edge network
over WebSocket **by default**, with automatic fallback to HTTP streaming
and long-polling when WebSockets are blocked.

```
Flutter App
  │
  │   ably_flutter SDK (WebSocket / HTTP fallback)
  │
  ▼
Ably Edge Node  (nearest PoP, < 65 ms anywhere on Earth)
  │
  ├──► Ably Core  (channels, presence, auth, history, push)
  │
  └──► Other Subscribers (web, mobile, server)
```

You don't talk to a WebSocket directly.  You talk to an **SDK** that:

- Decides which transport to use
- Handles every error, reconnect, and backoff scenario
- Manages channel lifecycle (attach → detach → re-attach)
- Maintains the distributed presence set across all PoPs
- Renews your auth token before it expires
- Delivers messages **once** (deduplication by message ID)

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│  WebSocketRealtimeClient                                         │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  You build this:                                           │ │
│  │                                                            │ │
│  │  WebSocketChannel (dart:io / web_socket_channel)          │ │
│  │    │                                                       │ │
│  │    ├── Heartbeat timer (20 s ping / 10 s pong timeout)    │ │
│  │    ├── Reconnect timer (2→4→8→16→30 s backoff)           │ │
│  │    ├── JSON envelope decoder                              │ │
│  │    ├── Channel router  Map<"ch\x00ev", StreamController> │ │
│  │    ├── Presence table  Map<channel, Map<cid, event>>     │ │
│  │    └── Re-subscribe on reconnect                         │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  AblyRealtimeClient                                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Ably SDK handles all of this:                             │ │
│  │                                                            │ │
│  │  ably.Realtime(options: ClientOptions(...))               │ │
│  │    │                                                       │ │
│  │    ├── realtime.connect()  ← one call                     │ │
│  │    ├── realtime.connection.on()  ← state stream           │ │
│  │    ├── realtime.channels.get('ch')  ← channel handle      │ │
│  │    │     ├── channel.subscribe(name: 'ev')  ← stream      │ │
│  │    │     ├── channel.publish(message: ...)  ← publish     │ │
│  │    │     └── channel.presence.*  ← full presence          │ │
│  │    └── (all reconnect / heartbeat / token renewal hidden) │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## Feature Parity Table

| Feature                    | WebSocketRealtimeClient            | AblyRealtimeClient              |
|----------------------------|------------------------------------|---------------------------------|
| **Transport**              | Raw WebSocket                      | WebSocket + HTTP fallbacks      |
| **Connect**                | Manual handshake, URL build        | `realtime.connect()`            |
| **Reconnect**              | ~30 lines, manual timer + backoff  | Automatic, SDK-managed          |
| **Heartbeat**              | 20-line ping/pong timer            | Automatic                       |
| **Channel routing**        | JSON envelope + `Map` of ctrls     | `channels.get()` built-in       |
| **Pub/Sub**                | Manual encode/send + route         | `channel.subscribe/publish()`   |
| **Channel re-attach**      | Re-send all subscribe frames       | SDK does it automatically       |
| **Presence**               | Manual server table + broadcast    | `channel.presence.*` built-in   |
| **Auth / Token refresh**   | Manual JWT in query param          | `authCallback` + auto-renewal   |
| **Message IDs**            | `timestamp_counter` (local)        | UUID (global, server-assigned)  |
| **Message deduplication**  | ❌ Not implemented                 | ✅ By message ID                |
| **Message history**        | ❌ Not available                   | ✅ `channel.history()`          |
| **E2E Encryption**         | ❌ Manual AES needed               | ✅ `CipherParams` one-liner     |
| **Push Notifications**     | ❌ Not available                   | ✅ `channel.push.subscribeDevice()` |
| **Lines of logic**         | ~300 lines                         | ~120 lines                      |
| **Server code required?**  | ✅ Yes (envelope + presence logic) | ❌ No (Ably is the server)      |

---

## Deep Dive: WebSocket

### 1. Message Protocol (Envelope)

A WebSocket is just a **pipe**.  There is no concept of channels, events, or
routing in the protocol.  You must invent and implement a message envelope
that both your server and client agree on.

Ably has a complete wire protocol baked into its SDK.  With WebSocket you write:

```
CLIENT → SERVER                          SERVER → CLIENT
──────────────                           ───────────────
{ "t": "sub",                            { "t": "msg",
  "ch": "market:AAPL",                     "ch": "market:AAPL",
  "ev": "tick"          }                  "ev": "tick",
                                           "d": { "price": 182.5 },
{ "t": "msg",                              "id": "1712345_7",
  "ch": "market:AAPL",                     "cid": "alice",
  "ev": "alert",                           "ts": 1712345678900 }
  "d": { "price": 200 },
  "id": "1712345_1",               { "t": "presence",
  "cid": "alice"      }              "a": "enter",
                                     "ch": "trading-room",
{ "t": "presence",                   "cid": "bob",
  "a": "enter",                      "ts": 1712345678901 }
  "ch": "trading-room",
  "d": { "name": "Alice" } }   { "t": "pong" }

{ "t": "ping"           }
```

The **server** must also implement this schema, including:
- Parsing every envelope type
- Broadcasting published messages to all subscribers on that channel
- Tracking presence members and broadcasting enter/leave events
- Echoing `pong` back within the heartbeat window

### 2. Channel Routing

Ably channels are a first-class concept.  With raw WebSocket you build a
routing table yourself:

```dart
// WebSocketRealtimeClient — the full routing table
final Map<String, StreamController<RealtimeMessage>> _msgControllers = {};

// Key: "$channel\x00$event"  OR  "$channel\x00*"  (wildcard)
String _subKey(String channel, String? event) =>
    '$channel\x00${event ?? '*'}';

// Routing on incoming frame:
void _routeMessage(Map<String, dynamic> frame) {
  final channel = frame['ch'] as String;
  final event   = frame['ev'] as String;

  // Route to the event-specific subscriber
  _msgControllers[_subKey(channel, event)]?.add(message);

  // Route to the wildcard subscriber
  _msgControllers[_subKey(channel, null)]?.add(message);
}
```

```dart
// AblyRealtimeClient — Ably does this inside the SDK
final ch = realtime.channels.get('market:AAPL');
ch.subscribe(name: 'tick');  // ← that's it
```

### 3. Reconnect with Exponential Backoff

When the network drops, a bare WebSocket fires `onDone` and is gone.
Nothing reconnects unless you write it.

```dart
// WebSocketRealtimeClient — ~30 lines you write yourself
const _kReconnectDelays = [2, 4, 8, 16, 30]; // seconds

void _scheduleReconnect() {
  if (_reconnectAttempts >= _kReconnectDelays.length) {
    _setState(RealtimeConnectionState.failed);
    return;
  }

  final delaySec = _kReconnectDelays[_reconnectAttempts++];
  _setState(RealtimeConnectionState.reconnecting);

  _reconnectTimer?.cancel();
  _reconnectTimer = Timer(Duration(seconds: delaySec), () async {
    try {
      await _attemptConnect();   // re-opens the WebSocket
    } catch (_) { /* will retry via _handleDisconnect */ }
  });
}
```

Ably's `autoConnect: true` (the default) handles all of this:

```
Network drop
    │
    └──► Ably SDK detects disconnect
              │
              └──► Internally backs off: 15ms → 30ms → 60ms → … → 30s
                        │
                        └──► Re-connects, re-attaches all channels,
                             re-enters presence, re-fetches missed messages
```

You write zero code for this.

### 4. Application-Level Heartbeat

TCP connections can be silently dropped by NAT devices, load balancers, and
cloud proxies after ~60–90 seconds of idle time.  The WebSocket **protocol**
has Ping/Pong control frames (RFC 6455 §5.5), but most Dart WebSocket
wrappers do not expose them at the application level.

We implement an application-layer equivalent:

```dart
// WebSocketRealtimeClient — heartbeat you write yourself
const _kHeartbeatInterval = Duration(seconds: 20);
const _kHeartbeatTimeout  = Duration(seconds: 10);

void _startHeartbeat() {
  _heartbeatTimer = Timer.periodic(_kHeartbeatInterval, (_) => _sendPing());
}

void _sendPing() {
  if (_waitingForPong) {
    // Previous pong never arrived — connection is dead
    _onTransportClosed();
    return;
  }
  _send(jsonEncode({'t': 'ping'}));
  _waitingForPong = true;

  _pongTimer = Timer(_kHeartbeatTimeout, () {
    if (_waitingForPong) _onTransportClosed();
  });
}

void _handlePong() {
  _waitingForPong = false;
  _pongTimer?.cancel();
}
```

Ably sends WebSocket-level pings every 15 seconds automatically.
You write zero heartbeat code.

### 5. Presence Management

"Presence" = knowing who else is connected to a channel right now.

With Ably, this is a built-in distributed feature:

```dart
// Ably — one line
await channel.presence.enter({'username': 'Alice'});
final members = await channel.presence.get(); // live, from Ably servers
```

With raw WebSocket:
- **Client**: sends a `{ "t": "presence", "a": "enter", ... }` envelope
- **Server** must: maintain a presence table, broadcast to all channel subscribers,
  handle disconnects (detect when a client drops and emit `leave`)
- **Client**: receives presence events and maintains a **local copy** of the
  presence table in memory

```dart
// WebSocketRealtimeClient — presence table you maintain yourself
final Map<String, Map<String, PresenceEvent>> _presenceTable = {};

void _routePresence(Map<String, dynamic> frame) {
  final channel  = frame['ch'] as String;
  final clientId = frame['cid'] as String;
  final action   = _parsePresenceAction(frame['a']);

  switch (action) {
    case PresenceAction.enter:
    case PresenceAction.present:
    case PresenceAction.update:
      _presenceTable.putIfAbsent(channel, () => {})[clientId] = event;
    case PresenceAction.leave:
      _presenceTable[channel]?.remove(clientId);
  }

  // Broadcast to local stream subscribers
  _presenceControllers[channel]?.add(event);
}
```

One critical problem: if a client's TCP connection drops without a clean
close frame, the **server** must detect the broken pipe and emit a `leave`
event.  Ably handles this with heartbeats on its infrastructure side.
With WebSocket you write this detection logic yourself on the server.

### 6. Auth / Tokens

WebSocket has **no authentication mechanism** at the protocol level.
You bolt it on yourself — typically via a query parameter or a first-frame
auth envelope:

```dart
// WebSocketRealtimeClient — manual auth
String connectUrl = _baseUrl;
if (_getAuthToken != null) {
  final token = await _getAuthToken();
  if (token != null) {
    connectUrl = '$connectUrl?token=$token';  // token in URL
  }
}
_channel = WebSocketChannel.connect(Uri.parse(connectUrl));
```

Problems with this approach:
- The token is visible in server logs and proxy logs
- You must manually refresh tokens before they expire
- No standard way to reject a connection mid-stream when a token expires

Ably provides **token authentication** natively:

```dart
// AblyRealtimeClient — token auth via SDK
final options = ably.ClientOptions(
  clientId: clientId,
  authCallback: (params) async {
    // SDK calls this automatically when a token is needed or about to expire.
    // The token is fetched from YOUR server, never embedded in the app.
    return await myServer.requestAblyToken(params);
  },
);
```

The SDK **renews the token automatically** before it expires.  If a token
refresh fails mid-session, the SDK emits a `failed` state rather than
silently dropping messages.

### 7. Re-subscription After Reconnect

After a reconnect the server has no memory of what this client subscribed to.
All subscriptions must be re-sent:

```dart
// WebSocketRealtimeClient — re-subscribe on every reconnect
void _resubscribeAll() {
  for (final entry in _activeSubscriptions.entries) {
    final channel = entry.key;
    for (final event in entry.value) {
      _sendSubscribeFrame(channel, event);
    }
  }
}
```

Ably tracks channel state (`attached`, `detached`, `suspended`) inside the SDK.
On reconnect it automatically re-attaches every channel and re-fetches any
messages that arrived while disconnected (within the 2-minute history window).

---

## Deep Dive: Ably

### What you actually write

```dart
final realtime = ably.Realtime(
  options: ably.ClientOptions(
    clientId: 'trader-alice',
    key: 'YOUR_KEY',            // or authCallback for production
  ),
);

await realtime.connect();

// Subscribe
final ch = realtime.channels.get('market:AAPL');
ch.subscribe(name: 'tick').listen((msg) {
  print(msg.data);              // RealtimeMessage.data
});

// Publish
await ch.publish(message: ably.Message(name: 'tick', data: {...}));

// Presence
await ch.presence.enter({'username': 'Alice'});
ch.presence.subscribe().listen((msg) => print(msg.action));

// History (not available in WebSocket impl at all)
final result = await ch.history(ably.RealtimeHistoryParams(limit: 50));

// E2E Encryption (one line — not available in WebSocket impl at all)
final key = await ably.Crypto.generateRandomKey();
final encryptedCh = realtime.channels.get(
  'market:AAPL',
  ably.RealtimeChannelOptions(cipher: ably.CipherParams(key: key)),
);
```

All of the reconnect, heartbeat, re-subscribe, and token-renewal logic runs
inside the SDK with zero code from you.

---

## Code Size Comparison

| Responsibility                | WebSocketRealtimeClient | AblyRealtimeClient |
|-------------------------------|-------------------------|---------------------|
| Connection + auth setup       | ~40 lines               | ~20 lines           |
| Reconnect + backoff           | ~30 lines               | 0 lines             |
| Heartbeat                     | ~20 lines               | 0 lines             |
| Channel routing / sub table   | ~40 lines               | ~10 lines           |
| Incoming frame dispatch       | ~30 lines               | 0 lines             |
| Presence table maintenance    | ~35 lines               | ~10 lines           |
| Re-subscribe after reconnect  | ~15 lines               | 0 lines             |
| Type mapping helpers          | ~20 lines               | ~20 lines           |
| **Total (approx.)**           | **~230 lines**          | **~60 lines**       |
| **Server code also needed?**  | **Yes**                 | **No**              |

---

## Side-by-Side

### Connect

```dart
// ─── WebSocket ───────────────────────────────────────────────────────────────
// You assemble the URL, optionally append an auth token, open the channel,
// handle the "ready" future (throws if refused), start the heartbeat,
// pipe messages to the router, start the reconnect logic.

Future<void> _attemptConnect() async {
  _setState(RealtimeConnectionState.connecting);

  String url = _baseUrl;
  if (_getAuthToken != null) {
    final token = await _getAuthToken();
    if (token != null) url = '$url?token=$token';
  }

  _channel = WebSocketChannel.connect(Uri.parse(url));
  await _channel!.ready;

  _onConnected();               // starts heartbeat + ws listener
}

// ─── Ably ────────────────────────────────────────────────────────────────────
// One call.  The SDK handles the handshake, token fetch, and heartbeat.

await _realtime.connect();
```

---

### Subscribe

```dart
// ─── WebSocket ───────────────────────────────────────────────────────────────
// 1. Get or create a StreamController for this channel+event key.
// 2. Track the subscription so we can re-send the frame after reconnect.
// 3. Send a subscribe frame to the server right now (if connected).
// 4. Return the controller's stream.

Stream<RealtimeMessage> subscribe(String channel, {String? event}) {
  final key  = '$channel\x00${event ?? '*'}';
  final ctrl = _msgControllers.putIfAbsent(key,
      () => StreamController.broadcast());

  _activeSubscriptions.putIfAbsent(channel, () => {}).add(event);

  if (_state == RealtimeConnectionState.connected) {
    _send(jsonEncode({'t': 'sub', 'ch': channel, if (event != null) 'ev': event}));
  }

  return ctrl.stream;
}

// ─── Ably ────────────────────────────────────────────────────────────────────
// channels.get() caches the channel.  subscribe() returns a Stream<ably.Message>.
// The SDK attaches to the channel, manages subscriptions, and re-attaches
// after reconnect automatically.

Stream<RealtimeMessage> subscribe(String channel, {String? event}) {
  final ch = realtime.channels.get(channel)..attach();
  return (event != null ? ch.subscribe(name: event) : ch.subscribe())
      .map(_toRealtimeMessage);
}
```

---

### Reconnect

```dart
// ─── WebSocket ───────────────────────────────────────────────────────────────
// You write the entire backoff algorithm.

const _kReconnectDelays = [2, 4, 8, 16, 30];   // seconds

void _scheduleReconnect() {
  if (_reconnectAttempts >= _kReconnectDelays.length) {
    _setState(RealtimeConnectionState.failed);
    return;
  }
  final delay = _kReconnectDelays[_reconnectAttempts++];
  _setState(RealtimeConnectionState.reconnecting);
  _reconnectTimer = Timer(Duration(seconds: delay), _attemptConnect);
}

// ─── Ably ────────────────────────────────────────────────────────────────────
// Zero lines.  The SDK's built-in policy:
//   disconnected → 15ms → 30ms → 60ms → 120ms → ... → 30s (cap) → suspended
```

---

### Presence

```dart
// ─── WebSocket ───────────────────────────────────────────────────────────────
// Client side: send an envelope, maintain a local table.
// Server side: also needs ~50 lines to track members + broadcast + detect drops.

Future<void> enterPresence(String channel, {dynamic data}) async {
  _send(jsonEncode({'t': 'presence', 'a': 'enter', 'ch': channel, 'd': data}));
}

void _routePresence(Map<String, dynamic> frame) {
  // merge into _presenceTable[channel][clientId], then emit on stream
}

// ─── Ably ────────────────────────────────────────────────────────────────────
// One SDK call.  Ably's servers handle the distributed member set.

await channel.presence.enter({'username': 'Alice'});
```

---

## When to Choose Each

### Choose raw WebSocket when:

| Situation | Reason |
|---|---|
| You control **both** client and server | You can design a custom protocol optimised for your exact data |
| The data format is non-standard | Binary frames, MessagePack, Protobuf — WebSocket is just a pipe |
| Cost is critical at massive scale | Ably charges per message; a self-hosted WS server has fixed infra cost |
| You need zero external dependencies | Pure Dart server, no third-party SaaS |
| Learning / education | Understanding the low-level protocol is essential foundation knowledge |

### Choose Ably when:

| Situation | Reason |
|---|---|
| **FinTech / Trading app** (like this one) | Reliability, reconnect, presence, and history are non-negotiable |
| Multiple platforms (web + mobile + server) | Ably has SDKs for 20+ platforms with identical semantics |
| Team is small | You can't afford to write and maintain reconnect + heartbeat + presence infra |
| Features > Infrastructure | Your competitive advantage is the product, not the WebSocket plumbing |
| Token auth is required | Ably's auth model is production-ready; rolling your own is a security risk |
| Message history is needed | "I missed 2 minutes of prices while I was offline" — Ably solves this |

---

## Transport Fallback (Ably only)

Ably automatically falls back to less ideal transports when WebSocket is blocked:

```
Try WebSocket
    │
    ├─ Success ──► use WebSocket (best: full-duplex, lowest overhead)
    │
    └─ Blocked ──► Try HTTP Streaming
                    │
                    ├─ Success ──► use HTTP streaming (server-push, no upgrade)
                    │
                    └─ Blocked ──► Try HTTP Long-Polling
                                    (slowest, but works everywhere)
```

Raw WebSocket has no fallback.  If port 443 WebSocket upgrades are blocked by
a corporate firewall, your app simply cannot connect.

---

## File Map

```
lib/core/network/realtime/
  realtime_client_interface.dart     Shared types + abstract IRealtimeClient
  websocket_realtime_client.dart     Manual WebSocket implementation (~300 LOC)
  ably_realtime_client.dart          Ably SDK wrapper (~120 LOC)

docs/
  REALTIME_COMPARISON.md             This document
  MARKET_FEED_ARCHITECTURE.md        How the market feed uses WebSocket in production
```

### How this fits into the existing Market Feed

The production market feed uses `MarketWebSocketDatasource` (in
`lib/features/market_feed/data/datasources/`) which is a **domain-specific**
WebSocket client optimised for the 1 000-stock GBM price feed.

`WebSocketRealtimeClient` and `AblyRealtimeClient` are **general-purpose**
realtime clients that implement the full Pub/Sub + Presence + Auth contract
described by `IRealtimeClient`.  They live in `lib/core/network/realtime/`
because they could serve any feature (orders, notifications, chat) that needs
realtime messaging.

Both implementations are behind the same interface so the DI layer can swap
them without touching any feature code:

```dart
// In your DI module (e.g. get_it):

// Development / self-hosted server:
getIt.registerSingleton<IRealtimeClient>(
  WebSocketRealtimeClient(
    url:      'ws://localhost:8080',
    clientId: 'dev-trader',
  ),
);

// Production (Ably):
getIt.registerSingleton<IRealtimeClient>(
  AblyRealtimeClient(
    clientId:      userId,
    tokenCallback: (params) => authApi.requestAblyToken(params),
  ),
);
```
