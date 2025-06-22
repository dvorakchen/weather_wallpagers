import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weather_wallpagers/src/background/service.dart';
import 'package:weather_wallpagers/src/components/detail_page.dart';
import 'package:weather_wallpagers/src/components/weather_card.dart';
import 'package:weather_wallpagers/src/controllers/wallpaper.dart';
import 'package:weather_wallpagers/src/components/weather_bar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '天气变化壁纸',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(title: '天气变化壁纸'),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;
  HomePage({super.key, required this.title});

  final WallpaperController c = Get.put(
    WallpaperController(client: http.Client()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [WeatherBar(), SizedBox(height: 30), WallpaperList()],
      ),
    );
  }
}

class WallpaperList extends StatelessWidget {
  final WallpaperController c = Get.find();
  WallpaperList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.90;

    return Center(
      child: Obx(() {
        final list = c.wallpapers.map((wallpaper) {
          return InkWell(
            onTap: () {
              Get.to(() => DetailPage(wallpaper: wallpaper));
            },
            child: WeatherCard(width: boxWidth, wallpaper: wallpaper),
          );
        }).toList();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: list,
        );
      }),
    );
  }
}
