import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_224109v/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final _indexController = TextEditingController(text: '224109V');
  final WeatherService _weatherService = WeatherService();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCached = false;

  String? _latitude;
  String? _longitude;
  String? _requestUrl;
  String? _lastUpdated;

  Map<String, dynamic>? _weatherData;

  static const String _weatherCacheKey = 'weather_data';

  void _calculateCoordinates() {
    final index = _indexController.text;
    if (index.length >= 4) {
      try {
        final firstTwo = int.parse(index.substring(0, 2));
        final nextTwo = int.parse(index.substring(2, 4));

        final lat = 5 + (firstTwo / 10.0);
        final lon = 79 + (nextTwo / 10.0);

        setState(() {
          _latitude = lat.toStringAsFixed(2);
          _longitude = lon.toStringAsFixed(2);
        });
      } catch (e) {
        setState(() {
          _latitude = null;
          _longitude = null;
          _errorMessage =
              'Invalid index format. Please use numbers for the first 4 characters.';
        });
      }
    } else {
      setState(() {
        _latitude = null;
        _longitude = null;
        _errorMessage = 'Index must be at least 4 characters long.';
      });
    }
  }

  Future<void> _fetchWeather() async {
    _calculateCoordinates();
    if (_latitude == null || _longitude == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.fetchWeather(_latitude!, _longitude!);
      setState(() {
        _weatherData = data;
        _requestUrl = data['request_url'];
        _lastUpdated = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        _isCached = false;
      });
      await _saveWeatherToCache(data);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to fetch live data: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWeatherToCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'weather': data,
      'lastUpdated': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'requestUrl': data['request_url'],
    };
    await prefs.setString(_weatherCacheKey, jsonEncode(cacheData));
  }

  Future<void> _loadWeatherFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedDataString = prefs.getString(_weatherCacheKey);
    if (cachedDataString != null) {
      final cachedData = jsonDecode(cachedDataString);
      setState(() {
        _weatherData = cachedData['weather'];
        _lastUpdated = cachedData['lastUpdated'];
        _requestUrl = cachedData['requestUrl'];
        _isCached = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWeatherFromCache();
    _indexController.addListener(_calculateCoordinates);
    _calculateCoordinates(); // Initial calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalized Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _indexController,
                decoration: const InputDecoration(
                  labelText: 'Student Index',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchWeather,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Fetch Weather'),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Coordinates:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _latitude != null && _longitude != null
                    ? '$_latitude, $_longitude'
                    : 'N/A',
              ),
              const SizedBox(height: 12),
              const Text(
                'Request URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_requestUrl ?? 'N/A', style: const TextStyle(fontSize: 10)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Last Update:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(_lastUpdated ?? 'N/A'),
                  if (_isCached)
                    const Text(
                      ' (cached)',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Current Weather',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (_weatherData != null) ...[
                Text('Temperature: ${_weatherData!['temperature']} °C'),
                const SizedBox(height: 8),
                Text('Wind Speed: ${_weatherData!['windspeed']} km/h'),
                const SizedBox(height: 8),
                Text('Weather Code: ${_weatherData!['weathercode']}'),
              ] else ...[
                const Text('Temperature: N/A'),
                const SizedBox(height: 8),
                const Text('Wind Speed: N/A'),
                const SizedBox(height: 8),
                const Text('Weather Code: N/A'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _indexController.removeListener(_calculateCoordinates);
    _indexController.dispose();
    super.dispose();
  }
}
