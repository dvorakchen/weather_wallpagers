class Wallpaper {
  final String title;
  String image;

  Wallpaper({required this.title, required this.image});

  Map<String, dynamic> toJson() {
    return {'title': title, 'image': image};
  }

  factory Wallpaper.fromJson(Map<String, dynamic> map) {
    return Wallpaper(title: map['title'], image: map['image']);
  }
}
