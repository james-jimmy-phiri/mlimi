import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/services/weather_service.dart';

class WeeklyForecastScreen extends StatefulWidget {
  @override
  _WeeklyForecastScreenState createState() => _WeeklyForecastScreenState();
}

class _WeeklyForecastScreenState extends State<WeeklyForecastScreen> {
  final WeatherService weatherService = WeatherService();
  List<dynamic> forecastData = [];
  String city = "Lilongwe";

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  void fetchForecast() async {
    final data = await weatherService.getWeeklyForecast(city);
    setState(() {
      forecastData = data['list'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(title: Text('Weekly Forecast')),
      body: forecastData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : CarouselSlider.builder(
              itemCount: 7,
              itemBuilder: (context, index, realIndex) {
                final day = forecastData[index * 8]; // Taking data at 24-hour intervals
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day['dt_txt'].split(' ')[0]}', style: TextStyle(fontSize: 18)),
                      Text('${day['main']['temp']}°C', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Icon(Icons.cloud, size: 50),
                      Text('${day['weather'][0]['description'].toUpperCase()}'),
                    ],
                  ),
                );
              },
              options: CarouselOptions(height: 300, enableInfiniteScroll: false),
            ),
    );
  }
}
