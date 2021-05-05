import 'package:curved_splash_screen/curved_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:stt_mobile_app/pages/home.dart';

        void main() {
        runApp(MyApp());
        }

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                title: 'Flutter AI tools',
                theme: ThemeData(
                primarySwatch: Colors.blue,
      ),
        home: MyHomePage(title: 'Flutter AI'),
    );
    }
}

class MyHomePage extends StatefulWidget {
    MyHomePage({Key key, this.title}) : super(key: key);
    final String title;

    @override
    _MyHomePageState createState() => _MyHomePageState();
}

class SplashContent extends StatelessWidget {
    final String title;
    final String text;
    final String image;

  const SplashContent({
        Key key,
        @required this.title,
        @required this.text,
        @required this.image,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
        SizedBox(height: 100),
        Container(
                height: 200,
                child: Image.asset(image),
          ),
        SizedBox(height: 60),
        Text(
                title,
                style: TextStyle(
                color: Colors.black,
                fontSize: 27,
                fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: 20),
        Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 19,
            ),
          )
        ],
      ),
    );
    }
}

final splashContent = [
        {
        "title": "Start Learning",
        "text":
        "Start learning now by using this app, Get your choosen course and start the journey.",
        "image": "assets/images/1.jpg",
        },
        ];

class _MyHomePageState extends State<MyHomePage> {
    int _counter = 0;

    void _incrementCounter() {
        setState(() {
            _counter++;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                appBar: AppBar(
                title: Text(widget.title),
                centerTitle: true,
      ),
        body: CurvedSplashScreen(
                screensLength: splashContent.length,
                screenBuilder: (index) {
        return SplashContent(
                title: splashContent[index]["title"],
                image: splashContent[index]["image"],
                text: splashContent[index]["text"],
          );
        },
        onSkipButton: () {
            Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (BuildContext contenxt) {
                return HomePage();
            }),
          );
        },
      ),
    );
    }
}
