import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodeService {
  final String apiKey = 'AIzaSyDA4XxN24QtIGFGb8odLZdEydExMtkgTU8'; // Replace with your actual API key

  Future<Map<String, dynamic>> getGeocode(String address) async {
    final url =
        'https://geocode.search.hereapi.com/v1/geocode?q=$address&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return parsed JSON
      } else {
        throw Exception('Failed to load geocode: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load geocode: $error');
    }
  }
}
