import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mlimi/constants/color.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '86b605e792245895c0d72e3ed18bf1cc';
  Map<String, dynamic>? weatherData;
  String city = "Lilongwe";
  bool locationFailed = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherByLocation();
  }

  Future<void> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body);
        locationFailed = false;
      });
    } else {
      setState(() {
        locationFailed = true;
      });
    }
  }

  Future<void> fetchWeatherByLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          locationFailed = false;
        });
      } else {
        setState(() {
          locationFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        locationFailed = true;
      });
    }
  }

  String getWeatherIcon(String? iconCode) {
    if (iconCode == null) return "assets/icons/cloudy.svg";
    return "https://openweathermap.org/img/wn/$iconCode@2x.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // if (locationFailed)
              //   Column(
              //     children: [
              //       Text("Geolocation failed, use search",
              //           style: GoogleFonts.poppins(
              //               fontSize: 16, color: Colors.red)),
              //       SizedBox(height: 10),
              //       IconButton(
              //         icon: Icon(Icons.refresh),
              //         onPressed: fetchWeatherByLocation,
              //       ),
              //     ],
              //   ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter city name",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      fetchWeather(city);
                    },
                  ),
                ),
                onChanged: (value) => city = value,
              ),
              SizedBox(height: 20),
              if (weatherData != null) ...[
                Text(
                  '${weatherData!['name']}, ${weatherData!['sys']['country']}',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Image.network(
                    getWeatherIcon(weatherData!['weather'][0]['icon'])),
                Text(
                  '${weatherData!['main']['temp']}°C',
                  style: GoogleFonts.poppins(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${weatherData!['weather'][0]['description'].toUpperCase()}',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 30),

                Card(
                  color: Colors.black.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Weather Details",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Divider(color: Colors.white),

                        // Weather Details with Icons
                        _buildDetailRow(Icons.thermostat, "Minimum Temperature",
                            "${weatherData!['main']['temp_min']}°C"),
                        _buildDetailRow(Icons.thermostat, "Maximum Temperature",
                            "${weatherData!['main']['temp_max']}°C"),
                        _buildDetailRow(FontAwesomeIcons.droplet, "Humidity",
                            "${weatherData!['main']['humidity']}%"),
                        _buildDetailRow(FontAwesomeIcons.wind, "Wind Speed",
                            "${weatherData!['wind']['speed']} m/s"),
                        _buildDetailRow(
                            FontAwesomeIcons.temperatureHalf,
                            "Pressure",
                            "${weatherData!['main']['pressure']} hPa"),
                        _buildDetailRow(FontAwesomeIcons.eye, "Visibility",
                            "${weatherData!['visibility']} meters"),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Sunrise & Sunset Card
                Card(
                  color: Colors.black.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sunrise Column
                        Column(
                          children: [
                            Icon(FontAwesomeIcons.solidSun,
                                color: Colors.orangeAccent, size: 30),
                            SizedBox(height: 8),
                            Text("Sunrise",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            Text(
                              "${DateTime.fromMillisecondsSinceEpoch(weatherData!['sys']['sunrise'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(weatherData!['sys']['sunrise'] * 1000).minute}",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),

                        // Sunset Column
                        Column(
                          children: [
                            Icon(FontAwesomeIcons.solidMoon,
                                color: Colors.deepOrangeAccent, size: 30),
                            SizedBox(height: 8),
                            Text("Sunset",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            Text(
                              "${DateTime.fromMillisecondsSinceEpoch(weatherData!['sys']['sunset'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(weatherData!['sys']['sunset'] * 1000).minute}",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each row with an icon
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
          Spacer(),
          Text(value,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
