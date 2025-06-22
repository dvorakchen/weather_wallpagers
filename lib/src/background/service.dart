import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:weather_wallpagers/src/controllers/wallpaper.dart';
import 'package:weather_wallpagers/src/models/wallpaper.dart';
import 'package:weather_wallpagers/src/services/seniverse_weather.dart';
import 'package:weather_wallpagers/src/services/weather.dart';
import 'package:weather_wallpagers/src/utils/location.dart';
import 'package:workmanager/workmanager.dart';

void initializeService() async {
  Workmanager().initialize(
    callbackDispatcher, // 回调函数
    isInDebugMode: true, // Debug 模式下任务会频繁执行
  );

  Workmanager().registerPeriodicTask(
    "1", // 任务 ID
    "fetchWeather", // 任务名称
    frequency: Duration(minutes: 15),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  Workmanager().executeTask((task, inputData) async {
    print("Enter Workmanager Task\n");
    final box = GetStorage();
    var lat = box.read(latStorageKey);
    var long = box.read(longStorageKey);

    if (lat == null || long == null) {
      final location = await determinePosition();
      if (location == null) {
        return Future.error(Exception("Determine Position Failed"));
      }

      lat = location.latitude;
      long = location.longitude;

      box.write(latStorageKey, lat);
      box.write(longStorageKey, lat);
    }
    await dotenv.load(fileName: ".env");
    var key = dotenv.env['SENIVERSE_KEY'] ?? '';
    WeatherService weatherService = SeniverseWeather(key, http.Client());
    var (text, _) = await weatherService.getWeather(lat!, long!);

    final wallpapers = _fetchWallpapers();

    Wallpaper? wallpaper;
    if (text.contains("晴")) {
      wallpaper = wallpapers.firstWhereOrNull(
        (wp) => wp.title == '晴天' && wp.image.isNotEmpty,
      );
    } else if (text.contains('雨')) {
      wallpaper = wallpapers.firstWhereOrNull(
        (wp) => wp.title == '雨天' && wp.image.isNotEmpty,
      );
    } else if (text.contains('阴') || text.contains('雾') || text.contains('云')) {
      wallpaper = wallpapers.firstWhereOrNull(
        (wp) => wp.title == '阴天' && wp.image.isNotEmpty,
      );
    } else if (text.contains('雪')) {
      wallpaper = wallpapers.firstWhereOrNull(
        (wp) => wp.title == '雪天' && wp.image.isNotEmpty,
      );
    }

    if (wallpaper == null) {
      return Future.value(true);
    }

    final wpm = WallpaperManagerFlutter();
    var res = await wpm.setWallpaper(
      File(wallpaper.image),
      WallpaperManagerFlutter.bothScreens,
    );

    print("Auto set Wallpaper result: $res\n");

    return Future.value(true); // 返回 true 表示任务完成
  });
}

List<Wallpaper> _fetchWallpapers() {
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

    return list;
  }

  list = json.map((item) {
    return Wallpaper.fromJson(item);
  }).toList();

  return list;
}
