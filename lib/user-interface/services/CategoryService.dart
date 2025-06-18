import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  final String baseUrl = "https://insidecasa.me/api";

  Future<Map<String, dynamic>> getCategoryDetail(int id) async {
    final url = Uri.parse('$baseUrl/categories/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur HTTP ${response.statusCode} – ${response.body}");
    }
  }
}
