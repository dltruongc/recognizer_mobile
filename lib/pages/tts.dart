import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts/flutter_tts_web.dart';

class MyTextToSpeech extends StatefulWidget {
  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<MyTextToSpeech> {
  FlutterTts flutterTts;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getEngines();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future _getEngines() async {
    FocusScope.of(context).unfocus();
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    FocusScope.of(context).unfocus();
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
      }
    }
  }

  Future _stop() async {
    FocusScope.of(context).unfocus();
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    FocusScope.of(context).unfocus();
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          _inputSection(),
          _btnSection(),
          _futureBuilder(),
          _buildSliders()
        ],
      ),
    );
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        onChanged: (String value) {
          _onChange(value);
        },
        minLines: 3,
        maxLines: 10,
        decoration: new InputDecoration(
          labelText: "Enter text here ...",
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(25.0),
            borderSide: new BorderSide(),
          ),
          //fillColor: Colors.green
        ),
      ));

  Widget _btnSection() {
    if (isAndroid) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Container(
          padding: EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildButtonColumn(
                Colors.green,
                Colors.greenAccent,
                Icons.play_arrow,
                'PLAY',
                _speak,
              ),
              _buildButtonColumn(
                Colors.red,
                Colors.redAccent,
                Icons.stop,
                'STOP',
                _stop,
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Container(
          padding: EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildButtonColumn(
                Colors.green,
                Colors.greenAccent,
                Icons.play_arrow,
                'PLAY',
                _speak,
              ),
              _buildButtonColumn(
                Colors.blue,
                Colors.blueAccent,
                Icons.pause,
                'PAUSE',
                _pause,
              ),
              _buildButtonColumn(
                Colors.red,
                Colors.redAccent,
                Icons.stop,
                'STOP',
                _stop,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                height: 60.0,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              child: DropdownButton(
                hint: Text('Select language'),
                value: language,
                items: getLanguageDropDownMenuItems(languages),
                onChanged: changedLanguageDropDownItem,
                isExpanded: true,
              ),
            ),
            Visibility(
              visible: isAndroid,
              child: Text("Is installed: $isCurrentLanguageInstalled"),
            ),
          ]));

  Widget _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 48,
      color: color,
      splashColor: splashColor,
      onPressed: () => func(),
    );
  }

  Widget _buildSliders() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _volume(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _pitch(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _rate(),
        ),
      ],
    );
  }

  Widget _volume() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Volume: '),
        ),
        Slider(
          value: volume,
          onChanged: (newVolume) {
            setState(() => volume = newVolume);
          },
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: "Volume: $volume",
        ),
      ],
    );
  }

  Widget _pitch() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Pitch: '),
        ),
        Slider(
          value: pitch,
          onChanged: (newPitch) {
            setState(() => pitch = newPitch);
          },
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: "Pitch: $pitch",
          // activeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _rate() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text('Rate: '),
        ),
        Slider(
          value: rate,
          onChanged: (newRate) {
            setState(() => rate = newRate);
          },
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: "Rate: $rate",
          // activeColor: Colors.green,
        ),
      ],
    );
  }
}
