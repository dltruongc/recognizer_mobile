import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:stt_mobile_app/pages/tts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Text to Speech'),
      ),
      body: MyTextToSpeech(),
    );
  }
}
