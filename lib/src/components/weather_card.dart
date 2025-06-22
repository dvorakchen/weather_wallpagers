import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_wallpagers/src/models/wallpaper.dart';

class WeatherCard extends StatelessWidget {
  final double width;
  final Wallpaper wallpaper;

  const WeatherCard({super.key, required this.width, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 100,
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        image: wallpaper.image.isNotEmpty
            ? DecorationImage(
                image: Image.file(File(wallpaper.image)).image,
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(16.0),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300]!.withValues(alpha: 0.5), // 半透明背景色
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          wallpaper.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
