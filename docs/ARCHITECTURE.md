# Architecture Guide

> Sanad — detailed technical reference for contributors and reviewers.

---

## Table of Contents

1. [Principles](#principles)
2. [Layer Responsibilities](#layer-responsibilities)
3. [Feature Anatomy](#feature-anatomy)
4. [Error Handling](#error-handling)
5. [Dependency Injection](#dependency-injection)
6. [Routing](#routing)
7. [State Management Patterns](#state-management-patterns)
8. [Theming System](#theming-system)
9. [Networking](#networking)
10. [Adding a New Feature](#adding-a-new-feature)

---

## Principles

| Principle | How it is applied |
|---|---|
| **Dependency Rule** | Outer layers depend on inner layers; never the reverse. Domain has zero Flutter imports. |
| **Single Source of Truth** | Each piece of state lives in exactly one Cubit/Bloc. |
| **Testability** | Every layer is testable in isolation via abstract interfaces. |
| **Immutability** | All state classes use `Equatable` and `const` constructors; mutable state is never emitted. |
| **Functional Error Path** | `TaskEither<Failure, T>` (fpdart) replaces `try/catch` at the repository boundary. |

---

## Layer Responsibilities

### Domain Layer
The innermost layer. Has **no Flutter, no Dio, no GetIt** — only pure Dart.

- **Entities** — plain Dart classes representing business objects (e.g. `Order`, `IpoListing`).
- **Repository interfaces** — `abstract interface class` declarations. The data layer implements them; the domain layer only sees the abstraction.
- **Use Cases** — single-responsibility classes that call one repository method and return `TaskEither<Failure, T>`.

```dart
// lib/features/orders/domain/usecases/get_orders_usecase.dart
class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);
  final OrdersRepository _repository;

  TaskEither<Failure, List<Order>> call() => _repository.getOrders();
}
```

### Data Layer
Implements the domain interfaces. May depend on Flutter (for `SharedPreferences`) but never on the presentation layer.

- **Local DataSources** — return raw Dart objects (no entities). Currently using in-memory dummy data; swap for real API calls without touching domain or presentation.
- **Repository Implementations** — bridge between the datasource and the domain contract. Convert datasource exceptions into `Failure` variants using `TaskEither.tryCatch`.

```dart
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._dataSource);
  final OrdersLocalDataSource _dataSource;

  @override
  TaskEither<Failure, List<Order>> getOrders() =>
      TaskEither.tryCatch(
        () => _dataSource.getOrders(),
        (e, _) => UnknownFailure(e.toString()),
      );
}
```

### Presentation Layer
Depends on the domain layer only.

- **Cubit/Bloc** — calls use cases, maps results to state.
- **State** — sealed class hierarchy (`Initial`, `Loading`, `Loaded`, `Error`). All fields final.
- **Screens** — stateless where possible; use `BlocBuilder` / `BlocListener` / `BlocConsumer`.
- **Widgets** — screen-local private widgets (underscore-prefixed) or shared widgets in `core/widgets/`.

---

## Feature Anatomy

```
features/<name>/
├── data/
│   ├── datasources/
│   │   └── <name>_local_datasource.dart   ← implements abstract class
│   ├── models/                             ← (optional) model ↔ entity mappers
│   └── repositories/
│       └── <name>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <entity>.dart
│   ├── repositories/
│   │   └── <name>_repository.dart         ← abstract interface class
│   └── usecases/
│       └── <usecase>.dart
└── presentation/
    ├── cubit/
    │   ├── <name>_cubit.dart
    │   └── <name>_state.dart
    ├── screens/
    │   └── <name>_screen.dart
    └── widgets/                            ← screen-local only
```

### fpdart import rule
`fpdart` exports a type named `Order` which conflicts with the `Order` entity. Any file that imports both must hide the fpdart export:

```dart
import 'package:fpdart/fpdart.dart' hide Order;
import '../entities/order.dart';
```

---

## Error Handling

### Failure hierarchy

```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
  String get userMessage;   // Arabic string for display
}

final class NetworkFailure extends Failure { final int? statusCode; }
final class ServerFailure  extends Failure { final int? statusCode; }
final class CacheFailure   extends Failure { }
final class UnknownFailure extends Failure { }
```

### Where failures are created
- `NetworkFailure` — `ErrorInterceptor` (Dio interceptor, `DioException`)
- `ServerFailure` — `ErrorInterceptor` (non-2xx responses)
- `CacheFailure` — datasource `try/catch` blocks
- `UnknownFailure` — `TaskEither.tryCatch` fallback in repository impls

### Where failures are consumed
Cubits pattern-match with `fold`:

```dart
result.fold(
  (failure) => emit(OrdersError(failure.userMessage)),
  (data)    => emit(OrdersLoaded(orders: data)),
);
```

`AppErrorWidget` receives the Arabic `userMessage` string and shows a retry button that calls the cubit method again.

---

## Dependency Injection

Registration lives in `lib/core/di/injection.dart`. Call once at startup:

```dart
await configureDependencies(); // inside main()
```

### Registration scopes

| Type | Scope | Rationale |
|---|---|---|
| `Dio` | `lazySingleton` | One HTTP client per app lifetime |
| `ApiService` | `lazySingleton` | Stateless; expensive to reflect |
| `*LocalDataSource` | `lazySingleton` | In-memory data; one instance shared |
| `*Repository` | `lazySingleton` | Stateless adapter; safe to share |
| `*UseCase` | `factory` | Lightweight; new instance is fine |
| `*Cubit` / `*Bloc` | `factory` | Fresh instance per route push/pop |

### Adding a registration

```dart
void _registerMyFeature() {
  getIt.registerLazySingleton<MyLocalDataSource>(() => MyLocalDataSource());
  getIt.registerLazySingleton<MyRepository>(() => MyRepositoryImpl(getIt()));
  getIt.registerFactory(() => MyUseCase(getIt()));
  getIt.registerFactory(() => MyCubit(myUseCase: getIt()));
}
```

Then call `_registerMyFeature()` inside `configureDependencies()`.

---

## Routing

Navigation is handled by **go_router** (`^14.6.2`). The single `GoRouter` instance is a static field on `AppRouter`.

### Route zones

```
GoRouter
├── ShellRoute (AppShell — bottom nav)
│   ├── /           → HomeScreen
│   ├── /markets    → MarketsScreen
│   ├── /portfolio  → PortfolioScreen
│   ├── /murabaha   → MurabahaScreen
│   └── /profile    → ProfileScreen
│
└── Full-screen push routes
    ├── /trade/:symbol
    ├── /splash  /login  /otp
    ├── /kyc/id  /kyc/selfie  /kyc/bank  /kyc/review  /kyc/submitted  /kyc/approved
    ├── /orders  /notifications  /statement  /ipo  /funds
    └── /deposit
```

### BlocProvider placement

Shell tabs receive their BlocProvider inside the `pageBuilder` (no transition page). Full-screen push routes receive it in the `builder`:

```dart
// Shell tab — no-transition page
GoRoute(
  path: AppRoutes.home,
  pageBuilder: (context, state) => _noTransition(
    state,
    BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadHome(),
      child: const HomeScreen(),
    ),
  ),
),

// Push route
GoRoute(
  path: AppRoutes.orders,
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<OrdersCubit>()..loadOrders(),
    child: const OrdersScreen(),
  ),
),
```

Because Cubits are `factory`-registered, `getIt<OrdersCubit>()` returns a **new** instance on every navigation, and the old one is disposed by `BlocProvider` when the route is popped.

### Navigation helpers

```dart
context.go(AppRoutes.markets);              // tab switch (no back stack)
context.push(AppRoutes.orders);             // push (back button visible)
context.push(AppRoutes.tradeRoute('AAPL')); // parameterised push
context.pop();                              // back
```

All path strings are constants in `AppRoutes`. Never hard-code a string in a widget.

---

## State Management Patterns

### Sealed state class

```dart
sealed class MyState extends Equatable {
  const MyState();

  @override
  List<Object?> get props => [];
}

class MyInitial extends MyState { const MyInitial(); }
class MyLoading extends MyState { const MyLoading(); }

class MyLoaded extends MyState {
  const MyLoaded({required this.items});
  final List<MyEntity> items;

  @override
  List<Object?> get props => [items];
}

class MyError extends MyState {
  const MyError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
```

### Exhaustive switch in UI

Use Dart `switch` on the sealed state so the compiler enforces every case:

```dart
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) => switch (state) {
    MyInitial() || MyLoading() => const AppLoadingWidget(),
    MyError(:final message)    => AppErrorWidget(message: message, onRetry: ...),
    MyLoaded(:final items)     => _MyList(items: items),
  },
);
```

### Filter / secondary actions

Secondary cubit methods (e.g. `filterByStatus`, `changePeriod`) update a derived field inside `MyLoaded` and re-emit. They should be no-ops if state is not `MyLoaded`:

```dart
void filterByStatus(OrderStatus? status) {
  final current = state;
  if (current is! OrdersLoaded) return;
  emit(current.copyWith(selectedStatus: status));
}
```

---

## Theming System

All tokens are `static const` or `static TextStyle get` — never instantiate theme objects inline in widgets.

### Token usage rules

```dart
// ✅ Correct
color: AppColors.green
style: AppTextStyles.bodyMd
margin: EdgeInsets.all(AppSpacing.md)
boxShadow: AppShadows.sm
borderRadius: AppRadius.mdAll

// ❌ Wrong
color: const Color(0xFF0B7A5E)   // hardcoded hex
style: TextStyle(fontSize: 15)   // not scaled
```

### Responsive sizing

All sizes use `flutter_screenutil` with design size `390 × 844`:

```dart
width: 42.w    // logical width scaled to device
height: 20.h   // logical height scaled to device
fontSize: 15.sp  // font size scaled for text accessibility
padding: EdgeInsets.all(16.r)  // uniform scaling
```

Never use plain `double` for layout dimensions; always `.w`, `.h`, `.r`, or `.sp`.

---

## Networking

### DioClient

`DioClient.create()` returns a configured `Dio` instance with:

- `baseUrl` from `AppFlavor.current.baseUrl`
- 30s connect / receive / send timeouts
- `Accept-Language: ar` header
- Three interceptors (in order):
  1. `AuthInterceptor` — injects `Authorization: Bearer <token>`
  2. `ErrorInterceptor` — converts `DioException` → `NetworkFailure` / `ServerFailure`
  3. `LoggingInterceptor` — only active when `AppFlavor.current.enableLogging`

### Replacing dummy data with real API calls

1. Add the endpoint to `ApiService` (Retrofit interface)
2. Create a `*RemoteDataSource` that calls `ApiService`
3. Update `*RepositoryImpl` to use the remote datasource (or both local + remote with caching logic)
4. Update `injection.dart` to pass the remote datasource
5. No changes needed in domain or presentation layers

---

## Adding a New Feature

Follow this checklist in order:

```
[ ] 1. Domain: entity class
[ ] 2. Domain: repository abstract interface
[ ] 3. Domain: use case(s)
[ ] 4. Data: local datasource (dummy data)
[ ] 5. Data: repository implementation
[ ] 6. Presentation: state (sealed class)
[ ] 7. Presentation: cubit
[ ] 8. Presentation: screen + widgets
[ ] 9. core/di/injection.dart  → _registerMyFeature()
[ ] 10. core/router/app_routes.dart → add route constant
[ ] 11. core/router/app_router.dart → add GoRoute with BlocProvider
[ ] 12. flutter analyze → 0 issues
```

### Naming conventions

| Artefact | Pattern | Example |
|---|---|---|
| Entity | `<Name>.dart` | `ipo_listing.dart` |
| Repository interface | `<name>_repository.dart` | `ipo_repository.dart` |
| Repository impl | `<name>_repository_impl.dart` | `ipo_repository_impl.dart` |
| Local datasource | `<name>_local_datasource.dart` | `ipo_local_datasource.dart` |
| Use case | `<verb>_<name>_usecase.dart` | `get_ipo_listings_usecase.dart` |
| Cubit | `<name>_cubit.dart` | `ipo_cubit.dart` |
| State | `<name>_state.dart` | `ipo_state.dart` |
| Screen | `<name>_screen.dart` | `ipo_screen.dart` |
