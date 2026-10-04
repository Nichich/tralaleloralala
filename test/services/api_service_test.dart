import 'dart:convert';
import 'dart:io';

import 'package:brainrot_dex/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _sample = '[{"id":"tralalero_tralala","name":"Tralalero Tralala",'
    '"description":"Акула в найках","superpower":"Бегает","rarity":"legendary",'
    '"aura":9000,"image":"","sound":"tralalero_tralala.mp3"}]';

// Bytes without a charset header - the same situation where response.body would garble Cyrillic.
http.Response _bytes(String body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(body), status);

ApiService _serviceWith(MockClientHandler handler) => ApiService(
      client: MockClient(handler),
      url: 'https://example.com/brainrots.json',
      timeout: const Duration(milliseconds: 100),
    );

Matcher _apiError(String fragment) =>
    throwsA(isA<ApiException>().having((e) => e.message, 'message', contains(fragment)));

void main() {
  test('parses list and decodes cyrillic as utf8', () async {
    final items = await _serviceWith((_) async => _bytes(_sample)).fetchBrainrots();

    expect(items, hasLength(1));
    expect(items.single.name, 'Tralalero Tralala');
    expect(items.single.description, 'Акула в найках');
  });

  test('returns empty list for empty array', () async {
    final items = await _serviceWith((_) async => _bytes('[]')).fetchBrainrots();
    expect(items, isEmpty);
  });

  test('non-200 status becomes ApiException with code', () {
    expect(_serviceWith((_) async => _bytes('Not found', 404)).fetchBrainrots(), _apiError('404'));
  });

  test('timeout becomes ApiException', () {
    final service = _serviceWith((_) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return _bytes(_sample);
    });
    expect(service.fetchBrainrots(), _apiError('долго не отвечает'));
  });

  test('SocketException becomes ApiException', () {
    expect(
      _serviceWith((_) async => throw const SocketException('offline')).fetchBrainrots(),
      _apiError('интернет'),
    );
  });

  test('ClientException becomes ApiException', () {
    expect(
      _serviceWith((_) async => throw http.ClientException('failed')).fetchBrainrots(),
      _apiError('интернет'),
    );
  });

  test('broken JSON becomes ApiException', () {
    expect(_serviceWith((_) async => _bytes('{not json')).fetchBrainrots(), _apiError('битые'));
  });

  test('object instead of array becomes ApiException', () {
    expect(_serviceWith((_) async => _bytes('{"id":"a"}')).fetchBrainrots(), _apiError('битые'));
  });

  test('item without name becomes ApiException', () {
    expect(_serviceWith((_) async => _bytes('[{"id":"a"}]')).fetchBrainrots(), _apiError('битые'));
  });

  test('invalid utf8 becomes ApiException', () {
    expect(
      _serviceWith((_) async => http.Response.bytes([0xff, 0xfe, 0xfd], 200)).fetchBrainrots(),
      _apiError('битые'),
    );
  });
}
