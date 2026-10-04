import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/brainrot.dart';

const String kDataUrl =
    'https://raw.githubusercontent.com/Nichich/tralaleloralala/main/data/brainrots.json';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    http.Client? client,
    this.url = kDataUrl,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String url;
  final Duration timeout;

  Future<List<Brainrot>> fetchBrainrots() async {
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(url)).timeout(timeout);
    } on TimeoutException {
      throw const ApiException('Сервер долго не отвечает. Попробуй ещё раз');
    } on SocketException {
      throw const ApiException('Нет подключения к интернету');
    } on http.ClientException {
      throw const ApiException('Нет подключения к интернету');
    }

    if (response.statusCode != 200) {
      throw ApiException('Сервер ответил ошибкой (код ${response.statusCode})');
    }

    try {
      // Decode manually: without a charset header response.body falls back to latin1.
      return parseBrainrots(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('Данные пришли битые. Уже чиним');
    }
  }

  static List<Brainrot> parseBrainrots(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array');
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      return Brainrot.fromJson(item);
    }).toList();
  }
}
