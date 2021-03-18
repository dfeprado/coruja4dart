import 'dart:io';

import 'coruja_request.dart';

abstract class CorujaRequestFactory {
  CorujaRequest build(HttpRequest request, Map<String, String> routeParams);
}