import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../components/dio.dart';
import '../models/result.dart';

FlutterSecureStorage storage = const FlutterSecureStorage();

class UserService {
  Future<Result?> login(String username, String password) async {
    final data = {"username": username, "password": password};
    try {
      response = await dio.post('/authenticate', data: data);
      await storage.write(
          key: 'TOKEN', value: response!.headers["authorization"]!.first);
      await storage.write(key: 'USERNAME', value: response!.data["username"]);
      await storage.write(key: 'ROLE', value: response!.data["role"]);
      Result result = Result(true, null);
      return result;
    } on DioError catch (e) {
      print(e);
      if (e.message.contains('Connection refused')) {
        Result result = Result(false, 'Connexion refused');
        return result;
      } else if (e.message.contains('timed out')) {
        Result result = Result(false, 'Connexion time out');
        return result;
      } else if (e.response?.statusCode == 403) {
        Result result = Result(false, 'Wrong credentials');
        return result;
      } else if (e.response?.statusCode == 404) {
        Result result = Result(false, 'Wrong database url');
        return result;
      }
    }
  }

  Future<Result> logout() async {
    await storage.write(key: 'TOKEN', value: null);
    await storage.write(key: 'ROLE', value: null);
    return Result(true, null);
  }
}
