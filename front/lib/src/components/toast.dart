import 'package:flutter/material.dart';

import "../res/colors.dart";
import "../res/icons.dart";

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Mes scans',
            style: TextStyle(color: AppColors.primary),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                AppIcons.barcode,
              ),
            )
          ],
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Show MaterialBanner'),
            onPressed: () => ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: const Text('Hello, I am a Material Banner'),
                leading: const Icon(Icons.info),
                backgroundColor: Colors.yellow,
                actions: [
                  TextButton(
                    child: const Text('Dismiss'),
                    onPressed: () => ScaffoldMessenger.of(context)
                        .hideCurrentMaterialBanner(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
