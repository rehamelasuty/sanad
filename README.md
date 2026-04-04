# سند — Sanad

> **Islamic Investment Platform** · Flutter · Clean Architecture · BLoC

Sanad (سند — "bond/support") is a Sharia-compliant investment app for the Saudi market, built with Flutter. It covers the full investor journey: onboarding & KYC, live market data, portfolio tracking, Murabaha products, IPO subscriptions, mutual funds, order management, and account operations.

---

## Table of Contents

1. [Screenshots](#screenshots)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Architecture](#architecture)
5. [Project Structure](#project-structure)
6. [Routing](#routing)
7. [State Management](#state-management)
8. [Dependency Injection](#dependency-injection)
9. [Theming](#theming)
10. [Flavors](#flavors)
11. [Getting Started](#getting-started)
12. [Running the App](#running-the-app)
13. [Code Generation](#code-generation)
14. [Localization](#localization)
15. [Contributing](#contributing)

---

## Features

| Module | Screens | State |
|---|---|---|
| **Auth** | Splash · Login · OTP | — (pure UI) |
| **KYC** | ID Upload · Selfie · Bank Link · Review · Submitted · Approved | — (pure UI) |
| **Home** | Portfolio hero card · Watchlist · Quick actions · Murabaha banner | `HomeCubit` |
| **Markets** | Stocks list · Market indices | `MarketsBloc` |
| **Portfolio** | Holdings · Asset allocation chart | `PortfolioCubit` |
| **Trade** | Stock detail · Buy/Sell order form | `TradeCubit` |
| **Murabaha** | Plans list · Plan detail · Invest flow | `MurabahaCubit` |
| **Orders** | Order history · Status filter | `OrdersCubit` |
| **Notifications** | Notification feed · Mark all read | `NotificationsCubit` |
| **Statement** | Transaction list · Period filter · Summary card | `StatementCubit` |
| **IPO** | Listings · Subscription progress · Subscribe | `IpoCubit` |
| **Funds** | Mutual fund cards · Exchange filter · Invest CTA | `FundsCubit` |
| **Deposit** | Method picker · Amount entry · Quick chips | — (pure UI) |
| **Profile** | Settings groups · Biometrics toggle · Sharia filter · Logout | — (pure UI) |

---

## Tech Stack

| Concern | Package | Version |
|---|---|---|
| SDK | Flutter / Dart | `^3.8.1` |
| State Management | `flutter_bloc` | `^8.1.6` |
| Dependency Injection | `get_it` | `^8.0.2` |
| Navigation | `go_router` | `^14.6.2` |
| Functional Programming | `fpdart` | `^1.1.0` |
| Networking | `dio` + `retrofit` | `^5.7.0` / `^4.4.1` |
| Responsive UI | `flutter_screenutil` | `^5.9.3` |
| Fonts | `google_fonts` (IBM Plex Sans Arabic + IBM Plex Mono) | `^6.2.1` |
| Charts | `fl_chart` | `^0.70.2` |
| Storage | `shared_preferences` | `^2.3.2` |
| Localization | Flutter gen-l10n | built-in |
| Serialization | `freezed` + `json_serializable` | code-gen |

---

## Architecture

Sanad follows **Clean Architecture** with a strict three-layer separation per feature:

```
┌──────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  Screens · Cubits/Blocs · States · Shared Widgets    │
└────────────────────┬─────────────────────────────────┘
                     │  calls
┌────────────────────▼─────────────────────────────────┐
│                   Domain Layer                       │
│   Entities · Repository Interfaces · Use Cases       │
└────────────────────┬─────────────────────────────────┘
                     │  implements
┌────────────────────▼─────────────────────────────────┐
│                    Data Layer                        │
│    Models · Local DataSources · Repository Impls     │
└──────────────────────────────────────────────────────┘
```

### Error Handling

All async operations return `TaskEither<Failure, T>` (fpdart). The `Failure` sealed class has four variants:

```dart
NetworkFailure   // no connectivity or HTTP transport error
ServerFailure    // 4xx / 5xx with parsed API error body
CacheFailure     // local storage read/write failure
UnknownFailure   // catch-all for unexpected exceptions
```

Each variant exposes `.userMessage` — a localised Arabic string ready to display in an `AppErrorWidget`.

### Data Flow

```
UI Event
  → Cubit/Bloc method
    → UseCase().run()          // TaskEither<Failure, T>
      → Repository (abstract)
        → RepositoryImpl
          → LocalDataSource / RemoteDataSource
  ← emit(State)
  ← BlocBuilder rebuilds
```

---

## Project Structure

```
lib/
├── app.dart                          # MaterialApp.router + ScreenUtilInit
├── main.dart                         # Entry point (dev flavor)
├── main_dev.dart
├── main_staging.dart
├── main_prod.dart
│
├── flavors/
│   └── app_flavor.dart               # FlavorType enum + base URLs
│
├── core/
│   ├── constants/                    # App-wide constants
│   ├── di/
│   │   └── injection.dart            # GetIt registrations
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart             # Sealed Failure hierarchy
│   ├── l10n/                         # ARB files + generated AppLocalizations
│   ├── network/
│   │   ├── api_service.dart          # Retrofit service interface
│   │   ├── dio_client.dart           # Dio factory + interceptors
│   │   └── interceptors/
│   ├── router/
│   │   ├── app_router.dart           # GoRouter definition
│   │   └── app_routes.dart           # Route path constants
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   ├── app_spacing.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── widgets/common/               # Shared reusable widgets
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_loading_error.dart
│       ├── app_shell.dart            # Bottom nav shell (ShellRoute)
│       ├── price_change_badge.dart
│       ├── section_header.dart
│       ├── sharia_badge.dart
│       ├── sparkline_widget.dart
│       └── stock_list_tile.dart
│
└── features/
    ├── auth/
    ├── funds/
    ├── home/
    ├── ipo/
    ├── kyc/
    ├── markets/
    ├── murabaha/
    ├── notifications/
    ├── orders/
    ├── portfolio/
    ├── profile/
    ├── statement/
    ├── trade/
    └── wallet/
        └── (deposit)
```

Every feature that has state management follows this internal layout:

```
features/<name>/
├── data/
│   ├── datasources/<name>_local_datasource.dart
│   ├── models/                        # (where applicable)
│   └── repositories/<name>_repository_impl.dart
├── domain/
│   ├── entities/<entity>.dart
│   ├── repositories/<name>_repository.dart   # abstract interface
│   └── usecases/<usecase>.dart
└── presentation/
    ├── cubit/
    │   ├── <name>_cubit.dart
    │   └── <name>_state.dart
    ├── screens/<name>_screen.dart
    └── widgets/                       # (screen-local widgets)
```

---

## Routing

Navigation is managed by **go_router**. The route tree has two zones:

### Shell Zone (bottom navigation)

All five main tabs live inside a `ShellRoute` backed by `AppShell`. Switching tabs uses `context.go()` with no transition animation.

| Tab | Route | Cubit |
|---|---|---|
| 🏠 الرئيسية | `/` | `HomeCubit` |
| 📊 الأسواق | `/markets` | `MarketsBloc` |
| ⚡ تداول | — (centre button → `/markets`) | — |
| 💼 محفظتي | `/portfolio` | `PortfolioCubit` |
| 👤 حسابي | `/profile` | — |

### Full-screen Push Zone

| Route | Screen | BlocProvider |
|---|---|---|
| `/trade/:symbol` | `TradeScreen` | `TradeCubit` |
| `/splash` | `SplashScreen` | — |
| `/login` | `LoginScreen` | — |
| `/otp` | `OtpScreen` | — |
| `/kyc/id` … `/kyc/approved` | KYC flow (6 screens) | — |
| `/orders` | `OrdersScreen` | `OrdersCubit` |
| `/notifications` | `NotificationsScreen` | `NotificationsCubit` |
| `/statement` | `StatementScreen` | `StatementCubit` |
| `/ipo` | `IpoScreen` | `IpoCubit` |
| `/funds` | `FundsScreen` | `FundsCubit` |
| `/deposit` | `DepositScreen` | — |

All route strings are defined as constants in `AppRoutes`. Use `context.push()` for full-screen routes and `context.go()` for tab switches.

---

## State Management

Sanad uses **flutter_bloc** with a `Cubit`-first approach (BLoC only when events have meaningful names, e.g. `MarketsBloc`).

### Cubit pattern

```dart
// 1. State — sealed class extending Equatable
sealed class OrdersState extends Equatable { ... }
class OrdersInitial extends OrdersState { ... }
class OrdersLoading extends OrdersState { ... }
class OrdersLoaded  extends OrdersState { final List<Order> orders; ... }
class OrdersError   extends OrdersState { final String message; ... }

// 2. Cubit
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required GetOrdersUseCase getOrders}) ...

  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    final result = await _getOrders().run();
    result.fold(
      (f) => emit(OrdersError(f.userMessage)),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }
}

// 3. UI
BlocBuilder<OrdersCubit, OrdersState>(
  builder: (context, state) => switch (state) {
    OrdersInitial() || OrdersLoading() => const AppLoadingWidget(),
    OrdersError(:final message)        => AppErrorWidget(message: message, ...),
    OrdersLoaded(:final orders)        => _OrderList(orders),
  },
);
```

---

## Dependency Injection

GetIt is configured manually (no code generation) in `lib/core/di/injection.dart`.

```dart
await configureDependencies(); // called once in main()
```

| Scope | Registration | When to use |
|---|---|---|
| `registerLazySingleton` | DataSource, Repository impl | shared, expensive to create |
| `registerFactory` | UseCase, Cubit/Bloc | fresh instance per navigation |

Cubits are registered as `factory` so each `BlocProvider` (in `app_router.dart`) gets a clean instance and the previous one is garbage-collected on pop.

---

## Theming

All design tokens live in `lib/core/theme/`.

### Colors (`AppColors`)

| Token | Value | Usage |
|---|---|---|
| `bgPage` | `#EEF0F5` | Scaffold background |
| `bgApp` | `#F7F8FC` | Card / surface background |
| `green` | `#0B7A5E` | Primary brand, positive change |
| `greenMid` | `#0D9970` | Gradient mid-stop |
| `greenLite` | `#E6F5F0` | Unread notification tint |
| `red` | `#D63F52` | Negative change, error |
| `gold` | `#B07D2A` | Murabaha / IPO accents |
| `blue` | `#2060C8` | Orders / info accents |
| `text1–4` | `#0F1923` → `#BCC4CE` | Typography hierarchy |

### Typography (`AppTextStyles`)

Two typefaces: **IBM Plex Sans Arabic** (UI copy) and **IBM Plex Mono** (numbers/prices). All sizes use `.sp` from `flutter_screenutil` (design size `390 × 844`).

| Style | Font | Size | Usage |
|---|---|---|---|
| `heroPrice` | Mono | `36sp` | Portfolio total |
| `priceDisplay` | Mono | `40sp` | Trade screen price |
| `h1–h4` | Sans | `22–14sp` | Headings |
| `bodyLg/Md/Sm` | Sans | `15–12sp` | Body copy |
| `caption` | Sans | `11sp` | Labels, hints |
| `monoSm` | Mono | `13sp` | Inline figures |
| `badgeMd/Sm` | Sans | `12–10sp` | Pills, badges |

### Design Tokens

- `AppRadius` — corner radii (`smAll`, `mdAll`, etc.)
- `AppShadows` — box shadow presets (`sm`, `md`, `heroCard`, `greenGlow`)
- `AppSpacing` — standard spacing values

---

## Flavors

| Flavor | Entry point | Base URL | Logging | Debug banner |
|---|---|---|---|---|
| `dev` | `main_dev.dart` | `api-dev.sanad.sa/v1` | ✅ | ✅ |
| `staging` | `main_staging.dart` | `api-staging.sanad.sa/v1` | ✅ | ✅ |
| `prod` | `main_prod.dart` | `api.sanad.sa/v1` | ❌ | ❌ |

Run a specific flavor with:

```bash
flutter run -t lib/main_dev.dart
flutter run -t lib/main_staging.dart
flutter run -t lib/main_prod.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.8.1`
- Dart SDK `>=3.4.0`
- Xcode 15+ (iOS)
- Android Studio / NDK (Android)
- CocoaPods (macOS/iOS)

### Install dependencies

```bash
flutter pub get
```

### iOS setup

```bash
cd ios && pod install && cd ..
```

---

## Running the App

```bash
# Dev flavor (default)
flutter run -t lib/main_dev.dart

# Specific device
flutter run -t lib/main_dev.dart -d <device-id>

# Release build
flutter run -t lib/main_prod.dart --release
```

### Build APK / IPA

```bash
# Android
flutter build apk -t lib/main_prod.dart --release

# iOS
flutter build ipa -t lib/main_prod.dart --release
```

---

## Code Generation

Some models use `freezed` and `json_serializable`. After editing annotated files, regenerate:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For continuous watch mode during development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## Localization

The app ships in **Arabic (ar)** with English (en) as a fallback. ARB files live in `lib/core/l10n/`. Generated classes are committed to source control.

To regenerate after editing ARB files:

```bash
flutter gen-l10n
```

Access strings via:

```dart
AppLocalizations.of(context)!.someKey
```

---

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Follow the existing Clean Architecture folder structure
3. Add the feature to `injection.dart` and `app_router.dart`
4. Ensure `flutter analyze` returns zero issues before opening a PR
5. Use `AppColors`, `AppTextStyles`, and `AppSpacing` tokens — no hardcoded values
# sanad
