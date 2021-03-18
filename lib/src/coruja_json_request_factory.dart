import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'coruja_request_factory.dart';
import 'coruja_request.dart';

class CorujaJsonRequest extends CorujaRequest {
  Map<String, dynamic>? _jsonBody;
  bool _alreadyConvertedBody = false;
  CorujaJsonRequest(HttpRequest request, Map<String, String> routeParams) : super(request, routeParams);

  FutureOr<Map<String, dynamic>?> get json async {
    if (contentType != 'application/json') {
      throw FormatException('Not a valid JSON', 'Mime: $contentType');
    }

    if (_alreadyConvertedBody) {
      return _jsonBody;
    }

    _alreadyConvertedBody = true;
    var body = await super.body;
    if (body.isEmpty) {
      return null;
    }

    _jsonBody = JsonDecoder().convert(body);
    return _jsonBody;
  }

  void writeJsonResponse({int code = 200, Object? jsonContent}) {
    var content = JsonEncoder().convert(jsonContent);
    super.writeResponse(code: code, content: content);
  }
}

class CorujaJsonRequestFactory implements CorujaRequestFactory {
  @override
  CorujaRequest build(HttpRequest request, Map<String, String> routeParams) {
    return CorujaJsonRequest(request, routeParams);
  }
}