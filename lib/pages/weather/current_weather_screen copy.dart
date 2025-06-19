import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/pages/weather/weekly_forecast_screen.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:mlimi/services/weather_service.dart';

class CurrentWeatherScreen extends StatefulWidget {
  @override
  _CurrentWeatherScreenState createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  String city = "Lilongwe";

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  void fetchWeather() async {
    final data = await weatherService.getWeatherData(city);
    setState(() {
      weatherData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchWeather,
          ),
        ],
      ),
      body: weatherData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${weatherData!['name']}, ${weatherData!['sys']['country']}',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${weatherData!['main']['temp']}°C',
                  style: GoogleFonts.poppins(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                BoxedIcon(
                  WeatherIcons.day_sunny,
                  size: 80,
                  color: Colors.orange,
                ),
                SizedBox(height: 20),
                Text(
                  '${weatherData!['weather'][0]['description'].toUpperCase()}',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeeklyForecastScreen(),
                      ),
                    );
                  },
                  child: Text('View Weekly Forecast'),
                ),
              ],
            ),
    );
  }
}
