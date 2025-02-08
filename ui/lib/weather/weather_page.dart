import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'city_timezones.dart';
import 'package:google_fonts/google_fonts.dart';

// Define the WeatherCondition enum
enum WeatherCondition {
  thunderstorm,
  drizzle,
  rain,
  snow,
  mist,
  haze,
  clear,
  clouds,
  windy,
  hail,
  unknown,
}

// Weather model class to parse the API response
class Weather {
  final String cityName;
  final double temperature;
  final String description;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown City',
      temperature: json['main']['temp'],
      description: json['weather'][0]['description'],
    );
  }
}

// Weather service to fetch weather data from the API
class WeatherService {
  static const baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String _apiKey;

  WeatherService(this._apiKey);

  Future<Weather> getWeather(String cityName) async {
    final url = '$baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }

  // Method to get the hourly forecast
  Future<List<Weather>> getHourlyForecast(String cityName) async {
    final url = '$baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> forecastList = data['list'];

      // Map the 3-hourly forecast data to Weather objects
      return forecastList.take(5).map<Weather>((json) {
        return Weather(
          cityName: cityName,
          temperature: json['main']['temp'],
          description: json['weather'][0]['description'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }
}

// Main WeatherPage widget
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final String apiKey = 'f22260ff20f2e12a4bbaa5913217f667'; // Replace with your OpenWeatherMap API key
  final String _cityName = 'New York';
  late Future<Weather> futureWeather;
  late Future<List<Weather>> futureHourlyForecast;
  String formattedDate = DateFormat('MMMM dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    futureWeather = WeatherService(apiKey).getWeather(_cityName);
    futureHourlyForecast = WeatherService(apiKey).getHourlyForecast(_cityName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Weather>(
          future: futureWeather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final weather = snapshot.data!;
              WeatherCondition weatherCondition =
                  _mapWeatherCondition(weather.description);

              return Container(
                color: Color(0xFF0C3579),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 250,
                          child: _getWeatherIcon(weatherCondition),
                        ),
                        Column(
                          children: [
                            Text(weather.cityName.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white,
                                )),
                            const SizedBox(height: 20),
                            Text('${weather.temperature.round()} °C',
                                style: GoogleFonts.poppins(
                                    fontSize: 30, color: Colors.white)),
                            const SizedBox(height: 10),
                            Text(
                              weather.description.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 350,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Today',
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.white),
                                ),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ]),
                        ),
                        const SizedBox(height: 30),
                        FutureBuilder<List<Weather>>(
                          future: futureHourlyForecast,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              List<Weather> hourlyForecast = snapshot.data!;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  final weather = hourlyForecast[index];
                                  final DateTime time = DateTime.now().add(Duration(hours: index * 3));

                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${weather.temperature.round()} °C', // Display temperature as integer
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        _getWeatherIcon(_mapWeatherCondition(weather.description)),
                                        Text(
                                          DateFormat('HH:mm').format(time),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return const Text('No data');
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            } else {
              return const Text('No data');
            }
          },
        ),
      ),
    );
  }

  WeatherCondition _mapWeatherCondition(String description) {
    if (description.contains('thunderstorm')) {
      return WeatherCondition.thunderstorm;
    } else if (description.contains('drizzle')) {
      return WeatherCondition.drizzle;
    } else if (description.contains('rain')) {
      return WeatherCondition.rain;
    } else if (description.contains('snow')) {
      return WeatherCondition.snow;
    } else if (description.contains('mist')) {
      return WeatherCondition.mist;
    } else if (description.contains('haze')) {
      return WeatherCondition.haze;
    } else if (description.contains('clear')) {
      return WeatherCondition.clear;
    } else if (description.contains('cloud')) {
      return WeatherCondition.clouds;
    } else if (description.contains('wind')) {
      return WeatherCondition.windy;
    } else if (description.contains('hail')) {
      return WeatherCondition.hail;
    }
    return WeatherCondition.unknown;
  }

  Widget _getWeatherIcon(WeatherCondition weatherCondition) {
    String iconPath = '';
    bool isNight = _isNight();

    switch (weatherCondition) {
      case WeatherCondition.thunderstorm:
        iconPath = '../assets/icons/200.svg';
        break;
      case WeatherCondition.drizzle:
        iconPath = '../assets/icons/300.svg';
        break;
      case WeatherCondition.rain:
        iconPath = '../assets/icons/500.svg';
        break;
      case WeatherCondition.snow:
        iconPath = '../assets/icons/600.svg';
        break;
      case WeatherCondition.mist:
        iconPath = isNight ? '../assets/icons/701n.svg' : '../assets/icons/701.svg';
        break;
      case WeatherCondition.haze:
        iconPath = isNight ? '../assets/icons/711n.svg' : '../assets/icons/711.svg';
        break;
      case WeatherCondition.clear:
        iconPath = isNight ? '../assets/icons/800n.svg' : '../assets/icons/800.svg';
        break;
      case WeatherCondition.clouds:
        iconPath = isNight ? '../assets/icons/801n.svg' : '../assets/icons/801.svg';
        break;
      case WeatherCondition.windy:
        iconPath = '../assets/icons/905.svg';
        break;
      case WeatherCondition.hail:
        iconPath = '../assets/icons/906.svg';
        break;
      default:
        iconPath = '../assets/icons/800.svg';
        break;
    }
    return SvgPicture.asset(iconPath, width: 100, height: 100);
  }

  bool _isNight() {
    String cityTimeZone = cityTimeZones[_cityName] ?? 'Asia/Seoul';
    tz.Location cityLocation = tz.getLocation(cityTimeZone);
    tz.TZDateTime cityTime = tz.TZDateTime.now(cityLocation);
    int cityHour = cityTime.hour;
    return cityHour >= 18 || cityHour < 6;
  }
}

void main() {
  runApp(const MaterialApp(
    home: WeatherPage(),
  ));
}
