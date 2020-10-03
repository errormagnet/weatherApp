import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // required for json

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature;
  String location = 'San Fransisco';
  int woeid = 2487956; // SF woeid
  String weather = 'clear';
  String abbreviation = '';
  String errorMessage = '';

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  // get from api website example
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async {
    try {
      //await for async function
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];
      errorMessage = '';

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
      });
    } catch (error) {
      setState(() {
        errorMessage = 'No data available. Try another City';
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      // To make the name same as the name of our image files
      abbreviation = data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(String input) async {
    // one click display
    await fetchSearch(input);
    await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: temperature == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                              'https://www.metaweather.com/static/img/weather/png/' +
                                  abbreviation +
                                  '.png',
                              width: 100),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + ' °C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60.0,
                            ),
                          ),
                        ),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                            },
                            style:
                                TextStyle(color: Colors.white, fontSize: 25.0),
                            decoration: InputDecoration(
                              hintText: 'Search another location...',
                              hintStyle: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
