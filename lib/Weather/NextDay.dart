// ignore_for_file: unnecessary_string_interpolations, prefer_adjacent_string_concatenation, avoid_print, unnecessary_brace_in_string_interps, file_names, sized_box_for_whitespace, avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_declarations, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:weather/Weather/Weather.dart';

class NextDays extends StatefulWidget {
  final int tempCelsius1;
  final String weatherDescription;
  final String loc;
  const NextDays(
      {super.key,
      required this.tempCelsius1,
      required this.weatherDescription,
      required this.loc});

  @override
  State<NextDays> createState() => _NextDaysState();
}

class _NextDaysState extends State<NextDays> {
  int tem = 0;
  String dis = '';
  String _weatherData = '';
  String Location = '';
  String weatherDescription = '';
  int tempCelsius1 = 0;
  int temrealfeel = 0;
  int air = 0;
  int vis = 0;
  int hum = 0;
  @override
  void initState() {
    super.initState();
    tem = widget.tempCelsius1;
    dis = widget.weatherDescription;
    Location = widget.loc;
    _fetchWeatherData(Location);
    print('$tem' + '$dis');
  }

  List dailyForecasts = [];

  Future<void> _fetchWeatherData(String location) async {
    const apiKey =
        '6ae533efe88fc31019f4240d790de2ee'; // Replace with your OpenWeatherMap API key
    final currentWeatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey';
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$apiKey';

    try {
      final currentWeatherResponse =
          await http.get(Uri.parse(currentWeatherUrl));

      if (currentWeatherResponse.statusCode == 200) {
        // Fetch 7-day forecast
        final forecastResponse = await http.get(Uri.parse(forecastUrl));

        if (forecastResponse.statusCode == 200) {
          final Map<String, dynamic> forecastData =
              json.decode(forecastResponse.body);

          // Extract the list of forecasts
          List<dynamic> forecasts = forecastData['list'];

          // Clear previous daily forecasts
          dailyForecasts.clear();

          final now = DateTime.now();

          // Calculate the difference in days

          for (int i = 0; i < forecasts.length; i++) {
            int timestamp = forecasts[i]['dt'];
            DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

            // Calculate the difference in days
            int daysDifference = dateTime.difference(now).inDays;
            // Extract timestamp and convert it to DateTime

            // Skip the forecast for the current day and only add data for the next 6 days
            if (daysDifference > 0 && daysDifference <= 7) {
              double tempKelvin = forecasts[i]['main']['temp'];
              double tempCelsius = tempKelvin - 273.15;
              double windSpeed =
                  forecasts[i]['wind']['speed'] * 3.6; // Convert m/s to km/h
              int humidity = forecasts[i]['main']['humidity'];
              double realFeelCelsius =
                  forecasts[i]['main']['feels_like'] - 273.15;
              int precipitation = forecasts[i]['pop'];
              int airPressure = forecasts[i]['main']['pressure'];

              // Add forecast data to the list
              dailyForecasts.add({
                'date': dateTime,
                'tempCelsius': tempCelsius.round(),
                'tempFahrenheit': (tempCelsius * 9 / 5) + 32.round(),
                'windSpeed': windSpeed.round(),
                'humidity': humidity,
                'realFeelCelsius': realFeelCelsius.round(),
                'precipitation': precipitation,
                'airPressure': airPressure,
              });
            }
            if (dailyForecasts.length >= 7) {
              break;
            }
          }

          // Sort the forecasts by date
          dailyForecasts.sort((a, b) => a['date'].compareTo(b['date']));

          // Display the next 7-day forecast
          setState(() {
            _weatherData += '\n\nNext 7-Day Forecast:';
            for (var forecast in dailyForecasts) {
              DateTime date = forecast['date'];
              String dayOfWeek = _getDayOfWeek(date.weekday);
              double tempCelsius = forecast['tempCelsius'].toDouble();
              double tempFahrenheit = forecast['tempFahrenheit'].toDouble();
              double windSpeed = forecast['windSpeed'].toDouble();
              int humidity = forecast['humidity'];
              double realFeelCelsius = forecast['realFeelCelsius'].toDouble();
              int precipitation = forecast['precipitation'];

              _weatherData +=
                  '\n$dayOfWeek - $tempCelsius°C / $tempFahrenheit°F\n'
                  'Wind Speed: $windSpeed km/h\n'
                  'Humidity: $humidity%\n'
                  'Real Feel: $realFeelCelsius°C\n'
                  'Precipitation: $precipitation%';
            }
          });
        } else {
          throw Exception(
              'Failed to load forecast data: ${forecastResponse.statusCode}');
        }
      } else {
        // Display popup message for invalid location
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Invalid location. Please enter a valid your City name.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => WeatherScreen(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );

        throw Exception(
            'Failed to load current weather data: ${currentWeatherResponse.statusCode}');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _weatherData = 'Error: $error';
        });
      }
    }
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  bool isSwitched = false;
  bool isDark = false;
  ThemeData lightThemeData(BuildContext context) {
    return ThemeData.light().copyWith(
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
    );
  }

  ThemeData darkThemeData(BuildContext context) {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.tealAccent,
      scaffoldBackgroundColor: Colors.grey[850],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: isDark ? darkThemeData(context) : lightThemeData(context),
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 226, 223, 241),
              ),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 1.h, 0.w, 0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.purple,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(3.w, 1.h, 0.w, 0),
                        child: Text(
                          'Next-Day Weather',
                          style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5.w, 1.h, 0.w, 0),
                        child: SlidingSwitch(
                          width: 20.w,
                          height: 4.h,
                          value: isDark,
                          onChanged: (value) {
                            setState(() {
                              isDark = value;
                            });
                          },
                          animationDuration: const Duration(milliseconds: 400),
                          onTap: () {},
                          onDoubleTap: () {},
                          onSwipe: () {},
                          textOff: "light",
                          textOn: "dark",
                          iconOff: Icons.light_mode,
                          iconOn: Icons.dark_mode,
                          contentSize: 14,
                          colorOn: const Color(0xffdc6c73),
                          colorOff: const Color(0xff6682c0),
                          background: const Color(0xffe4e5eb),
                          buttonColor: const Color(0xfff7f5f7),
                          inactiveColor: const Color(0xff636f7b),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      print(_weatherData);
                      print('$dailyForecasts');
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 5.w, 10.w, 0),
                      child: SizedBox(
                        // Set the width of the Card
                        height: 25.h, // Set the height of the Card
                        child: Card(
                            color: Colors.white,
                            elevation: 20.0,
                            shadowColor: Colors.purpleAccent, // Shadow color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Rounded corners
                            ),
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 89, 68, 203),
                                        Color.fromARGB(255, 60, 76, 160),
                                        Color.fromARGB(159, 233, 213, 213)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0.w, 0.h, 0, 18.h),
                                          child: Text(
                                            'Current Day',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              3.w, 1.h, 0, 0),
                                          child: Image.network(
                                            'https://cdn-icons-png.flaticon.com/512/4052/4052984.png',
                                            height: 15.h,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5.w, 7.h, 0, 0),
                                              child: Text(
                                                '${tem}°C',
                                                style: TextStyle(
                                                    fontSize: 35.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5.w, 0.h, 0, 0.h),
                                              child: Text(
                                                '${dis}',
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 3.h, 0, 0.h),
                    child: Text(
                      'Future Weather',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(7.w, 2.h, 7.w, 0),
                    child: Container(
                      // Set a fixed height for the GridView
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: dailyForecasts.length
                            .round(), // Number of days for forecast
                        itemBuilder: (context, index) {
                          var forecast = dailyForecasts[
                              index]; // Get the forecast for the current index

                          return Card(
                            shadowColor: Colors.purpleAccent,
                            elevation: 10,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(3.w, 0.h, 0, 0),
                                        child: Image.network(
                                          'https://cdn2.iconfinder.com/data/icons/weather-flat-14/64/weather02-512.png',
                                          height: 7.h,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            13.w, 0.h, 0, 0),
                                        child: Text(
                                          '${forecast['tempCelsius']}°C',
                                          style: TextStyle(
                                              fontSize: 35.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 7.h, 0, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 1.h, 0, 0),
                                                  child: Image.network(
                                                    'https://cdn-icons-png.flaticon.com/512/173/173573.png',
                                                    height: 5.h,
                                                    color: Colors.deepPurple,
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 1.h, 0, 0),
                                                  child: Text(
                                                    '${forecast['airPressure']}'
                                                    ' hPa',
                                                    style: TextStyle(
                                                        fontSize: 9.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 1.h, 0, 0),
                                                  child: Image.network(
                                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNUyi8lIpX9L6oN8w8gTgTKXCY3SYNCnOSqZXlko3uSwjNpMDH&s',
                                                    height: 4.h,
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 2.h, 0, 0),
                                                  child: Text(
                                                    '${forecast['windSpeed'].round()}'
                                                    'km',
                                                    style: TextStyle(
                                                        fontSize: 9.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 1.h, 0, 0),
                                                  child: Image.network(
                                                    'https://cdn-icons-png.flaticon.com/512/2938/2938122.png',
                                                    height: 4.h,
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 2.h, 0, 0),
                                                  child: Text(
                                                    '${forecast['humidity'].round()}'
                                                    '%',
                                                    style: TextStyle(
                                                        fontSize: 9.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                            child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0.w, 1.h, 0, 0),
                                                child: Image.network(
                                                  'https://play-lh.googleusercontent.com/jESOMYQucROBIKl4SAjg7MC8fUWF2cXqfG66aeEGX3vmML7aZsN8jceCU5oXu6LLuvU',
                                                  height: 4.h,
                                                )),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0.w, 2.h, 0, 0),
                                                child: Text(
                                                  '${forecast['realFeelCelsius'].round()}°C',
                                                  style: TextStyle(
                                                      fontSize: 9.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0.w, 1.h, 0, 0),
                                                child: Image.network(
                                                  'https://cdn2.iconfinder.com/data/icons/weather-flat-14/64/weather07-512.png',
                                                  height: 4.h,
                                                )),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0.w, 2.h, 0, 0),
                                                child: Text(
                                                  '${forecast['precipitation'].round()}%',
                                                  style: TextStyle(
                                                      fontSize: 9.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ],
                                        )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5,
                          mainAxisExtent: 150,
                          // Adjust aspect ratio as needed
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String getDateTime() {
    DateTime now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }
}
