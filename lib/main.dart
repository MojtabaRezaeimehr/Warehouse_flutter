import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/order_detail_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/search_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/local/log.dart';
import 'package:warehouse_amf/screens/home/cubit/api_search_cubit.dart';
import 'package:warehouse_amf/screens/login/cubit/card_cubit.dart';
import 'package:warehouse_amf/screens/login/cubit/connection_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/screens/routes/routes_gen.dart';
import 'package:warehouse_amf/bloc/cubit/theme_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_type_cubit.dart';
import 'package:warehouse_amf/screens/settings/cubit/expansion_cubit.dart';
import 'package:warehouse_amf/screens/settings/cubit/user_role_cubit.dart';
import 'package:warehouse_amf/services/local/local_services.dart';
import 'package:warehouse_amf/services/local/log/log_service.dart';
import 'package:warehouse_amf/utils/consts/default_values.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';

import 'package:warehouse_amf/utils/color/color_schemes.dart';
import 'package:warehouse_amf/utils/enums/log_level.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await EasyLocalization.ensureInitialized();

      if (kIsWeb) {
        await Hive.initFlutter();
        await Hive.openBox(kDefualtHiveBox);
      }

      //appConfigRepo init must be called after hive initialization
      await LocalServices.appConfigRepo.ensureInitialization();

      //deleting old logs from storage
      LocalServices.logRepo.deleteOldLogs();

      //deleting old history from storage
      LocalServices.scannedHistoryRepo.deleteOldHistory();

      return runApp(
        ToastificationWrapper(
          child: EasyLocalization(
            supportedLocales: [const Locale("fa"), const Locale("en")],
            fallbackLocale: const Locale("fa"),
            startLocale: const Locale("fa"),
            path: "assets/translations",
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stack) {
      LogService().logThis(
        Log(
          date: DateTime.now(),
          desc: "ZonedGuarded captured error! :$error | $stack",
          logLevel: LogLevel.error,
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CardCubit>(
          create: (context) => CardCubit(),
        ),
        BlocProvider<UserAuthCubit>(
          lazy: false,
          create: (context) => UserAuthCubit(),
        ),
        BlocProvider<ConnectionCubit>(
          create: (context) => ConnectionCubit(),
        ),
        BlocProvider<UserRoleCubit>(
          create: (context) => UserRoleCubit(),
        ),
        BlocProvider<ThemeCubit>(
          lazy: false,
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<ExpansionCubit>(
          create: (context) => ExpansionCubit(),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => OrderCubit(),
        ),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(),
        ),
        BlocProvider<NewOrderCubit>(
          lazy: false,
          create: (context) => NewOrderCubit(
              context.read<UserAuthCubit>(), Theme.of(context).platform),
        ),
        BlocProvider<OrderDetailCubit>(
          create: (context) => OrderDetailCubit(),
        ),
        BlocProvider<ScanTypeCubit>(
          lazy: false,
          create: (context) => ScanTypeCubit(),
        ),
        BlocProvider<ScanCubit>(
          create: (context) => ScanCubit(
            newOrderCubit: context.read<NewOrderCubit>(),
            scanTypeCubit: context.read<ScanTypeCubit>(),
            userAuthCubit: context.read<UserAuthCubit>(),
          ),
        ),
        BlocProvider<ApiSearchCubit>(
          create: (context) => ApiSearchCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            // themeAnimationStyle: AnimationStyle.noAnimation, animaion can be disabled in device stteings
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'Warehouse-amf',
            theme: ThemeData(
              colorScheme:
                  state is LightTheme ? lightColorScheme : darkColorScheme,
            ),
            initialRoute: kRouteLogIn,
            routes: generateRoutes(),
          );
        },
      ),
    );
  }
}
