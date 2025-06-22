import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:weather_wallpagers/src/controllers/wallpaper.dart';
import '../models/wallpaper.dart';

class DetailPage extends StatefulWidget {
  final Wallpaper wallpaper;

  const DetailPage({super.key, required this.wallpaper});

  @override
  State<DetailPage> createState() => _DetailState();
}

class _DetailState extends State<DetailPage> {
  String? _imagePath;
  WallpaperController c = Get.find();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.wallpaper.image.isEmpty ? null : widget.wallpaper.image;
  }

  Future<void> _onSelectChange(String newImagePath) async {
    setState(() {
      _imagePath = newImagePath;
    });

    if (newImagePath.isEmpty) {
      return;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final filename = path.basename(newImagePath);
    final saveImage = File('${appDir.path}/$filename');

    await File(newImagePath).copy(saveImage.path);

    await c.updateWallpaper(
      Wallpaper(title: widget.wallpaper.title, image: saveImage.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            WallpaperImage(imagePath: _imagePath),
            const AppIcons(),
            Positioned(
              left: 20,
              bottom: 50,
              child: Actions(onChange: _onSelectChange),
            ),
          ],
        ),
      ),
    );
  }
}

class WallpaperImage extends StatelessWidget {
  final String? imagePath;

  const WallpaperImage({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: imagePath != null
          ? Image.file(File(imagePath!), fit: BoxFit.cover)
          : Container(color: Colors.grey[300]),
    );
  }
}

class AppIcons extends StatelessWidget {
  const AppIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        'assets/images/phone-app-icons.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class Actions extends StatelessWidget {
  final void Function(String newImagePath) _onChange;
  const Actions({super.key, required void Function(String) onChange})
    : _onChange = onChange;

  Future<void> _onSelectFromGallery() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return;
    }

    _onChange(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        iconSize: 40,
        onPressed: _onSelectFromGallery,
        color: Colors.white,
        icon: Icon(Icons.picture_in_picture_alt_sharp, color: Colors.white),
      ),
    );
  }
}
