// ignore_for_file: unnecessary_string_interpolations, avoid_unnecessary_containers, sized_box_for_whitespace, avoid_print, file_names, non_constant_identifier_names, unused_local_variable, prefer_const_declarations, unnecessary_brace_in_string_interps, prefer_const_constructors, unused_field, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:weather/Weather/NextDay.dart';
import 'package:weather/Weather/Weather.dart';

class HourlyForecast {
  final DateTime dateTime;
  final double temperatureCelsius;
  final double temperatureFahrenheit;

  HourlyForecast(
      this.dateTime, this.temperatureCelsius, this.temperatureFahrenheit);
}

class WeatherForerest extends StatefulWidget {
  final String loc;
  const WeatherForerest({Key? key, required this.loc}) : super(key: key);

  @override
  State<WeatherForerest> createState() => _WeatherForerestState();
}

class _WeatherForerestState extends State<WeatherForerest> {
  late Timer timer;
  late int second;
  int selectedCardIndex = -1;
  String Location = '';

  @override
  void initState() {
    super.initState();
    second = 0;
    timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
    Location = widget.loc;
    _fetchWeatherData(Location);
    _fetchWeatherData1(Location);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    setState(() {
      second = (second % 7) + 1;
    });
  }

  String _weatherData = '';
  int tempCelsius1 = 0;
  int temrealfeel = 0;
  int air = 0;
  int vis = 0;
  int hum = 0;
  String weatherDescription = '';
  double pre = 0;
  int speed = 0;
  String _weatherData1 = '';

