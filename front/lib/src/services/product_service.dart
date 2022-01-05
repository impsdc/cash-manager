import 'package:dio/dio.dart';
import 'package:front/src/models/product.dart';
import 'package:front/src/services/api_service.dart';
import '../components/dio.dart';

class ProductService {
  Future<Response> getProduct() async {
    response = await APIService().get('/products');
    return response!;
  }

  Future<Response> addProduct(Map<String, dynamic> product) async {
    response = await APIService().post('/products',
      data: product,
    );
    return response!;
  }

  Future<Response> editProduct( int productId, Map<String, dynamic> product) async {
    response = await APIService().put('/products/$productId',
      data: product,
    );
    return response!;
  }

  Future<Response> deleteProduct(int productId) async {
    response = await APIService().delete('/products/$productId');
    return response!;
  }
}
