import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:weather_wallpagers/src/global.dart';
import 'package:weather_wallpagers/src/models/wallpaper.dart';
import 'package:weather_wallpagers/src/services/seniverse_weather.dart';
import 'package:weather_wallpagers/src/services/weather.dart';
import 'package:weather_wallpagers/src/utils/location.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

const weatherWallpapersStorageKey = 'weather_wallpapers_storage_key';

class WallpaperController extends GetxController {
  final http.Client client;

  WallpaperController({required this.client});

  var currentWeather = '获取中'.obs;
  var wallpapers = [
    Wallpaper(title: '晴天', image: ''),
    Wallpaper(title: '阴天', image: ''),
    Wallpaper(title: '雨天', image: ''),
    Wallpaper(title: '雪天', image: ''),
  ].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _fetchWeather().then((data) {
      final (text, _) = data;
      currentWeather.value = text;
    });

    _fetchWallPapers().then((list) {
      wallpapers.value = list;
    });
  }

  Future<WeatherData> _fetchWeather() async {
    var data = await determinePosition();
    if (data == null) {
      return ('', 0);
    }

    final box = GetStorage();
    await box.write(latStorageKey, data.latitude);
    await box.write(longStorageKey, data.longitude);

    currentLat = data.latitude ?? 0.0;
    currentLong = data.longitude ?? 0.0;

    var key = dotenv.env['SENIVERSE_KEY'] ?? '';
    WeatherService weatherService = SeniverseWeather(key, http.Client());
    var weatherData = await weatherService.getWeather(
      data.latitude!,
      data.longitude!,
    );

    return weatherData;
  }

  Future<List<Wallpaper>> _fetchWallPapers() async {
    final box = GetStorage();
    List<dynamic>? json = box.read(weatherWallpapersStorageKey);

    List<Wallpaper> list;
    if (json == null || json.length != 4) {
      list = [
        Wallpaper(title: '晴天', image: ''),
        Wallpaper(title: '阴天', image: ''),
        Wallpaper(title: '雨天', image: ''),
        Wallpaper(title: '雪天', image: ''),
      ];
      await box.write(
        weatherWallpapersStorageKey,
        list.map((item) => item.toJson()).toList(),
      );

      return list;
    }

    list = json.map((item) {
      return Wallpaper.fromJson(item);
    }).toList();

    return list;
  }

  Future<void> updateWallpaper(Wallpaper newWallpaper) async {
    var index = wallpapers.indexWhere((w) {
      return w.title == newWallpaper.title;
    });

    if (index == -1) {
      return;
    }

    wallpapers[index] = newWallpaper;

    final box = GetStorage();
    await box.write(
      weatherWallpapersStorageKey,
      wallpapers.map((item) => item.toJson()).toList(),
    );

    final wpm = WallpaperManagerFlutter();
    await wpm.setWallpaper(
      File(newWallpaper.image),
      WallpaperManagerFlutter.bothScreens,
    );
  }
}
