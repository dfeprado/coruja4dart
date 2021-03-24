import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'coruja_request_factory.dart';
import 'coruja_request.dart';

/// Define uma personalização do `CorujaRequest` com facilidades para tratar requisições
/// que tenham corpo em formato JSON ou precisem responder com conteúdo em JSON.
class CorujaJsonRequest extends CorujaRequest {
  Map<String, dynamic>? _jsonBody;
  bool _alreadyConvertedBody = false;
  CorujaJsonRequest(HttpRequest request, Map<String, String> routeParams) : super(request, routeParams);

  /// Obtém, do corpo da requisição, um `Map<String, dynamic>` representando um JSON interpretado.
  /// 
  /// Na primeira invocação o corpo da requisição é analisado e processado para passar pela conversão
  /// para JSON. Caso o formato do corpo não seja um _application/json_ a propriedade retornará um
  /// `FormatException`.
  /// 
  /// Nas demais invocações retorna instantâneamente, através de um cache formado na primeira execução
  /// bem-sucedida.
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

  /// Facilita a resposta quando o conteúdo deve ser um JSON.
  /// 
  /// O parâmetro `Object? jsonContent` deve receber um objeto capaz de ser convertido
  /// para uma string JSON.
  void writeJsonResponse({int code = 200, Object? jsonContent}) {
    var content = JsonEncoder().convert(jsonContent);
    super.writeResponse(code: code, content: content);
  }
}

/// Define uma customização da _abstract factory_ `CorujaRequestFactory` que cria instâncias
/// de `CorujaJsonRequest` ao invés do `CorujaRequest` comum.
/// 
/// # Exemplo de uso
/// ```dart
/// var coruja = Coruja();
/// 
/// // Define a fábrica padrão dos adapters de requisição como sendo a CorujaRequestFactory
/// // Assim todas as funções responsáveis por requisições receberão uma instância de um
/// // CorujaJsonRequest ao invés de um **CorujaRequest
/// coruja.setRequestFactory(CorujaJsonRequestFactory());
/// 
/// coruja.addGetRoute('/some/path', (request) {
///   // Aqui o request é recebido como CorujaRequest, mas pode ser especializado para
///   // um CorujaJsonRequest graças à nova fábrica.
///   (request as CorujaJsonRequest).writeJsonResponse(content: <String>['Some', 'Response', 'Array']);
/// });
/// 
/// coruja.listen();
/// ```
class CorujaJsonRequestFactory implements CorujaRequestFactory {
  @override
  CorujaRequest build(HttpRequest request, Map<String, String> routeParams) {
    return CorujaJsonRequest(request, routeParams);
  }
}