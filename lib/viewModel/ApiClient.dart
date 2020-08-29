import 'dart:convert';

import 'package:muslim_app/model/dataPray.dart';
import 'package:http/http.dart' as http;

String baseUrl = "https://api.banghasan.com";

Future<DataPray> fetchPray() async {
  final response = await http
      .get('$baseUrl/sholat/format/json/jadwal/kota/703/tanggal/2017-02-07');
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DataPray.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
