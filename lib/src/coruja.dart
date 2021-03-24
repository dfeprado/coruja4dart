import 'dart:io';
import 'coruja_request.dart';
import 'coruja_request_factory.dart';

/// Esse é o tipo da função responsável por um caminho de uma requisição GET/POST
/// 
/// A implementação das funções responsáveis devem seguir essa assinatura.
typedef CorujaFunction = Function(CorujaRequest request);

class _CorujaRoute {
  final _routeParamNames = <String>[];
  late RegExp _pathPattern;

  _CorujaRoute(String path) {
    // Procura por parâmetros de rota no caminho
    var routeParams = RegExp(r':([a-z0-9]+)', caseSensitive: false).allMatches(path);
    for (var routeParam in routeParams) {
      _routeParamNames.add(routeParam.group(1)!);
    }

    // Substitui os parâmetros de rota por grupos de expressão regular
    path = path.replaceAll(RegExp(r':[a-z0-9]+', caseSensitive: false), '([a-z0-9]+)');

    // Cria a expressão regular do caminho
    _pathPattern = RegExp('^'+path+r'$', caseSensitive: false);
  }

  // Retorna NULL se o caminho não satisfazer o padrão
  RegExpMatch? isMatch(String path) {
    return _pathPattern.firstMatch(path);
  }

  // Retorna um mapa de parâmetros de rota do tipo {nome: valor}
  Map<String, String> getRouteParamsMap(RegExpMatch routeParamsMatch) {
    var map = <String, String>{};
    for (var i = 0; i < _routeParamNames.length; i++) {
      map[_routeParamNames[i]] = routeParamsMatch.group(i+1)!;
    }
    return map;
  }
}

class _DefaultCorujaRequestFactory implements CorujaRequestFactory {
  @override
  CorujaRequest build(HttpRequest request, Map<String, String> routeParams) {
    return CorujaRequest(request, routeParams);
  }
}

/// Representa um servidor HTTP com facilidades para manipulação de requisições GET e POST
class Coruja {
  HttpServer? _httpServer;
  final _getRoutes = <_CorujaRoute, CorujaFunction>{};
  final _postRoutes = <_CorujaRoute, CorujaFunction>{};
  CorujaRequestFactory _requestFactory = _DefaultCorujaRequestFactory();

  /// Adiciona um caminho (path) e uma função responsável (fn) por ele.
  /// 
  /// Quando uma requisição do tipo GET satisfazer o caminho, a função responsável
  /// será invocada.
  void addGetRoute(String path, CorujaFunction fn) {
    _getRoutes[_CorujaRoute(path)] = fn;
  }

  /// Adiciona um caminho (path) e uma função responsável (fn) por ele.
  /// 
  /// Quando uma requisição do tipo POST satisfazer o caminho, a função responsável
  /// será invocada.
  void addPostRoute(String path, CorujaFunction fn) {
    _postRoutes[_CorujaRoute(path)] = fn;
  }

  /// Altera a fábrica de requisições padrão por uma outra qualquer que herde
  /// de CorujaRequestFactory
  void setRequestFactory(CorujaRequestFactory newFactory) {
    _requestFactory = newFactory;
  }

  /// Inicia o servidor HTTP na porta desejada.
  /// 
  /// A porta padrão é a 8181.
  void listen({int port = 8181}) {
    if (_httpServer != null) {
      return;
    }

    HttpServer.bind(InternetAddress.anyIPv4, port).then((server) {
      _httpServer = server;

      _httpServer?.listen(_onData);
    });
  }

  void _onData(HttpRequest request) {
    // Define qual conjunto de rotas usar
    Map<_CorujaRoute, CorujaFunction>? routes;
    switch (request.method) {
      case 'GET':
        routes = _getRoutes;
        break;
      case 'POST':
        routes = _postRoutes;
        break;
    }

    // Procura uma rota que satisfaça o caminho da requisição
    RegExpMatch? match;
    if (routes != null) {
      for (var corujaRoute in routes.keys) {
        match = corujaRoute.isMatch(request.uri.path); 
        if (match != null) {
          routes[corujaRoute]!(_requestFactory.build(request, corujaRoute.getRouteParamsMap(match)));
          return;
        }
      }
    }

    // Resposta padrão para requisições não satisfeitas
    request.response
      ..statusCode = 404
      ..close();
  }

  /// Encerra o servidor HTTP
  /// 
  /// Não retorna nenhum erro caso o servidor não tenha iniciado.
  void close() {
    _httpServer?.close(force: true).then((v) {
      _httpServer = null;
    });
  }
}