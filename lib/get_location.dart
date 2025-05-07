import 'dart:convert';
import 'package:flutter_yandex_mapkit_example/api_keys.dart';
import 'package:http/http.dart' as http;

Future<String> getAddress(double latitude, double longitude) async {
  final apiKey = ApiKeys.geocodeApiKey;
  final url =
      'https://geocode-maps.yandex.ru/v1/?geocode=$longitude,$latitude&format=json&apikey=$apiKey&lang=uz_UZ&kind=house&rspn=1&results=1';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    
    final address =
        data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['metaDataProperty']['GeocoderMetaData']['text'];
    return address;
  } else {
    throw Exception('Failed to load address');
  }
}
