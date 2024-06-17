import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> fetchFromApi(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}
Future<Map<String, dynamic>> FromApi(String url, {Map<String, String>? queryParameters}) async {
  final fullUrl = Uri.parse(url).replace(queryParameters: queryParameters);
  final response = await http.get(fullUrl);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}
