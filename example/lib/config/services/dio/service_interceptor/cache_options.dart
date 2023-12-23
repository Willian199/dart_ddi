import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:uuid/uuid.dart';

class DioCacheOptions {
  static CacheOptions? _options;

  static Future<CacheOptions> getCacheOptions() async {
    if (_options != null) {
      return _options!;
    }

    return _montarCache();
  }

  static Future<CacheOptions> _montarCache() async {
    Future<List<int>> decode(List<int> bytes) {
      return Future.value(base64Url.decode(latin1.decode(bytes)));
    }

    Future<List<int>> encode(List<int> valor) {
      const HtmlEscape sanitizer = HtmlEscape(HtmlEscapeMode.element);

      return Future.value(latin1.encode(sanitizer.convert(base64Url.encode(valor))));
    }

    final CacheCipher cipher = CacheCipher(decrypt: decode, encrypt: encode);

    final CacheOptions options = CacheOptions(
      // A default store is required for interceptor.
      store: ddi(),
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [204, 400, 404, 408, 500, 501, 502, 504],
      // Default. Body and headers encryption with your own algorithm.
      cipher: cipher,
      // Default. Key builder to retrieve requests.
      keyBuilder: _buildKey,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended when [true].
      allowPostMethod: true,
    );

    _options = options;

    return Future.value(_options);
  }

  static String _buildKey(RequestOptions request) {
    const Uuid uuid = Uuid();

    String key = request.uri.toString();

    if (request.data != null) {
      key += request.data!.toString();
    }

    return uuid.v5(Uuid.NAMESPACE_URL, key);
  }
}
