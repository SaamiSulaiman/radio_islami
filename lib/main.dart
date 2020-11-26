import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radio_player/flutter_radio_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  var PlayerState = FlutterRadioPlayer.flutter_radio_paused;
  var volume = 0.8;

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterRadioPlayer _flutterRadioPlayer = FlutterRadioPlayer();

  @override
  void initState() {
    initRadioService();
    super.initState();
  }

  Future<void> initRadioService() async {
    try {
      await _flutterRadioPlayer.init("Radio Islami", "Kumpulan Radio Islami",
          "https://radioislamindonesia.com:7002/", "false");
    } on PlatformException {
      print("Gagal Server");
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xff0a0e21),
        scaffoldBackgroundColor: Color(0xff0a0e21),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Radio Islami"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 6,
                  child: Icon(
                Icons.radio,
                color: Colors.white,
                size: 258,
              )),
              Row(
                children: [
                  Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 32,
                  ),
                  Expanded(
                    child: Slider(
                        value: widget.volume,
                        onChanged: (value) => setState(() {
                              widget.volume = value;
                              _flutterRadioPlayer.setVolume(widget.volume);
                            })),
                  )
                ],
              ),
              Expanded(
                flex: 2,
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: StreamBuilder(
                  stream: _flutterRadioPlayer.isPlayingStream,
                  initialData: widget.PlayerState,
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    String returnData = snapshot.data;
                    print("Object Data : " + returnData);

                    switch (returnData) {
                      case FlutterRadioPlayer.flutter_radio_stopped:
                        return RaisedButton(
                            child: Text("Start Listening Now"),
                            onPressed: () async {
                              await initRadioService();
                            });
                        break;
                      case FlutterRadioPlayer.flutter_radio_loading:
                        return Text("Loadung stream ....");
                        break;
                      case FlutterRadioPlayer.flutter_radio_error:
                        return RaisedButton(
                            child: Text("Try Again"),
                            onPressed: () async {
                              await initRadioService();
                            });
                        break;
                      default:
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              onPressed: () async {
                                print("button press data : " +
                                    snapshot.data.toString());
                                await _flutterRadioPlayer.playOrPause();
                              },
                              child: snapshot.data ==
                                      FlutterRadioPlayer.flutter_radio_playing
                                  ? Icon(Icons.pause)
                                  : Icon(Icons.play_arrow),
                            ),
                            SizedBox(width: 16,),
                            FloatingActionButton(onPressed: () async {
                              await _flutterRadioPlayer.stop();
                            },
                              child: Icon(Icons.stop),
                            )
                          ],
                        );
                        break;
                    }
                  },
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
