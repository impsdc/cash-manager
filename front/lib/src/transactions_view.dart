import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:front/src/services/transaction_service.dart';
import 'package:intl/intl.dart';

import 'order_details_view.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({Key? key}) : super(key: key);

  static const routeName = '/transaction';

  @override
  _TransactionsViewState createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  List<dynamic> _transactions = [];

  late Future<Response> _getTransactions;

  @override
  initState() {
    _getTransactions = TransactionService().getTransactions();
    super.initState();
  }

  String _formatDate(String date) {
    DateTime format = DateTime.parse(date);
    return DateFormat('yyyy MMMM dd, kk:mm').format(format);
  }

  @override
  Widget build(BuildContext context) {
    const assetImage = 'assets/svg/cart_empty.svg';
    bool isEmpty = true;

    return FutureBuilder<Response>(
      future: _getTransactions,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Response response = snapshot.data!;
          if (response.data != null) {
            _transactions = response.data["content"];
            if (_transactions.isNotEmpty) {
              isEmpty = false;
            }
          }
          return isEmpty
              ? Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 80, bottom: 20),
                        child: SvgPicture.asset(
                          assetImage,
                          semanticsLabel: "Cart empty",
                          allowDrawingOutsideViewBox: true,
                        ),
                      ),
                    ),
                    Text(AppLocalizations.of(context)!.empty_transaction)
                  ],
                )
              : ListView.builder(
                  restorationId: 'transactionsListView',
                  itemCount: _transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final transaction = _transactions[index];

                    return ListTile(
                      title: Text(_formatDate(transaction["transactionDate"])),
                      subtitle: Text('mode: ${transaction["paymentMode"]}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('${transaction["totalBill"]}€'),
                      ),
                      onTap: () {
                        Navigator.restorablePushNamed(
                          context,
                          OrderDetailsView.routeName,
                          arguments: transaction,
                        );
                      },
                    );
                  },
                );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
