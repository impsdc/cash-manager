import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front/src/services/transaction_service.dart';
import 'package:intl/intl.dart';

/// Displays detailed information about a SampleItem.
class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({Key? key, required this.transaction}) : super(key: key);

  static const routeName = '/transaction_item';

  final Map<String, dynamic> transaction;

  @override
  _OrderDetailsViewState createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {

  List<dynamic> _products = [];

  late Future<Response> _getProducts;

  @override
  initState() {
    _getProducts = TransactionService().getTransactionProducts(widget.transaction["id"]);
    super.initState();
  }

  String _formatDate(String date) {
    DateTime format = DateTime.parse(date);
    return DateFormat('yyyy MMMM dd, kk:mm').format(format);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _formatDate(widget.transaction["transactionDate"]),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                Text("${widget.transaction["totalBill"]}€",
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 10.0),
            child: Text('Payment mode: ${widget.transaction["paymentMode"]}'),
          ),
          const SizedBox(
            height: 20.0,
          ),
          FutureBuilder<Response>(
            future: _getProducts,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Response response = snapshot.data!;
                if(response.data != null) {
                  _products = response.data;
                }
                return ListView.builder(
                  restorationId: 'productsList',
                  itemCount: _products.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> product = _products[index];
                    return ListTile(
                      title: Text(product["name"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${product["quantity"]}'),
                      trailing: Text('${product["price"]}€',
                        style: const TextStyle(fontWeight: FontWeight.w500),
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
        ],
      ),
    );
  }
}

