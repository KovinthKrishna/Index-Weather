import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchWeather(
    String latitude,
    String longitude,
  ) async {
    final url =
        '$_baseUrl?latitude=$latitude&longitude=$longitude&current_weather=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('current_weather')) {
        // Add the request URL to the data we return
        final result = Map<String, dynamic>.from(data['current_weather']);
        result['request_url'] = url;
        return result;
      } else {
        throw Exception('Invalid data format from API.');
      }
    } else {
      throw Exception(
        'Failed to load weather data. Status code: ${response.statusCode}',
      );
    }
  }
}
