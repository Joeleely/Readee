import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:readee_app/features/starter/return.dart';
import 'package:readee_app/features/starter/unavailable.dart';
import 'package:readee_app/widget/bottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('isFirstTime') ?? true;

    try {
      Position position = await _determinePosition();
      double latitude = position.latitude;
      double longitude = position.longitude;

      print('User Latitude: $latitude');
      print('User Longitude: $longitude');

      bool isInThailand = latitude >= 5.5 &&
          latitude <= 20.5 &&
          longitude >= 97.3 &&
          longitude <= 105.6;

      print('Is user in Thailand: $isInThailand');

      if (isInThailand) {
        if (isFirstTime) {
          await prefs.setBool('isFirstTime', true);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ReadeeNavigationBar(
                    userId: 2,
                    initialTab: 0,
                  )),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isFirstTime
                ? UnavailableScreen()
                : ReturningUserRestrictedScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LocationErrorScreen(errorMessage: e.toString()),
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Permissions are granted; continue accessing the position.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LocationErrorScreen extends StatelessWidget {
  final String errorMessage;

  LocationErrorScreen({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
