import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:weather_wallpagers/src/services/seniverse_weather.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  test('Get Seniverse Weather', () async {
    const key = 'fake_key';
    const lat = 0.0, long = 0.0;

    final uri = Uri(
      scheme: 'https', // 协议
      host: 'api.seniverse.com', // 域名
      path: '/v3/weather/now.json', // 路径
      queryParameters: {
        'key': key,
        'location': '$lat:$long',
        'language': 'zh-Hans',
        'unit': 'c',
      },
    );

    // Mock the http client
    var res = Future.value(
      http.Response(
        jsonEncode({
          'results': [
            {
              'now': {'text': '晴', 'code': '100'},
            },
          ],
        }),
        200,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        },
      ),
    );
    final client = MockClient();
    when(() => client.get(uri)).thenAnswer((_) => res);

    final weather = SeniverseWeather(key, client);
    final (text, code) = await weather.getWeather(lat, long);
    expect(text, '晴');
    expect(code, 100);
  });
}
