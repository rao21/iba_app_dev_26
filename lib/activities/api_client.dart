import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iba_app_dev_26/activities/error.dart';
import 'package:iba_app_dev_26/activities/models.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw ServerException('Server returned ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw NoInternetException('Request timed out. Check your connection');
    } on FormatException {
      throw DataParsingException('Invalid data received from server');
    }
  }
}
