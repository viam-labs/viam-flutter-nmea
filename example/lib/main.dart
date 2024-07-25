import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:viam_flutter_nmea/flutter_nmea_impl.dart' as flutter_nmea;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Map<dynamic, dynamic> result;

  final Uint8List byteArr = Uint8List.fromList(utf8.encode(
      "!PDGY,130567,6,200,255,25631.18,RgPczwYAQnYeAB4AAAADAAAAAABQbiMA"));

  @override
  void initState() {
    super.initState();
    result = flutter_nmea.processData(byteArr);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Nmea'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'The call to the gonmea library produced.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text('$byteArr'),
                spacerSmall,
                Text(
                  '$result',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
