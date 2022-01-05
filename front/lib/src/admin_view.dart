import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'components/dialogs/confirm_dialog.dart';
import 'components/dialogs/product_dialogs.dart';
import 'services/product_service.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  static const routeName = '/admin';

  @override
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  late Future<Response> getProducts;

  @override
  initState() {
    getProducts = ProductService().getProduct();
    super.initState();
  }

  List<dynamic> articles = [];

  Future scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666',
          AppLocalizations.of(context)!.cancel, true, ScanMode.BARCODE);
    } on PlatformException {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fail_scan),
        ),
      );
      return;
    }
    if (!mounted) return;
    if (barcodeScanRes == '-1') return;

    await showDialog(
      context: context,
      builder: (context) {
        return AddProductDialog(barcode: barcodeScanRes);
      },
    );

    setState(() {
      getProducts = ProductService().getProduct();
    });
  }

  Future _onDeleteProduct(Map<String, dynamic> product) async {
    if (await confirmDeleteProductDialog(context,
        content:
            "Are you sure you want to delete the product ${product["name"]}")) {
      try {
        await ProductService().deleteProduct(32525);
      } on DioError catch (e) {
        print(e.message);
      }

      setState(() {
        getProducts = ProductService().getProduct();
      });
    }
  }

  Future _onEditProduct(Map<String, dynamic> product) async {
    await showDialog(
      context: context,
      builder: (context) {
        return EditProductDialog(product: product);
      },
    );

    setState(() {
      getProducts = ProductService().getProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FutureBuilder<Response>(
            future: getProducts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Response response = snapshot.data!;
                if (response.data != null) {
                  articles = response.data["content"];
                }
                return ListView.builder(
                  restorationId: 'productsList',
                  itemCount: articles.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> product = articles[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                      title: Text(product["name"]),
                      subtitle: Text(AppLocalizations.of(context)!
                          .quantity(product["quantity"])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${product["price"]}€'),
                          const SizedBox(width: 8.0),
                          InkWell(
                            child: const Icon(Icons.edit, color: Colors.grey),
                            onTap: () => _onEditProduct(product),
                          ),
                          const SizedBox(width: 8.0),
                          InkWell(
                            child: const Icon(Icons.delete, color: Colors.red),
                            onTap: () => _onDeleteProduct(product),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () => scanBarcodeNormal(),
            child: Text(AppLocalizations.of(context)!.admin_add_article),
          ),
        ),
      ],
    );
  }
}
