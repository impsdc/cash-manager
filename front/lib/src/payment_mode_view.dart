import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/src/services/cart_service.dart';
import 'package:nfc_manager/nfc_manager.dart';

class PaymentModeView extends StatefulWidget {
  const PaymentModeView({Key? key}) : super(key: key);

  static const routeName = '/cart/payment_mode';

  @override
  _PaymentModeViewState createState() => _PaymentModeViewState();
}

class _PaymentModeViewState extends State<PaymentModeView> {
  String _QRCodeResult = '';
  String _NFCResult = '';
  late Future<Response> getProducts;
  late Response validateCart;
  bool _isProcessing = false;

  @override
  initState() {
    getProducts = CartService().getCartProducts();
    super.initState();
  }

  void _nfcRead() {
    setState(() {
      _isProcessing = true;
    });
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      String result = await tag.data.toString();
      setState(() {
        _NFCResult = result;
      });

      try {
        validateCart = await CartService().validateCart("NFC");
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.validate_transaction),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.dismiss,
            onPressed: () => Navigator.of(context).pushNamed('transaction'),
          ),
        ));
      } on DioError catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.validate_transaction_fail),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
      }
      NfcManager.instance.stopSession();
    });
  }

  Future<void> _scanQR() async {
    String QRCodeRes;

    try {
      QRCodeRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', AppLocalizations.of(context)!.cancel, true, ScanMode.QR);
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
    if (QRCodeRes == '-1') return;

    setState(() {
      _QRCodeResult = QRCodeRes;
    });

    try {
      validateCart = await CartService().validateCart("QR");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.validate_transaction),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ));
    } on DioError catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.validate_transaction_fail),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.payment_title),
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FutureBuilder(
                      future: getProducts,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          Response result = snapshot.data;
                          num total = 0;
                          result.data.asMap().forEach((index, value) =>
                              total += value["price"] * value["quantity"]);

                          return Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Text(
                              "${total.toStringAsFixed(2)}€",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    AppLocalizations.of(context)!.payment_method,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () => _nfcRead(),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(Icons.nfc, size: 16),
                              ),
                              TextSpan(
                                text: " NFC",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () => _scanQR(),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(Icons.qr_code, size: 16),
                              ),
                              TextSpan(
                                text: " QR Code",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              _isProcessing
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Column(
                        children: const [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          Text(
                              "Please stick your card on the back of the phone")
                        ],
                      )),
                    )
                  : Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _NFCResult.isNotEmpty ||
                                  _QRCodeResult.isNotEmpty
                              ? Text(
                                  AppLocalizations.of(context)!.payment_success,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : const SizedBox()),
                    )
            ],
          )
        ],
      ),
    );
  }
}
