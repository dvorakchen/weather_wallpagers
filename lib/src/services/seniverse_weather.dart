import 'dart:convert';
import 'weather.dart';
import 'package:http/http.dart' as http;

class SeniverseWeather implements WeatherService {
  final String _key;
  final http.Client _client;
  const SeniverseWeather(this._key, this._client);

  @override
  Future<WeatherData> getWeather(double latitude, double longitude) async {
    final uri = Uri(
      scheme: 'https', // 协议
      host: 'api.seniverse.com', // 域名
      path: '/v3/weather/now.json', // 路径
      queryParameters: {
        'key': _key,
        'location': '$latitude:$longitude',
        'language': 'zh-Hans',
        'unit': 'c',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var results = data['results'] as List;
      if (results.isEmpty) {
        throw Exception('Weather no results found');
      }

      var result = results[0];
      String text = result['now']['text'];
      var code = int.parse(result['now']['code'].toString());

      return (text, code);
    }
    throw UnimplementedError('SeniverseWeather.getWeather is not implemented');
  }
}
