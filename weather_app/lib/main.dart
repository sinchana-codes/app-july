import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Weather',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF276EF1)),
        scaffoldBackgroundColor: const Color(0xFFF3F7FF),
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherData {
  final String city;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;

  const WeatherData({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  factory WeatherData.fromJson(String city, Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherData(
      city: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num).toInt() == 1,
    );
  }

  String get condition {
    if (weatherCode == 0) return 'Clear sky';
    if ([1, 2, 3].contains(weatherCode)) return 'Partly cloudy';
    if ([45, 48].contains(weatherCode)) return 'Foggy';
    if ([51, 53, 55, 56, 57].contains(weatherCode)) return 'Drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(weatherCode)) return 'Rain';
    if ([71, 73, 75, 77, 85, 86].contains(weatherCode)) return 'Snow';
    if ([95, 96, 99].contains(weatherCode)) return 'Thunderstorm';
    return 'Variable conditions';
  }

  String get icon {
    if ([0, 1].contains(weatherCode)) return isDay ? '☀️' : '🌙';
    if ([2, 3].contains(weatherCode)) return '⛅';
    if ([45, 48].contains(weatherCode)) return '🌫️';
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(weatherCode)) return '🌧️';
    if ([71, 73, 75, 77, 85, 86].contains(weatherCode)) return '❄️';
    if ([95, 96, 99].contains(weatherCode)) return '⛈️';
    return '🌤️';
  }
}

class WeatherService {
  Future<WeatherData> fetchWeather(String city) async {
    final geocodingUri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {'name': city, 'count': '1', 'language': 'en', 'format': 'json'},
    );

    final geoResponse = await http.get(geocodingUri).timeout(const Duration(seconds: 12));
    if (geoResponse.statusCode != 200) {
      throw Exception('Could not find the city. Please try again.');
    }

    final geoJson = jsonDecode(geoResponse.body) as Map<String, dynamic>;
    final results = geoJson['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw Exception('City not found. Check the spelling and try again.');
    }

    final place = results.first as Map<String, dynamic>;
    final latitude = (place['latitude'] as num).toDouble();
    final longitude = (place['longitude'] as num).toDouble();
    final displayName = place['name'] as String? ?? city;
    final admin = place['admin1'] as String?;
    final country = place['country'] as String?;
    final fullName = [displayName, admin, country]
        .where((part) => part != null && part.isNotEmpty)
        .toSet()
        .join(', ');

    final weatherUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
        'timezone': 'auto',
      },
    );

    final weatherResponse = await http.get(weatherUri).timeout(const Duration(seconds: 12));
    if (weatherResponse.statusCode != 200) {
      throw Exception('Weather service is unavailable. Please try again later.');
    }

    final weatherJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
    return WeatherData.fromJson(fullName, weatherJson);
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final _controller = TextEditingController(text: 'Bengaluru');
  final _service = WeatherService();
  WeatherData? _weather;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      setState(() => _error = 'Please enter a city name.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.fetchWeather(city);
      if (!mounted) return;
      setState(() {
        _weather = result;
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _error = message.contains('TimeoutException') || message.contains('SocketException')
            ? 'Network error. Check your internet connection.'
            : message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Now', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3F7FF),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Weather at a glance',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Search any city to see live weather conditions.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchWeather(),
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      prefixIcon: const Icon(Icons.location_city),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _loading ? null : _searchWeather,
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorCard(message: _error!, onRetry: _searchWeather)
            else if (_weather != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF276EF1), Color(0xFF68B7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF276EF1).withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70),
                    const SizedBox(height: 4),
                    Text(_weather!.city,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Text(_weather!.icon, style: const TextStyle(fontSize: 66)),
                    Text('${_weather!.temperature.round()}°C',
                        style: const TextStyle(color: Colors.white, fontSize: 58, fontWeight: FontWeight.bold)),
                    Text(_weather!.condition,
                        style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Feels like ${_weather!.feelsLike.round()}°C',
                        style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _InfoCard(icon: Icons.water_drop, title: 'Humidity', value: '${_weather!.humidity}%', color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _InfoCard(icon: Icons.air, title: 'Wind speed', value: '${_weather!.windSpeed.toStringAsFixed(1)} km/h', color: Colors.teal)),
                ],
              ),
              const SizedBox(height: 18),
              const Text('About this project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Live weather data is retrieved from the Open-Meteo API using HTTP GET requests and parsed from JSON.',
                  style: TextStyle(color: Colors.black54, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: Colors.red.shade400, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
