import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/models/restaurants_model.dart';
import '../../../core/utils/constants.dart';

class RestaurantService {
  final http.Client _client;

  RestaurantService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<RestaurantModel>> getRestaurants() async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.restaurantsPath}',
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: AppConstants.defaultTimeout));

    if (response.statusCode != 200) {
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final list = body is List ? body : (body['data'] as List);

    return list
        .map<RestaurantModel>(
          (e) => RestaurantModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.restaurantsPath}/$id',
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: AppConstants.defaultTimeout));

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load restaurant: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final json = body is Map<String, dynamic> ? body : (body['data'] as Map<String, dynamic>);

    return RestaurantModel.fromJson(json);
  }
}

