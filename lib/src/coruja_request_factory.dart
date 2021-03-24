import 'dart:io';

import 'coruja_request.dart';

/// Define uma interface para todas as fábricas de requisições do Coruja.
/// 
/// É um _abstract factory_
/// 
/// Quando uma requisição chega ao Coruja, um objeto `CorujaRequest` é criado usando-se a fábrica
/// padrão. Esse objeto fornece facilidades para manusear a requisição.
/// 
/// A fábrica `CorujaJsonRequestFactory` é um exemplo de fábrica personalizada que retorna uma
/// instância personalizada do `CorujaRequest`. A definição dela contém um exemplo de uso.
abstract class CorujaRequestFactory {
  CorujaRequest build(HttpRequest request, Map<String, String> routeParams);
}