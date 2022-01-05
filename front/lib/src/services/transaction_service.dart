import 'package:dio/dio.dart';
import 'package:front/src/models/product.dart';
import 'package:front/src/services/api_service.dart';
import '../components/dio.dart';

class TransactionService {
  Future<Response> getTransactions() async {
    response = await APIService().get('/user/transactions');
    return response!;
  }

  Future<Response> getTransaction(int transactionId) async {
    response = await APIService().get('/user/transactions/$transactionId');
    return response!;
  }

  Future<Response> getTransactionProducts(int transactionId) async {
    response = await APIService().get('/user/transactions/$transactionId/products');
    return response!;
  }
}
