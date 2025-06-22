import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_wallpagers/src/controllers/wallpaper.dart';

class WeatherBar extends StatelessWidget {
  WeatherBar({super.key});

  final WallpaperController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),

      child: Obx(
        () => Text('当前天气：${c.currentWeather}', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
