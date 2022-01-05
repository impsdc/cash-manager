import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/src/res/colors.dart';
import '../models/result.dart';
import '../services/user_service.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {

    _logout(context) async {
      Result response = await UserService().logout();
      if (response.status!) {
        Navigator.of(context).pushNamed('home');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting_title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Theme.of(context).cardColor,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.theme_mode),
                            Row(
                              children: [
                                const Icon(Icons.dark_mode),
                                Switch(
                                  activeColor: AppColors.primary,
                                  activeTrackColor: AppColors.primaryDark,
                                  value:
                                  controller.themeMode == ThemeMode.light,
                                  onChanged: (isLight) {
                                    ThemeMode newTheme = isLight
                                        ? ThemeMode.light
                                        : ThemeMode.dark;
                                    controller.updateThemeMode(newTheme);
                                  },
                                ),
                                const Icon(Icons.light_mode),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(AppColors.red)),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ),
        ],
      ),
    );
  }
}
