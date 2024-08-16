import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SportartenMetConverter {
  static Future<Map<String, double>> loadSportartenMet(String path) async {
    final String jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    return jsonMap.map((key, value) => MapEntry(key, value.toDouble()));
  }
}
