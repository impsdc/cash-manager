import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/src/admin_view.dart';
import 'package:front/src/cart_view.dart';
import 'package:front/src/login_view.dart';
import 'package:front/src/models/view.dart';
import 'package:front/src/res/colors.dart';
import 'package:front/src/settings/settings_view.dart';
import 'package:front/src/transactions_view.dart';

import 'models/result.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isAuth = false;
  String? username;

  Future<Result> getToken() async {
    String? token = await storage.read(key: 'TOKEN');
    String? role = await storage.read(key: 'ROLE');
    return Result(token != null ? true : false, role);
  }

  Future<String?> getUsername() async {
    username = await storage.read(key: 'USERNAME');
    return username;
  }

  final List<View> _views = [
    View('Basket', const Icon(Icons.shopping_cart), const CartView()),
    View(
      "Transaction",
      const Icon(Icons.list),
      const TransactionsView(),
    ),
  ];

  final List<View> _adminViews = [
    View(
      "Basket",
      const Icon(Icons.shopping_cart),
      const CartView(),
    ),
    View(
      "Transaction",
      const Icon(Icons.list),
      const TransactionsView(),
    ),
    View("Admin", const Icon(Icons.person), const AdminView(), appbar: false),
  ];

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<View> currentView = _views;

    return FutureBuilder(
      future: getToken(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          Result result = snapshot.data;
          if (result.status!) {
            isAuth = true;
            if (result.message == 'ROLE_ADMIN') {
              currentView = _adminViews;
            } else {
              currentView = _views;
            }
          }
          if (isAuth) {
            return Scaffold(
              appBar: currentView[_currentPage].appbar
                  ? AppBar(
                      title: FutureBuilder(
                          future: getUsername(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return username != null
                                  ? Row(
                                      children: [
                                        Text(username! + ' | '),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .pageTitle(
                                                  currentView[_currentPage]
                                                      .title),
                                        )
                                      ],
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.pageTitle(
                                          currentView[_currentPage].title),
                                    );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          }),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.restorablePushNamed(
                                context, SettingsView.routeName);
                          },
                        ),
                      ],
                      automaticallyImplyLeading: false,
                    )
                  : null,
              body: currentView[_currentPage].view,
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                currentIndex: _currentPage,
                items: currentView
                    .map<BottomNavigationBarItem>(
                      (view) => BottomNavigationBarItem(
                        icon: view.icon,
                        label: view.title,
                      ),
                    )
                    .toList(),
                onTap: (index) => setState(() {
                  _currentPage = index;
                }),
                showUnselectedLabels: false,
              ),
            );
          }
          return const LoginView();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
