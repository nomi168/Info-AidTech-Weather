// ignore_for_file: library_private_types_in_public_api, file_names, prefer_const_declarations, unused_local_variable, unused_field, unused_element, prefer_final_fields

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:weather/Weather/WeatherDashboard.dart';

// ignore: use_key_in_widget_constructors
class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
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
                child: ListView(
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0),
                        child: Image.network(
                          'https://cdn3d.iconscout.com/3d/premium/thumb/cloudy-sun-7018462-5704797.png',
                          width: 20.w,
                          height: 20.h,
                        )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(13.w, 3.h, 10.w, 0),
                      child: Material(
                        elevation: 20.0,
                        shadowColor: Colors.purpleAccent,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            fillColor: Colors.white10,
                            filled: true,
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.purple,
                            ),
                            hintText: 'Enter Your Location',
                            hoverColor: Colors.purple,
                            focusColor: Colors.purpleAccent,
                            contentPadding: const EdgeInsets.all(10.0),
                            counterText: AutofillHints.location,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Adjust the radius as needed
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(23.w, 5.h, 23.w, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 20.0,
                          backgroundColor: Colors.white,
                          shadowColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          String loc = _locationController.text;
                          if (_locationController.text.isNotEmpty) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => WeatherForerest(
                                  loc: loc,
                                ),
                              ),
                            );
                            _locationController.clear();
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Stack(
                                  children: [
                                    // Background blur effect
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    // AlertDialog
                                    AlertDialog(
                                      title: const Text(
                                          "Please Fill Required Fields"),
                                      content:
                                          const Text("Location are required."),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Get Weather'),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
