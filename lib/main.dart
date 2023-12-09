// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
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
    // timer = Timer.periodic(Duration(seconds: 6), (timer) {
    //   // ignore: avoid_print
    //
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (context) => WeatherScreen(),
    //     ),
    //   );
    //   timer.cancel();
    // });
    checkInternet();
  }

  Future<void> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // If no internet, show a dialog to allow internet access
      showNoInternetDialog();
    } else {
      // If internet is available, start the timer for SplashScreen
      timer = Timer.periodic(const Duration(seconds: 6), (timer) {
        // Check if the timer is still active
        if (timer.isActive) {
          // Cancel the timer before navigating to the WeatherScreen
          timer.cancel();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => WeatherScreen(),
            ),
          );
        }
      });
    }
  }

  void showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Disable the default behavior of the back button
            return false;
          },
          child: AlertDialog(
            title: const Text("No Internet"),
            content:
                const Text("Please allow internet access to use this app."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Optionally, you can open the device's internet settings here
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
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
