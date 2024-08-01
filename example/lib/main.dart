import 'dart:convert';
import 'dart:developer';
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

    // Test data for
    List<String> dataPoints = [
      '{"0EEFF-00": "/+4AAGRD/j/yAKlmAAAAALAiDwAAAAAACAD/AAAABgB9gCQiAIIywA=="}',
	'{"1FB12-16": "EvsBAGRD/j/BAKlmAAAAAIk5CgAAAAAAIwD/ABYABgAYQMfxFSVHUk1EQEBFAP///////xgBWgAoALQAAAAAAAPh/w=="}',
	'{"0EEFF-09": "/+4AAGRD/j854qdmAAAAAKYuBwAAAAAACAD/AAkABgCP87AcAILcwA=="}',
	'{"1F014-1C": "FPABALg+gD9dtqdmAAAAALDoBQAAAAAAhgD/ABwABgA0CBMZR1BTTUFQIDg2MjIA//////////////////////////8zMy40MAD//////////////////////////////////zEuMAD/////////////////////////////////////MzQ1MDQ0OTU5NAD///////////////////////////8CAg=="}',
	'{"1F805-03": "BfgBAGRD/j/7AKlmAAAAAIisBAAAAAAAKwD/AAMAAwAw3k3g8VggQHY6VwKapwWA8z3EO6a69Wxqr/7/////JPwURgCCAOby//8A"}',
	'{"0EEFF-1C": "/+4AAGRD/j854qdmAAAAAFxRBwAAAAAACAD/ABwABgC6rrEcAILwwA=="}',
	'{"0EEFF-0F": "/+4AAGRD/j/0AKlmAAAAAJIGAQAAAAAACAD/AA8ABgDg87YcAILcwA=="}',
	'{"1F50B-13": "C/UBAPQZ/D9u4qdmAAAAAEhqDQAAAAAACAD/ABMAAwD/5gAAAAAA/w=="}',
	'{"1FA04-03": "BPoBAGRD/j/7AKlmAAAAAHiTBAAAAAAAkwD/AAMABgAw/QwFAAAAAKwP////f/EFRSplqPEP////f/UGrg+tPPAL////f/ULRSo5KLMS////f/UMUQ4UmusQ////f/UN9AzPbxcR////f/UU3DWuAC8N////f/UZ/w7xsWIR////f/Ud3Be21AoP////f/VF8yo5KIcQ////f/VGlhragOkJ////f/VV8xtB3owN////f/U="}',
	'{"1FD06-13": "Bv0BAPQZ/D9u4qdmAAAAAH1sDQAAAAAACAD/ABMABQD/HXT//////w=="}',
	'{"1F811-16": "EfgBALg+gD/TF6hmAAAAALeLCgAAAAAAMQD/ABYABABVajs6O8IN7dPom/UY9AAAAAAAAAAAGO4A4RcBNjcgICAgICAgICAgICAgICAgICAA"}',
	'{"1F805-16": "BfgBAGRD/j/7AKlmAAAAAH7oBAAAAAAALwD/ABYAAwDU3k3QylggQJvQujqapwWAKHLOX6a69QDv5wAAAAAAFPwCPgBwAJDy//8A/////w=="}',
	'{"1F014-13": "FPABALg+gD8nrqdmAAAAAKChCQAAAAAAhgD/ABMABgA0CNUHR1BTTUFQIDg2MTcA//////////////////////////8zMy40MAD//////////////////////////////////zEuMAD/////////////////////////////////////MzQ0ODUwNTY4MgD///////////////////////////8CAg=="}',
	'{"0EEFF-08": "/+4AAGRD/j854qdmAAAAAIxGBwAAAAAACAD/AAgABgBVirAcAILcwA=="}',
	'{"1F11A-16": "GvEBAGRD/j/7AKlmAAAAALovBAAAAAAACAD/ABYABgDS+P//cff//w=="}',
	'{"1F513-23": "E/UBAGRD/j/7AKlmAAAAAHmOBwAAAAAADgD/ACMABgD///////+f7LwAn+y8AA=="}',
	'{"1F801-03": "AfgBAPQZ/D/7AKlmAAAAAKFgCgAAAAAACAD/AAMAAgDMZkkYXwbj0w=="}',
	'{"1EFFF-14": "/+8BAGRD/j9u4qdmAAAAAEQ3DwAAAAAAIAD/ABQABwDlmEcZAgIGAwEBAw8I/w8AT4qwHAERABkAIpBOK4LZAg=="}',
	'{"1EFFF-07": "/+8BAGRD/j9u4qdmAAAAALbyDAAAAAAADQD/AAcABwDlmJMKAgIDCQARARkA"}',
	'{"1EFFF-0D": "/+8BAGRD/j9v4qdmAAAAAMMUAQAAAAAADQD/AA0ABwDlmJMKAgIDCQARARkA"}',
	'{"1EFFF-12": "/+8BAGRD/j9s4qdmAAAAAFkkDQAAAAAAIAD/ABIABwDlmEcZAgIGAwEBAw8I/w8APj2lHAERABkAIpBOK/TYAg=="}',
	'{"0EEFF-21": "/+4AAGRD/j/zAKlmAAAAAFCUBgAAAAAACAD/ACEABgDCy7UcAILwwA=="}',
	'{"1EFFF-09": "/+8BAGRD/j9u4qdmAAAAAAXcAgAAAAAADQD/AAkABwDlmJMKAgIDCQARARkA"}',
	'{"1F50B-23": "C/UBAGRD/j/7AKlmAAAAAMdBCAAAAAAACAD/ACMAAwD/oQAAAAAAAg=="}',
	'{"0EEFF-11": "/+4AAGRD/j854qdmAAAAAHM5BwAAAAAACAD/ABEABgCSHaQcAILwwA=="}',
	'{"0EAF0-21": "8OoAAGRD/j/oAKlmAAAAAEiNCgAAAAAAAwDwACEABgAA7gA="}',
	'{"1EFFF-13": "/+8BAGRD/j9u4qdmAAAAAIJYDAAAAAAAEQD/ABMABwDlmOcIAAoDAQMNivXixQERAQ=="}',
	'{"1FB02-16": "AvsBAGRD/j/0AKlmAAAAABZ3BgAAAAAATAD/ABYABgAF5pzkFQAAAABXREQ4ODcyTUFOSEFUVEFOIAD///////////9jAAAAAAAAAAALTQAAAAAAAE5ZIEhBUkJPUgD/////////////PuH/"}',
	'{"1F014-0C": "FPABALg+gD/R36dmAAAAAD6DAQAAAAAAhgD/AAwABgA0CAAAVmlydHVhbCBOMksgSW5wdXQgSGFuZGxlcgD///////8xLjAwAP///////////////////////////////////zEuMAD/////////////////////////////////////MzQ1MDQ0OTU5NAD///////////////////////////8CAA=="}',
	'{"0EAF0-02": "8OoAAGRD/j/yAKlmAAAAAC7YDAAAAAAAAwDwAAIABgAA7gA="}',
	'{"0EEFF-1E": "/+4AAGRD/j/xAKlmAAAAAOWlDQAAAAAACAD/AB4ABgAjkuDnAMigwA=="}',
	'{"1F113-02": "E/EBAGRD/j/7AKlmAAAAALaDCgAAAAAACAD/AAIAAgD/zyEAAP///w=="}',
	'{"1EFFF-0A": "/+8BAGRD/j9t4qdmAAAAAPbAAwAAAAAADQD/AAoABwDlmJMKAgIDCQARARkA"}',
	'{"1F801-16": "AfgBAGRD/j/7AKlmAAAAAFNuCQAAAAAACAD/ABYAAgCyZ0kY9gbj0w=="}',
	'{"0EEFF-07": "/+4AAGRD/j854qdmAAAAAHosBwAAAAAACAD/AAcABgBPirAcAILcwA=="}',
	'{"1FD0A-16": "Cv0BAGRD/j/7AKlmAAAAAIwtBAAAAAAACAD/ABYABQDSAACRYg8A/w=="}',
	'{"1F112-16": "EvEBAGRD/j/7AKlmAAAAAOUxBAAAAAAACAD/ABYAAgDSDVf/f3H3/Q=="}',
	'{"1FB11-16": "EfsBAGRD/j/vAKlmAAAAAH2TAgAAAAAAGwD/ABYABgAYC84sFERFTExBIEFVUk9SQQD/////////4f8="}',
	'{"0EEFF-19": "/+4AAGRD/j854qdmAAAAACZMBwAAAAAACAD/ABkABgBXUrEcAILwwA=="}',
	'{"1F80F-16": "D/gBAGRD/j/5AKlmAAAAALH4BwAAAAAAGwD/ABYABAASBXkqFPtQ3dMy9UMYcP//CgA6NQH//wBw//8="}',
	'{"1EFFF-17": "/+8BAGRD/j9u4qdmAAAAACc+DQAAAAAAEQD/ABcABwDlmOcIAAoDAQMNivXixQERAQ=="}',
	'{"0EAFF-01": "/+oAAGRD/j/dAKlmAAAAAHtJCwAAAAAAAwD/AAEABgAA7gA="}',
	'{"1EFFF-0B": "/+8BAGRD/j9t4qdmAAAAAPFfCAAAAAAADQD/AAsABwDlmJMKAgIDCQARARkA"}',
	'{"1F112-02": "EvEBAPQZ/D/7AKlmAAAAAAKACgAAAAAACAD/AAIAAgD/R0//f/9//Q=="}',
	'{"0EEFF-0A": "/+4AAGRD/j854qdmAAAAAMswBwAAAAAACAD/AAoABgBXUrEcAILcwA=="}',
	'{"1F802-16": "AvgBAPQZ/D/7AKlmAAAAACanCAAAAAAACAD/ABYAAgDZ/KwTAwD//w=="}',
	'{"0EEFF-13": "/+4AAGRD/j854qdmAAAAANA9BwAAAAAACAD/ABMABgBSBbAcAILwwA=="}',
	'{"1FD06-16": "Bv0BAGRD/j/7AKlmAAAAABspBAAAAAAACAD/ABYABQDS//////AD/w=="}',
	'{"0EEFF-16": "/+4AAGRD/j/dAKlmAAAAAIZLCwAAAAAACAD/ABYABgAsgwI/AMN4wA=="}',
	'{"1FA03-16": "A/oBAGRD/j/7AKlmAAAAAOvpBAAAAAAACAD/ABYABgDU0j4AXQD/fw=="}',
	'{"1F014-08": "FPABALg+gD/jiKdmAAAAAMnKCwAAAAAAhgD/AAgABgA0CAAAVmlydHVhbCBOMksgSW5wdXQgSGFuZGxlcgD///////8xLjAwAP///////////////////////////////////zEuMAD/////////////////////////////////////MzQ1MzY1MTU0MQD///////////////////////////8CAA=="}',
	'{"1EFFF-1C": "/+8BAGRD/j9u4qdmAAAAAItZCgAAAAAADgD/ABwABwDlmOAIAgIDCQwS0A8ZAA=="}',
	'{"1EFFF-19": "/+8BAGRD/j9u4qdmAAAAAMY6CQAAAAAADgD/ABkABwDlmOAIAgIDCQwS0A8ZAA=="}',
	'{"1FD08-13": "CP0BAPQZ/D9u4qdmAAAAAERoDQAAAAAACAD/ABMABQD/AAAddP///w=="}',
	'{"0EEFF-06": "/+4AAGRD/j854qdmAAAAAP4/BwAAAAAACAD/AAYABgBSBbAcAILcwA=="}',
	'{"0EEFF-12": "/+4AAGRD/j854qdmAAAAAJ47BwAAAAAACAD/ABIABgA+PaUcAILwwA=="}',
	'{"0EEFF-26": "/+4AALg+gD/dAKlmAAAAADlWCwAAAAAACAD/ACYABgC9y2g0AIL6wA=="}',
	'{"1F010-03": "EPABAGRD/j/7AKlmAAAAAPaUBAAAAAAACAD/AAMAAwAw8N5N4PFYIA=="}',
	'{"0EFFF-02": "/+8AAGRD/j/0AKlmAAAAAO1ICgAAAAAACAD/AAIABwDlmBAXBAQUAQ=="}',
	'{"1FA03-03": "A/oBAGRD/j/7AKlmAAAAAImuBAAAAAAACAD/AAMABgAw00YAbQBNAA=="}',
	'{"1EFFF-11": "/+8BAGRD/j9s4qdmAAAAAA62CwAAAAAAGQD/ABEABwDlmEgZAgIDAwEBAw8I/w8Akh2kHAETl68D"}',
	'{"0EEFF-15": "/+4AAGRD/j854qdmAAAAAFdEBwAAAAAACAD/ABUABgBVirAcAILwwA=="}',
	'{"0EEFF-0C": "/+4AAGRD/j854qdmAAAAAIhTBwAAAAAACAD/AAwABgC6rrEcAILcwA=="}',
	'{"1F903-13": "A/kBAGRD/j9u4qdmAAAAAHDRBQAAAAAACAD/ABMAAwD/8f///3///w=="}',
	'{"0EEFF-10": "/+4AAGRD/j/zAKlmAAAAAPFCAwAAAAAACAD/ABAABgCEkeDnAMigwA=="}',
	'{"1F11A-03": "GvEBAGRD/j/7AKlmAAAAADyxBAAAAAAACAD/AAMABgAw8t5NZff//w=="}',
	'{"0EAF0-25": "8OoAAGRD/j+LAKlmAAAAAMC3AAAAAAAAAwDwACUABgAA7gA="}',
	'{"1FA04-16": "BPoBAGRD/j/7AKlmAAAAAPHyBAAAAAAAGwD/ABYABgDU/wIJ6ArzGwAAAAAAAPIxAAAhQgAAAAAAAPI="}',
	'{"1EFFF-02": "/+8BAPQZ/D/7AKlmAAAAAP5LCgAAAAAADQD/AAIABwDlmBAXBAQRAgpODBEA"}',
	'{"1F503-23": "A/UBAGRD/j/7AKlmAAAAAGUyCAAAAAAACAD/ACMAAgD/AAD//wD//w=="}',
	'{"1F119-03": "GfEBAPQZ/D/7AKlmAAAAAE6ICgAAAAAACAD/AAMAAwA0/n/+f/5//w=="}',
	'{"0EEFF-0B": "/+4AAGRD/j854qdmAAAAACtPBwAAAAAACAD/AAsABgC3rrEcAILcwA=="}',
	'{"1EFFF-15": "/+8BAGRD/j9u4qdmAAAAAIbyBAAAAAAAEQD/ABUABwDlmOcIAAoDAQMNivXixQERAQ=="}',
	'{"1FF04-26": "BP8BAGRD/j/7AKlmAAAAAP+RCgAAAAAACAD/ACYABwCjmV+AAQEAAQ=="}',
	'{"1EFFF-1B": "/+8BAPQZ/D9u4qdmAAAAAAVrCwAAAAAAEQD/ABsABwDlmOcIAAoDAQMNivXixQERAQ=="}',
	'{"0EEFF-1B": "/+4AAGRD/j854qdmAAAAAJhNBwAAAAAACAD/ABsABgC3rrEcAILwwA=="}',
	'{"1FD07-23": "B/0BAPQZ/D/7AKlmAAAAAMt6BQAAAAAACAD/ACMABQD/wKF0/3///w=="}',
	'{"1EFFF-08": "/+8BAGRD/j9t4qdmAAAAAGBhAwAAAAAADQD/AAgABwDlmJMKAgIDCQARARkA"}',
	'{"1F80E-16": "DvgBAPQZ/D/7AKlmAAAAAGU4CgAAAAAAHAD/ABYABAABIr3dFR274tOMLU0YfL3XAADYCAr///9/wPj/"}',
	'{"0EEFF-03": "/+4AAGRD/j/dAKlmAAAAAOVRCwAAAAAACAD/AAMABgA8WrkcAJF4wA=="}',
	'{"1EFFF-0C": "/+8BAGRD/j9u4qdmAAAAAEMzCAAAAAAADQD/AAwABwDlmJMKAgIDCQARARkA"}',
	'{"0EEFF-25": "/+4AAGRD/j/yAKlmAAAAAINNCwAAAAAACAD/ACUABgD7y7UcAILwwA=="}',
	'{"1EFFF-1D": "/+8BAGRD/j9u4qdmAAAAANgXCgAAAAAAEQD/AB0ABwDlmOcIAAoDAQMNivXixQERAQ=="}',
	'{"0EEFF-17": "/+4AAGRD/j854qdmAAAAALpIBwAAAAAACAD/ABcABgCP87AcAILwwA=="}',
	'{"1F119-02": "GfEBAPQZ/D/7AKlmAAAAABX8CAAAAAAACAD/AAIAAwD/R0/4/9P//w=="}',
	'{"1F014-17": "FPABALg+gD++oadmAAAAAAINAAAAAAAAhgD/ABcABgA0CBMZR1BTTUFQIDg2MjIA//////////////////////////8zMy40MAD//////////////////////////////////zEuMAD/////////////////////////////////////MzQ0MjI3NTIxNQD///////////////////////////8CAg=="}',
	'{"1F904-13": "BPkBAGRD/j9u4qdmAAAAAJHPBQAAAAAAIgD/ABMAAwD//////w////////////////////////////9/////f/9/"}',
	'{"1F014-19": "FPABALg+gD9ZtqdmAAAAAHfxAQAAAAAAhgD/ABkABgA0CNUHR1BTTUFQIDg2MTcA//////////////////////////8zMy40MAD//////////////////////////////////zEuMAD/////////////////////////////////////MzQ1MDgxOTE1OQD///////////////////////////8CAg=="}',
	'{"1EFFF-06": "/+8BAGRD/j9u4qdmAAAAAOsuCAAAAAAADQD/AAYABwDlmJMKAgIDCQARARkA"}',
	'{"0EEFF-14": "/+4AAGRD/j854qdmAAAAADBCBwAAAAAACAD/ABQABgBPirAcAILwwA=="}',
	'{"1EFFF-03": "/+8BAGRD/j/7AKlmAAAAAP7MBAAAAAAAPgD/AAMABwDlmBcABAQ5J2xARWY4QDrPlUA6zxVAOs8VQArXozzNzMw9CtejPM3MzD2nOTQ/2R6MP26Ypj8kr0Y/AAAAAA=="}',
	'{"1F112-03": "EvEBAGRD/j/7AKlmAAAAANDGCQAAAAAACAD/AAMAAgAz/v//f/9//A=="}',
	'{"0EEFF-23": "/+4AAGRD/j/B/qhmAAAAAEhFCwAAAAAACAD/ACMABgADIOoQAIh4wA=="}',
	'{"0EEFF-1D": "/+4AAGRD/j854qdmAAAAALFVBwAAAAAACAD/AB0ABgCY4rEcAILwwA=="}',
	'{"1F802-03": "AvgBAPQZ/D/7AKlmAAAAAPlbCgAAAAAACAD/AAMAAgA0/E/iAwD//w=="}',
	'{"0EEFF-01": "/+4AAGRD/j/yAKlmAAAAAEI1DwAAAAAACAD/AAEABgBuvCQiAIcywA=="}',
	'{"1FD07-16": "B/0BAGRD/j/7AKlmAAAAAFwrBAAAAAAACAD/ABYABQDS/////3/wAw=="}',
	'{"1FD06-23": "Bv0BAGRD/j/7AKlmAAAAAF2MCgAAAAAACAD/ACMABQD/oXT//////w=="}',
	'{"0EEFF-02": "/+4AAGRD/j/dAKlmAAAAALlPCwAAAAAACAD/AAIABgDJ2r0cAJZQwA=="}',
	'{"1FD0C-23": "DP0BAPQZ/D/6AKlmAAAAAIOXCgAAAAAACAD/ACMABQD/AABSjgT//w=="}',
	'{"0EEFF-0D": "/+4AAGRD/j854qdmAAAAAPAyBwAAAAAACAD/AA0ABgCY4rEcAILcwA=="}',
	'{"1F11A-11": "GvEBAGRD/j9s4qdmAAAAAArdCwAAAAAACAD/ABEABgD/8t1NZff//w=="}'
    ];

    for (var data in dataPoints) {
      List<String> key = jsonDecode(data).keys.toList();
      log('Processing data: $key');
      byteArr = Uint8List.fromList(utf8.encode(data));
      result = flutter_nmea.processData(byteArr);
      log('$result');
    }
  }

  void processDataCall() {
    if (textEditingController.text.isNotEmpty) {
      byteArr = Uint8List.fromList(utf8.encode(textEditingController.text));
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
                              decoration: const InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                label: Text('Enter data'),
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
