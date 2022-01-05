import 'package:dio/dio.dart';
import 'package:front/src/services/api_service.dart';

import '../components/dio.dart';

class CartService {
  Future<Response> getCart() async {
    response = await APIService().get('/cart');
    return response!;
  }

  Future<Response> getCartProducts() async {
    response = await APIService().get('/cart/products');
    return response!;
  }

  Future<Response> addProduct(String code) async {
    response = await APIService().post('/cart/products', data: {"code": code});
    return response!;
  }

  Future<Response> validateCart(String mode) async {
    response =
        await APIService().post('/cart/validate', data: {"payment_mode": mode});
    return response!;
  }

  Future<Response> deleteProduct(int productId) async {
    response = await APIService().delete('/cart/products/$productId');
    return response!;
  }
}
