abstract interface class WeatherService {
  Future<WeatherData> getWeather(double latitude, double longitude);
}

typedef WeatherData = (String text, int code);

const latStorageKey = 'Lat_Storage_Key';
const longStorageKey = 'Long_Storage_Key';
