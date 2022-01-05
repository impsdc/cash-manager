import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:front/src/payment_mode_view.dart';
import 'package:front/src/res/colors.dart';
import 'package:front/src/res/icons.dart';
import 'package:front/src/services/cart_service.dart';

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  static const routeName = '/cart';

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  List<dynamic> articles = [];
  late Future<String?> usernameStorage;
  late Response addProducts;
  late Future<Response> getProducts;
  late Response deleteProduct;
  bool isEmpty = true;

  @override
  initState() {
    getProducts = CartService().getCartProducts();
    super.initState();
  }

  Future<void> scanBarcodeNormal() async {
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

    await handleBarCode(barcodeScanRes);
  }

  Future<void> handleBarCode(barcodeScanRes) async {
    try {
      addProducts = await CartService().addProduct(barcodeScanRes);
      setState(() {
        getProducts = CartService().getCartProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.product_added_cart),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ));
      return;
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.scan_unknown),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
        return;
      } else if (e.response?.statusCode == 422) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.not_enough_quantity),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
        return;
      }
    }
  }

  Future<void> _onRemoveProduct(product) async {
    try {
      deleteProduct = await CartService().deleteProduct(product);
      setState(() {
        getProducts = CartService().getCartProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.cart_product_delete),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ));
      return;
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.scan_unknown),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const assetImage = 'assets/svg/cart_empty.svg';

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
                width: double.infinity,
                child: FutureBuilder(
                    future: getProducts,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        Response result = snapshot.data;
                        if (result.data.length != 0) {
                          isEmpty = false;
                          articles = result.data;
                        } else {
                          isEmpty = true;
                        }

                        return isEmpty
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 80, bottom: 20),
                                    child: SvgPicture.asset(
                                      assetImage,
                                      semanticsLabel: "Cart empty",
                                      allowDrawingOutsideViewBox: true,
                                    ),
                                  ),
                                  Text(AppLocalizations.of(context)!.empty_cart)
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ListView.builder(
                                      restorationId: 'cartProductsList',
                                      itemCount: articles.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Image.network(
                                                  articles[index]['imgUrl'])),
                                          title: Text(
                                              "${articles[index]['name']}"),
                                          subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .quantity(articles[index]
                                                      ['quantity'])),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  '${(articles[index]["price"] * articles[index]['quantity']).toStringAsFixed(2)}€'),
                                              const SizedBox(width: 8.0),
                                              InkWell(
                                                child: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onTap: () => _onRemoveProduct(
                                                    articles[index]["id"]),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }))
          ],
        ),
        Stack(
          children: [
            Positioned(
              right: 100,
              bottom: 18,
              left: 100,
              child: ElevatedButton(
                onPressed: () => Navigator.restorablePushNamed(
                    context, PaymentModeView.routeName),
                child: Text(AppLocalizations.of(context)!.payment_button),
              ),
            ),
          ],
        ),
        Stack(children: [
          Positioned(
              right: 20.0,
              bottom: 20.0,
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(
                    AppIcons.barcode,
                    color: AppColors.white,
                  ),
                  onPressed: () => scanBarcodeNormal(),
                ),
              )),
        ])
      ],
    );
  }
}
