import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disaster Alert',
      home: HomeScreen(),
    );
  }
}

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = "Loading...";
  String temperature = "";
  String condition = "";

  final String apiKey = "YOUR_API_KEY_HERE";

  @override
  void initState() {
    super.initState();
    getLocationAndWeather();
  }

  // ✅ FIXED LOCATION FUNCTION
  Future<void> getLocationAndWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        city = "Turn ON Location";
      });
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        city = "Permission Denied";
      });
      return;
    }

    // Get location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    fetchWeather(position.latitude, position.longitude);
  }

  // ✅ WEATHER API
  Future<void> fetchWeather(double lat, double lon) async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          city = data["name"];
          temperature = data["main"]["temp"].toString();
          condition = data["weather"][0]["main"];
        });
      } else {
        setState(() {
          city = "Weather Error";
        });
      }
    } catch (e) {
      setState(() {
        city = "Check Internet";
      });
    }
  }

  // Maps
  void openMap(String type) async {
    String url = "https://www.google.com/maps/search/$type+near+me/";
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  // YouTube
  void openYouTube(String url) async {
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(height: 30),

                Text("Disaster Alert",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),

                SizedBox(height: 10),

                Text(city,
                    style: TextStyle(color: Colors.white, fontSize: 18)),

                Icon(Icons.cloud, size: 80, color: Colors.white),

                SizedBox(height: 10),

                Text(
                  temperature.isEmpty ? "Loading..." : "$temperature °C",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),

                Text(condition,
                    style: TextStyle(color: Colors.white70)),

                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: getLocationAndWeather,
                  child: Text("Refresh Weather"),
                ),

                SizedBox(height: 15),

                ElevatedButton.icon(
                  icon: Icon(Icons.video_library),
                  label: Text("Awareness Videos"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AwarenessScreen()),
                    );
                  },
                ),

                SizedBox(height: 15),

                ElevatedButton.icon(
                  icon: Icon(Icons.phone),
                  label: Text("Emergency Contacts"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EmergencyScreen()),
                    );
                  },
                ),

                SizedBox(height: 15),

                ElevatedButton.icon(
                  icon: Icon(Icons.local_hospital),
                  label: Text("Nearby Hospitals"),
                  onPressed: () => openMap("hospital"),
                ),

                SizedBox(height: 10),

                ElevatedButton.icon(
                  icon: Icon(Icons.local_fire_department),
                  label: Text("Nearby Fire Stations"),
                  onPressed: () => openMap("fire station"),
                ),

                SizedBox(height: 10),

                ElevatedButton.icon(
                  icon: Icon(Icons.local_police),
                  label: Text("Nearby Police Stations"),
                  onPressed: () => openMap("police station"),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- AWARENESS ----------------

class AwarenessScreen extends StatelessWidget {

  void openVideo(String url) async {
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  Widget buildTile(String title, String url, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.play_circle_fill, color: color),
        title: Text(title),
        onTap: () => openVideo(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Awareness Videos")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [

          buildTile("Flood Safety Tips",
              "https://www.youtube.com/watch?v=3k6k1YB2FvE",
              Colors.blue),

          buildTile("Earthquake Safety",
              "https://www.youtube.com/watch?v=BtC9KqQ4b6c",
              Colors.orange),

          buildTile("Cyclone Safety",
              "https://www.youtube.com/watch?v=9bEo6gE3Y4w",
              Colors.red),

          buildTile("Drought Awareness (Rural)",
              "https://www.youtube.com/watch?v=7m6w0zXxH8k",
              Colors.brown),
        ],
      ),
    );
  }
}

// ---------------- EMERGENCY ----------------

class EmergencyScreen extends StatelessWidget {

  void callNumber(String number) async {
    await launchUrl(Uri.parse("tel:$number"));
  }

  Widget buildCard(
      IconData icon, String title, String number, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title),
        subtitle: Text(number),
        trailing: Icon(Icons.call),
        onTap: () => callNumber(number),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emergency Contacts")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildCard(Icons.local_police, "Police", "100", Colors.blue),
            buildCard(Icons.local_hospital, "Ambulance", "108", Colors.red),
            buildCard(Icons.fire_truck, "Fire", "101", Colors.orange),
          ],
        ),
      ),
    );
  }
}