  Future<void> _fetchWeatherData(String location, {bool isCity = true}) async {
    const apiKey =
        '6ae533efe88fc31019f4240d790de2ee'; // Replace with your OpenWeatherMap API key
    final baseUrl = isCity
        ? 'https://api.openweathermap.org/data/2.5/weather?q=$location'
        : 'https://api.openweathermap.org/data/2.5/weather?zip=$location';

    final currentWeatherUrl = '$baseUrl&appid=$apiKey';

    try {
      final currentWeatherResponse =
          await http.get(Uri.parse(currentWeatherUrl));

      if (currentWeatherResponse.statusCode == 200) {
        final Map<String, dynamic> currentWeatherData =
            json.decode(currentWeatherResponse.body);

        double tempKelvin = currentWeatherData['main']['temp'];
        double tempCelsius = tempKelvin - 273.15;
        double tempFahrenheit = (tempCelsius * 9 / 5) + 32;
        double precipitationVolume = 0.0;
        if (currentWeatherData.containsKey('rain')) {
          precipitationVolume = currentWeatherData['rain']['1h'] ?? 0.0;
        } else if (currentWeatherData.containsKey('snow')) {
          precipitationVolume = currentWeatherData['snow']['1h'] ?? 0.0;
        }
        double significantPrecipitationThreshold =
            1.0; // You can adjust this threshold

// Convert precipitation to percentage based on the threshold
        double precipitationPercentage =
            (precipitationVolume > significantPrecipitationThreshold)
                ? 100.0
                : 0.0;

        double realFeelCelsius =
            currentWeatherData['main']['feels_like'] - 273.15;
        double realFeelFahrenheit = (realFeelCelsius * 9 / 5) + 32;
        double shadeTempCelsius = currentWeatherData['main']['temp'] - 273.15;
        double shadeTempFahrenheit = (shadeTempCelsius * 9 / 5) + 32;
        double windSpeed = currentWeatherData['wind']['speed'] * 3.6;
        int humidity = currentWeatherData['main']['humidity'];
        double visibility =
            currentWeatherData['visibility'] / 1000; // Convert to kilometers
        int airPressure = currentWeatherData['main']['pressure'];

        setState(() {
          _weatherData =
              'Current Temperature: $tempCelsius°C / $tempFahrenheit°F\n'
              'Real Feel: $realFeelCelsius°C / $realFeelFahrenheit°F\n'
              'Shade Temperature: $shadeTempCelsius°C / $shadeTempFahrenheit°F\n'
              'Wind Speed: $windSpeed km/h\n'
              'Humidity: $humidity%\n'
              'Visibility: $visibility km\n'
              'Air Pressure: $airPressure hPa\n'
              'Precipitation: ${precipitationPercentage.toStringAsFixed(2)}%\n'
              'Description: ${currentWeatherData['weather'][0]['description']}';

          // Assign values to other variables if needed
          tempCelsius1 = tempCelsius.round();
          temrealfeel = realFeelCelsius.round();
          air = airPressure.round();
          vis = visibility.round();
          hum = humidity.round();
          pre = precipitationPercentage;
          speed = windSpeed.round();
          weatherDescription = currentWeatherData['weather'][0]['description'];
        });
      } else {
        // Display popup message for invalid location
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Invalid location. Please enter a valid city name or zip code.'),
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

  List dailyForecasts = [];

  Future<void> _fetchWeatherData1(String location) async {
    const apiKey = '6ae533efe88fc31019f4240d790de2ee';
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$apiKey';

    try {
      final forecastResponse = await http.get(Uri.parse(forecastUrl));
      if (forecastResponse.statusCode == 200) {
        final Map<String, dynamic> forecastData =
            json.decode(forecastResponse.body);

        List<dynamic> forecasts = forecastData['list'];

        DateTime tomorrow = DateTime.now().add(Duration(days: 1));
        int tomorrowDay = tomorrow.day;

        for (int i = 0; i < forecasts.length; i++) {
          // Extract temperature for each forecast
          double tempKelvin = forecasts[i]['main']['temp'];
          double tempCelsius = tempKelvin - 273.15;

          // Extract timestamp and convert it to DateTime
          int timestamp = forecasts[i]['dt'];
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

          // Check if it's tomorrow's forecast
          if (dateTime.day == tomorrowDay) {
            // Extract day of the week
            String dayOfWeek = _getDayOfWeek(dateTime.weekday);
            double windSpeed = forecasts[i]['wind']['speed'] * 3.6;
            int precipitation =
                forecasts[i]['pop']; // Probability of precipitation
            double realFeelCelsius =
                forecasts[i]['main']['feels_like'] - 273.15;
            int humidity = forecasts[i]['main']['humidity'];
            String description = forecasts[i]['weather'][0]['description'];
            int airPressure = forecasts[i]['main']['pressure'];

            // Add forecast data to the list
            dailyForecasts.add({
              'dayOfWeek': dayOfWeek,
              'tempCelsius': tempCelsius.round(),
              'tempFahrenheit': (tempCelsius * 9 / 5) + 32.round(),
              'windSpeed': windSpeed,
              'precipitation': precipitation,
              'realFeelCelsius': realFeelCelsius.round(),
              'humidity': humidity,
              'description': description,
              'airPressure': airPressure,
            });

            break;
          }
        }
      }

      setState(() {
        _weatherData1 = dailyForecasts
            .map((forecast) =>
                '${forecast['dayOfWeek']} - ${forecast['tempCelsius']}°C / ${forecast['tempFahrenheit']}°F\n'
                'Wind Speed: ${forecast['windSpeed']} km/h\n'
                'Real Feel: ${forecast['realFeelCelsius']}°C\n'
                'Humidity: ${forecast['humidity']}%')
            .join('\n');
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _weatherData1 = 'Error: $error';
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
            // ignore: deprecated_member_use
            home: WillPopScope(
              onWillPop: () => _onWillPop(context),
              child: Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 226, 223, 241),
                  ),
                  child: ListView(
                    children: [
                      Row(
                        children: [
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
                              animationDuration:
                                  const Duration(milliseconds: 400),
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
                              inactiveColor:
                                  const Color.fromARGB(255, 80, 135, 191),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(60.w, 1.h, 0.w, 0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_box,
                                  color: Colors.purple,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => WeatherScreen(),
                                    ),
                                  );
                                },
                              )),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${Location}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 1.h, 0, 0),
                        child: Center(
                          child: Text(
                            '${getCurrentDateTime()}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(34.w, 1.h, 34.w, 0),
                        child: Material(
                          color: Colors.white,
                          elevation: 10.0,
                          shadowColor: Colors.purpleAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          child: Center(
                            child: Text(
                              '${getDateTime()}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle the onTap event
                          print('${Location.toString()}');
                          print('$pre');
                          print('$dailyForecasts');
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 0),
                          child: SizedBox(
                            // Set the width of the Card
                            height: 32.h, // Set the height of the Card
                            child: Card(
                                color: Colors.white,
                                elevation: 20.0,
                                shadowColor:
                                    Colors.purpleAccent, // Shadow color
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
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 1.h, 0, 0),
                                          child: Image.network(
                                            'https://cdn-icons-png.flaticon.com/512/4052/4052984.png',
                                            height: 18.h,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 2.h, 0, 0),
                                          child: Text(
                                            '$tempCelsius1°C',
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 0.h, 0, 0.h),
                                          child: Text(
                                            '$weatherDescription',
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.w, 3.h, 10.w, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.black,
                          ),
                          height: 10.h,
                          child: Material(
                            elevation: 10.0,
                            shadowColor: Colors.purpleAccent,
                            borderRadius: BorderRadius.circular(20.0),
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
                                            '$air' ' hPa',
                                            style: TextStyle(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.bold),
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
                                            'https://static.vecteezy.com/system/resources/previews/022/782/484/original/wind-clouds-icon-weather-forecast-pictogram-wind-icon-wind-blowing-windy-weather-air-icons-doodle-wind-winds-and-clouds-weather-symbol-wind-speed-icon-free-vector.jpg',
                                            height: 4.h,
                                          )),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0.w, 2.h, 0, 0),
                                          child: Text(
                                            '$speed' 'km',
                                            style: TextStyle(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.bold),
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
                                            '$hum%',
                                            style: TextStyle(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0.w, 1.h, 0, 0),
                                        child: Image.network(
                                          'https://play-lh.googleusercontent.com/jESOMYQucROBIKl4SAjg7MC8fUWF2cXqfG66aeEGX3vmML7aZsN8jceCU5oXu6LLuvU',
                                          height: 4.h,
                                        )),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0.w, 2.h, 0, 0),
                                        child: Text(
                                          '$temrealfeel°C',
                                          style: TextStyle(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                )),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0.w, 1.h, 0, 0),
                                        child: Image.network(
                                          'https://cdn2.iconfinder.com/data/icons/weather-flat-14/64/weather07-512.png',
                                          height: 4.h,
                                        )),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0.w, 2.h, 0, 0),
                                        child: Text(
                                          '$pre%',
                                          style: TextStyle(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.w, 2.h, 0, 0),
                            child: const Text(
                              'Tomorrow',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(35.w, 2.h, 0, 0),
                              child: GestureDetector(
                                child: const Text(
                                  'Next 7 Days >',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => NextDays(
                                          tempCelsius1: tempCelsius1,
                                          weatherDescription:
                                              weatherDescription,
                                          loc: widget.loc),
                                    ),
                                  );
                                },
                              )),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(7.w, 1.h, 0.w, 0),
                        child: Container(
                          height: 24.h, // Set a fixed height for the GridView
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: dailyForecasts.length.round(),
                            itemBuilder: (context, index) {
                              var forecast = dailyForecasts[index];

                              return Card(
                                  shadowColor: Colors.purpleAccent,
                                  elevation: 10,
                                  child: GestureDetector(
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  7.w, 0.h, 0, 7.h),
                                              child: Image.network(
                                                'https://cdn-icons-png.flaticon.com/512/4052/4052984.png',
                                                height: 9.h,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      8.w, 3.h, 0, 0.h),
                                                  child: Text(
                                                    '${forecast['dayOfWeek']}',
                                                    style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.purple),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.w, 0.h, 0.w, 10.h),
                                                  child: Text(
                                                    '${forecast['tempCelsius']}°C',
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.purple),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.w, 0.h, 0.w, 0.h),
                                              child: Text(
                                                '${forecast['description']}',
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.purple),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 13.h, 0, 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.w, 1.h, 0, 0),
                                                        child: Image.network(
                                                          'https://cdn-icons-png.flaticon.com/512/173/173573.png',
                                                          height: 5.h,
                                                          color:
                                                              Colors.deepPurple,
                                                        )),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.w, 1.h, 0, 0),
                                                        child: Text(
                                                          '${forecast['airPressure']}'
                                                          ' hPa',
                                                          style: TextStyle(
                                                              fontSize: 9.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.w, 1.h, 0, 0),
                                                        child: Image.network(
                                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNUyi8lIpX9L6oN8w8gTgTKXCY3SYNCnOSqZXlko3uSwjNpMDH&s',
                                                          height: 4.h,
                                                        )),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.w, 2.h, 0, 0),
                                                        child: Text(
                                                          '${forecast['windSpeed'].round()}'
                                                          'km',
                                                          style: TextStyle(
                                                              fontSize: 9.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.w, 1.h, 0, 0),
                                                        child: Image.network(
                                                          'https://cdn-icons-png.flaticon.com/512/2938/2938122.png',
                                                          height: 4.h,
                                                        )),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.w, 2.h, 0, 0),
                                                        child: Text(
                                                          '${forecast['humidity'].round()}'
                                                          '%',
                                                          style: TextStyle(
                                                              fontSize: 9.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  child: Column(
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0.w, 1.h, 0, 0),
                                                      child: Image.network(
                                                        'https://play-lh.googleusercontent.com/jESOMYQucROBIKl4SAjg7MC8fUWF2cXqfG66aeEGX3vmML7aZsN8jceCU5oXu6LLuvU',
                                                        height: 4.h,
                                                      )),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0.w, 2.h, 0, 0),
                                                      child: Text(
                                                        '${forecast['realFeelCelsius'].round()}°C',
                                                        style: TextStyle(
                                                            fontSize: 9.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                ],
                                              )),
                                              Expanded(
                                                  child: Column(
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0.w, 1.h, 0, 0),
                                                      child: Image.network(
                                                        'https://cdn2.iconfinder.com/data/icons/weather-flat-14/64/weather07-512.png',
                                                        height: 4.h,
                                                      )),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0.w, 2.h, 0, 0),
                                                      child: Text(
                                                        '${forecast['precipitation'].round()}%',
                                                        style: TextStyle(
                                                            fontSize: 9.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                ],
                                              )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    onTap: () {},
                                  ));
                            },
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 10,
                                    mainAxisExtent: 310
                                    // Adjust aspect ratio as needed
                                    ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    return ' ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
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

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Exit'),
            content: Text('Are you sure you want to exit the application?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
