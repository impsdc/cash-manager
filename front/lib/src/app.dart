import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/src/cart_view.dart';
import 'package:front/src/home_view.dart';
import 'package:front/src/payment_mode_view.dart';
import 'package:front/src/res/colors.dart';

import 'order_details_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  final SettingsController settingsController;

  @override
  _AppState createState() => _AppState(settingsController: settingsController);

  static _AppState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>()!;
}

class _AppState extends State<MyApp> {
  _AppState({required this.settingsController});

  final SettingsController settingsController;
  Locale? locale;

  void changeLanguage(Locale newlocale) {
    setState(() {
      locale = newlocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Cash Manager",
          theme: ThemeData(
            fontFamily: "Avenir",
            primaryColor: AppColors.primary,
            secondaryHeaderColor: AppColors.secondary,
            appBarTheme: const AppBarTheme(color: AppColors.primaryDark),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary),
              ),
            ),
          ),
          restorationScopeId: 'app',
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fr', 'FR'),
          ],
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: AppColors.primary,
            secondaryHeaderColor: AppColors.secondary,
            appBarTheme: const AppBarTheme(color: AppColors.primaryDark),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary),
              ),
            ),
          ),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case OrderDetailsView.routeName:
                    return OrderDetailsView(
                        transaction:
                            routeSettings.arguments as Map<String, dynamic>);
                  case CartView.routeName:
                    return const CartView();
                  case PaymentModeView.routeName:
                    return const PaymentModeView();
                  default:
                    return const HomeView();
                }
              },
            );
          },
        );
      },
    );
  }
}
