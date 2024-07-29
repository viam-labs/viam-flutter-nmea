import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:native_add/flutter_nmea_impl.dart' as flutter_nmea;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();
  late Map<dynamic, dynamic> result;
  late Uint8List byteArr;

  bool showData = false;

  @override
  void initState() {
    super.initState();
    final byteArrTemp = Uint8List.fromList(utf8.encode(
        "!PDGY,130567,6,200,255,25631.18,RgPczwYAQnYeAB4AAAADAAAAAABQbiMA"));
    result = flutter_nmea.processData(byteArrTemp);
  }

  //!PDGY,130567,6,200,255,25631.18,RgPczwYAQnYeAB4AAAADAAAAAABQbiMA

  void processDataCall() {
    if (!textEditingController.text.isEmpty) {
      byteArr = Uint8List.fromList(utf8.encode(textEditingController.text));
      print(byteArr);
      setState(() {
        showData = true;
      });
    }
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
                !showData
                    ? Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter raw data'
                                  : null,
                              controller: textEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                label: const Text('Enter data'),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.zero)),
                                isDense: true,
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: processDataCall,
                              child: const Text("PARSE NMEA"))
                        ],
                      )
                    : Column(
                        children: [
                          const Text(
                            'The call to the gonmea library produced.',
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                          spacerSmall,
                          const Text("Raw bytes"),
                          spacerSmall,
                          Text('$byteArr'),
                          spacerSmall,
                          const Text("NMEA Readings"),
                          spacerSmall,
                          Text(
                            '$result',
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
