import 'dart:io';
import 'dart:convert';
import 'dart:async';

class CorujaRequest {
  final HttpRequest _request;
  final Map<String, String> routeParams;
  String? _body;

  CorujaRequest(this._request, this.routeParams);

  void writeResponse({int code = 200, String content = ''}) {
    _request.response
      ..statusCode = 200
      ..write(content)
      ..close();
  }

  FutureOr<String> get body async {
    if (_body != null) {
      return _body!;
    }

    var contentBuf = StringBuffer();
    await for (var chunk in utf8.decoder.bind(_request)) {
      contentBuf.write(chunk);
    }
    _body = contentBuf.toString();
    return _body!;
  }

  Map<String, String> get queryParams => _request.uri.queryParameters;
  String? get contentType => _request.headers.contentType?.mimeType;
}