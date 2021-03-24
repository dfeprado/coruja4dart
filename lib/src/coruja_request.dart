import 'dart:io';
import 'dart:convert';
import 'dart:async';

/// Representa uma requisição HTTP com facilidades
/// 
/// É um adapter de um HttpRequest para as funções responsáveis de requisições
class CorujaRequest {
  final HttpRequest _request;
  final Map<String, String> routeParams;
  String? _body;

  /// Cria um novo CorujaRequest que recebe um HttpRequest e um Map<String, String> com
  /// os parâmetros de rotas
  CorujaRequest(this._request, this.routeParams);

  /// Envia um retorno ao cliente HTTP definindo o código de resposta (code) e seu conteúdo (content).
  /// 
  /// O código padrão de resposta é 200.
  /// 
  /// O conteúdo padrão de resposta é uma string vazia.
  /// 
  /// Encerra a requisição HTTP quando invocado. I.E. HttpRequest.close()
  void writeResponse({int code = 200, String content = ''}) {
    _request.response
      ..statusCode = code
      ..write(content)
      ..close();
  }

  /// Processa e retorna o conteúdo do corpo da requisição (se houver).
  /// 
  /// Transforma o conteúdo usando UTF8.
  /// 
  /// Quando invocado pela primeira vez faz o processamento do conteúdo e o armazena
  /// num cache. Nas demais invocações o processamento não é feito e o conteúdo do cache é retornado
  /// imediatamente.
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

  /// Retorna um `Map<String, String>` com os parâmetros de consulta (_query params_)
  Map<String, String> get queryParams => _request.uri.queryParameters;

  /// Retorna o tipo do corpo da requisição (_content type: mime_)
  String? get contentType => _request.headers.contentType?.mimeType;
}