import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/funds/data/datasources/funds_local_datasource.dart';
import '../../features/funds/data/repositories/funds_repository_impl.dart';
import '../../features/funds/domain/repositories/funds_repository.dart';
import '../../features/funds/domain/usecases/get_funds_usecase.dart';
import '../../features/funds/presentation/cubit/funds_cubit.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_portfolio_summary_usecase.dart';
import '../../features/home/domain/usecases/get_watchlist_usecase.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/ipo/data/datasources/ipo_local_datasource.dart';
import '../../features/ipo/data/repositories/ipo_repository_impl.dart';
import '../../features/ipo/domain/repositories/ipo_repository.dart';
import '../../features/ipo/domain/usecases/get_ipo_listings_usecase.dart';
import '../../features/ipo/presentation/cubit/ipo_cubit.dart';
import '../../features/markets/data/datasources/markets_local_datasource.dart';
import '../../features/markets/data/repositories/markets_repository_impl.dart';
import '../../features/markets/domain/repositories/markets_repository.dart';
import '../../features/markets/domain/usecases/get_market_indices_usecase.dart';
import '../../features/markets/domain/usecases/get_stocks_usecase.dart';
import '../../features/markets/presentation/bloc/markets_bloc.dart';
import '../../features/murabaha/data/datasources/murabaha_local_datasource.dart';
import '../../features/murabaha/data/repositories/murabaha_repository_impl.dart';
import '../../features/murabaha/domain/repositories/murabaha_repository.dart';
import '../../features/murabaha/domain/usecases/get_murabaha_plans_usecase.dart';
import '../../features/murabaha/domain/usecases/invest_in_murabaha_usecase.dart';
import '../../features/murabaha/presentation/cubit/murabaha_cubit.dart';
import '../../features/notifications/data/datasources/notifications_local_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/orders/data/datasources/orders_local_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_orders_usecase.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/portfolio/data/datasources/portfolio_local_datasource.dart';
import '../../features/portfolio/data/repositories/portfolio_repository_impl.dart';
import '../../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../../features/portfolio/domain/usecases/get_asset_allocations_usecase.dart';
import '../../features/portfolio/domain/usecases/get_holdings_usecase.dart';
import '../../features/portfolio/presentation/cubit/portfolio_cubit.dart';
import '../../features/statement/data/datasources/statement_local_datasource.dart';
import '../../features/statement/data/repositories/statement_repository_impl.dart';
import '../../features/statement/domain/repositories/statement_repository.dart';
import '../../features/statement/domain/usecases/get_transactions_usecase.dart';
import '../../features/statement/presentation/cubit/statement_cubit.dart';
import '../../features/trade/data/datasources/trade_local_datasource.dart';
import '../../features/trade/data/repositories/trade_repository_impl.dart';
import '../../features/trade/domain/repositories/trade_repository.dart';
import '../../features/trade/domain/usecases/get_stock_detail_usecase.dart';
import '../../features/trade/domain/usecases/place_order_usecase.dart';
import '../../features/trade/presentation/cubit/trade_cubit.dart';
import '../network/api_service.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerCore();
  _registerHome();
  _registerMarkets();
  _registerTrade();
  _registerPortfolio();
  _registerMurabaha();
  _registerOrders();
  _registerNotifications();
  _registerStatement();
  _registerIpo();
  _registerFunds();
}

void _registerCore() {
  getIt.registerLazySingleton<Dio>(() => DioClient.create());
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
}

void _registerHome() {
  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetPortfolioSummaryUseCase(getIt()));
  getIt.registerFactory(() => GetWatchlistUseCase(getIt()));
  getIt.registerFactory(
    () => HomeCubit(
      getPortfolioSummary: getIt(),
      getWatchlist: getIt(),
    ),
  );
}

void _registerMarkets() {
  getIt.registerLazySingleton<MarketsLocalDataSource>(
    () => MarketsLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<MarketsRepository>(
    () => MarketsRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetStocksUseCase(getIt()));
  getIt.registerFactory(() => GetMarketIndicesUseCase(getIt()));
  getIt.registerFactory(
    () => MarketsBloc(
      getStocks: getIt(),
      getMarketIndices: getIt(),
    ),
  );
}

void _registerTrade() {
  getIt.registerLazySingleton<TradeLocalDataSource>(
    () => TradeLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<TradeRepository>(
    () => TradeRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetStockDetailUseCase(getIt()));
  getIt.registerFactory(() => PlaceOrderUseCase(getIt()));
  getIt.registerFactory(
    () => TradeCubit(
      getStockDetail: getIt(),
      placeOrder: getIt(),
    ),
  );
}

void _registerPortfolio() {
  getIt.registerLazySingleton<PortfolioLocalDataSource>(
    () => PortfolioLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetHoldingsUseCase(getIt()));
  getIt.registerFactory(() => GetAssetAllocationsUseCase(getIt()));
  getIt.registerFactory(
    () => PortfolioCubit(
      getHoldings: getIt(),
      getAllocations: getIt(),
    ),
  );
}

void _registerMurabaha() {
  getIt.registerLazySingleton<MurabahaLocalDataSource>(
    () => MurabahaLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<MurabahaRepository>(
    () => MurabahaRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetMurabahaPlansUseCase(getIt()));
  getIt.registerFactory(() => InvestInMurabahaUseCase(getIt()));
  getIt.registerFactory(
    () => MurabahaCubit(
      getPlans: getIt(),
      invest: getIt(),
    ),
  );
}

void _registerOrders() {
  getIt.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSource(),
  );
  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetOrdersUseCase(getIt()));
  getIt.registerFactory(
    () => OrdersCubit(getOrders: getIt()),
  );
}

void _registerNotifications() {
  getIt.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSource(),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetNotificationsUseCase(getIt()));
  getIt.registerFactory(
    () => NotificationsCubit(getNotifications: getIt()),
  );
}

void _registerStatement() {
  getIt.registerLazySingleton<StatementLocalDataSource>(
    () => StatementLocalDataSource(),
  );
  getIt.registerLazySingleton<StatementRepository>(
    () => StatementRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetTransactionsUseCase(getIt()));
  getIt.registerFactory(
    () => StatementCubit(getTransactions: getIt()),
  );
}

void _registerIpo() {
  getIt.registerLazySingleton<IpoLocalDataSource>(
    () => IpoLocalDataSource(),
  );
  getIt.registerLazySingleton<IpoRepository>(
    () => IpoRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetIpoListingsUseCase(getIt()));
  getIt.registerFactory(
    () => IpoCubit(getIpoListings: getIt()),
  );
}

void _registerFunds() {
  getIt.registerLazySingleton<FundsLocalDataSource>(
    () => FundsLocalDataSource(),
  );
  getIt.registerLazySingleton<FundsRepository>(
    () => FundsRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => GetFundsUseCase(getIt()));
  getIt.registerFactory(
    () => FundsCubit(getFunds: getIt()),
  );
}
