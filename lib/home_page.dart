import 'package:d9l_weather/dio_client.dart';
import 'package:d9l_weather/model.dart';
import 'package:d9l_weather/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RealTimeWeather realTimeWeather;
  String cid;

  List<DailyForecast> dailyForecastList = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.asset('assets/images/bg.png', fit: BoxFit.fill, width: width),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dailyForecastList.map((item) {
                    return _threeDayWeather(item);
                  }).toList(),
                ),
                Text('d9lweather', style: TextStyle(color: Color(0xffe2e2e2))),
              ],
            ),
          ),
          RefreshIndicator(
            onRefresh: _pullDownRefresh,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 90.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${realTimeWeather?.now?.condTxt ?? 'unknown'}',
                        style: TextStyle(fontSize: 34.0, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          realTimeWeather?.basic?.location ?? 'unknown',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${realTimeWeather?.now?.tmp ?? '0'}',
                              style: TextStyle(fontSize: 80.0, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text('℃', style: TextStyle(fontSize: 40.0, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      SizedBox(height: 330.0)
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 27.0,
            right: 0.0,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (_) => SearchPage())).then((result) {
                  if (result != null) {
                    cid = result;
                    _updateWeather();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _threeDayWeather(DailyForecast dailyForecast) {
    String date = DateFormat('EE', 'zh_CN').format(
      DateTime.parse(dailyForecast.date),
    );
    return Column(
      children: <Widget>[
        Text(date, style: TextStyle(color: Color(0xff8a8a8a))),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Image.asset('assets/images/sunny.png'),
        ),
        Text(dailyForecast.tmpMin + '℃~' + dailyForecast.tmpMax + '℃', style: TextStyle(color: Color(0xff8a8a8a))),
      ],
    );
  }

  // refresh
  Future<void> _pullDownRefresh() async {
    await _updateWeather();
  }

  Future<void> _updateWeather() async {
    await DioClient().getRealTimeWeather(cid).then((v) {
      if (v != null && this.mounted) {
        setState(() {
          realTimeWeather = v;
        });
      }
    });

    await DioClient().getThreeDaysForecast(cid).then((v) {
      if (v != null && this.mounted) {
        setState(() {
          dailyForecastList = v.dailyForecasts;
        });
      }
    });
  }
}
