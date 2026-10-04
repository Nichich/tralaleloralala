import 'package:brainrot_dex/providers/brainrot_provider.dart';
import 'package:brainrot_dex/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  test('starts in loading and becomes loaded', () async {
    final provider = BrainrotProvider(FakeApiService.returns(sampleBrainrots));
    expect(provider.status, LoadStatus.loading);

    await provider.load();

    expect(provider.status, LoadStatus.loaded);
    expect(provider.items, hasLength(sampleBrainrots.length));
  });

  test('empty response gives empty status', () async {
    final provider = BrainrotProvider(FakeApiService.returns([]));
    await provider.load();
    expect(provider.status, LoadStatus.empty);
  });

  test('api error gives error status with message', () async {
    final provider = BrainrotProvider(FakeApiService.fails('Нет подключения к интернету'));
    await provider.load();
    expect(provider.status, LoadStatus.error);
    expect(provider.errorMessage, 'Нет подключения к интернету');
  });

  test('unexpected exception does not escape', () async {
    final provider = BrainrotProvider(FakeApiService(() async => throw Exception('boom')));
    await provider.load();
    expect(provider.status, LoadStatus.error);
    expect(provider.errorMessage, isNotEmpty);
  });

  test('unexpected Error does not leave the spinner forever', () async {
    final provider = BrainrotProvider(FakeApiService(() async => throw UnsupportedError('boom')));
    await provider.load();
    expect(provider.status, LoadStatus.error);
    expect(provider.errorMessage, isNotEmpty);
  });

  test('retry after error loads data', () async {
    final api = FakeApiService.fails('Нет сети');
    final provider = BrainrotProvider(api);
    await provider.load();

    api.handler = () async => sampleBrainrots;
    await provider.retry();

    expect(provider.status, LoadStatus.loaded);
    expect(api.calls, 2);
  });

  test('failed refresh keeps shown data and returns message', () async {
    final api = FakeApiService.returns(sampleBrainrots);
    final provider = BrainrotProvider(api);
    await provider.load();

    api.handler = () async => throw const ApiException('Нет сети');
    final error = await provider.refresh();

    expect(error, 'Нет сети');
    expect(provider.status, LoadStatus.loaded);
    expect(provider.items, hasLength(sampleBrainrots.length));
  });

  test('failed refresh without data shows error', () async {
    final provider = BrainrotProvider(FakeApiService.fails('Нет сети'));
    final error = await provider.refresh();

    expect(error, 'Нет сети');
    expect(provider.status, LoadStatus.error);
  });

  test('successful refresh returns null and updates items', () async {
    final api = FakeApiService.returns(sampleBrainrots.take(1).toList());
    final provider = BrainrotProvider(api);
    await provider.load();

    api.handler = () async => sampleBrainrots;
    expect(await provider.refresh(), isNull);
    expect(provider.items, hasLength(sampleBrainrots.length));
  });

  test('search ignores case and surrounding spaces', () async {
    final provider = BrainrotProvider(FakeApiService.returns(sampleBrainrots));
    await provider.load();

    expect(provider.search('  TUNG ').map((b) => b.id), ['tung_tung_tung_sahur']);
    expect(provider.search('bomb'), hasLength(2));
    expect(provider.search(''), hasLength(sampleBrainrots.length));
    expect(provider.search('nobody'), isEmpty);
  });
}
