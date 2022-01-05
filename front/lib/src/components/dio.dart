import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
Response? response;

Future<String?> getToken() async {
  String? token = await storage.read(key: 'TOKEN');
  return token;
}

var options = BaseOptions(
    baseUrl: dotenv.env['HOST']!,
    connectTimeout: 5000,
    receiveTimeout: 3000,
    headers: {
      'Content-Type': 'application/json',
      'authorization': 'Bearer $getToken()'
    });

Dio dio = Dio(options);
