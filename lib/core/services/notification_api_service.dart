import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationApiService {
  final http.Client _client;

  NotificationApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.notificationsPath}?userId=$userId',
    );

    final res = await _client
        .get(uri)
        .timeout(const Duration(seconds: AppConstants.defaultTimeout));

    if (res.statusCode != 200) {
      throw Exception('Failed to load notifications: ${res.statusCode}');
    }

    final body = jsonDecode(res.body);
    final list = body is List ? body : (body['data'] as List);

    return list
        .map<NotificationModel>(
          (e) => NotificationModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}

