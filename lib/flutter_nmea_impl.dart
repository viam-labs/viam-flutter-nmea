import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'flutter_nmea_generated_bindings.dart';

/// A very short-lived native function.
///
/// For very short-lived functions, it is fine to call them on the main isolate.
/// They will block the Dart execution while running the native function, so
/// only do this for native functions which are guaranteed to be short-lived.

String? _processDataHelper(Uint8List data) {
  // Allocate memory for the raw data
  final rawDataPtr = calloc<Uint8>(data.length);
  final rawDataList = rawDataPtr.asTypedList(data.length);
  rawDataList.setAll(0, data);

  // Prepare the FFI call with the raw data pointer and length
  final cData = rawDataPtr.cast<Char>();
  final length = data.length;

  // Call the FFI function to process the data
  final resultPtr = _bindings.parse_data(cData, length);

  String? result;
  if (resultPtr != nullptr) {
    // Convert the result pointer to a Dart string
    result = resultPtr.cast<Utf8>().toDartString();
    // Free the result pointer memory
    calloc.free(resultPtr);
  }

  // Free remaining allocated memory
  calloc.free(rawDataPtr);

  return result;
}

Map<dynamic, dynamic> _stringToMap(String dartString) {
  try {
    final jsonString = json.decode(dartString);
    return jsonString;
  } catch (e) {
    return {};
  }
}

Map<dynamic, dynamic> processData(Uint8List data) {
  final readingsString = _processDataHelper(data);
  if (readingsString != null) {
    return _stringToMap(readingsString);
  }
  return {};
}

const String _libName = 'viam_flutter_nmea';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libsum.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final FlutterNmea _bindings = FlutterNmea(_dylib);
