import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_cors/src/cors_defaults.dart';

/// Injects CORS headers into every [Response].
///
/// Also adds an immediate response to `OPTIONS` requests for preflight checks.
Middleware cors({
  List<String> allowedOrigins = const [CorsDefaults.allowOrigin],
  String allowMethods = CorsDefaults.allowMethods,
  String allowHeaders = CorsDefaults.allowHeaders,
  Map<String, String>? additional,
}) {
  return (handler) {
    return (context) async {
      String responseOrigin = allowedOrigins.first;

      final requestOrigin = context.request.headers['origin'];
      if (requestOrigin != null && allowedOrigins.contains(requestOrigin)) {
        responseOrigin = requestOrigin;
      }

      final headers = {
        HttpHeaders.accessControlAllowOriginHeader: responseOrigin,
        HttpHeaders.accessControlAllowMethodsHeader: allowMethods,
        HttpHeaders.accessControlAllowHeadersHeader: allowHeaders,
        if (additional != null) ...additional,
      };

      if (context.request.method == HttpMethod.options) {
        return Response(statusCode: HttpStatus.ok, headers: headers);
      }

      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          ...headers,
        },
      );
    };
  };
}
