import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather/Weather/Weather.dart';

void main() {
  // ignore: prefer_const_constructors
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, home: SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int timerCount = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    // ignore: prefer_const_constructors
    timer = Timer.periodic(Duration(seconds: 6), (timer) {
      // ignore: avoid_print

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WeatherScreen(),
        ),
      );
      timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 89, 68, 203),
                Color.fromARGB(255, 60, 76, 160),
                Color.fromARGB(159, 233, 213, 213)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
                    child: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/4052/4052984.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    'Weather App',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          )),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
