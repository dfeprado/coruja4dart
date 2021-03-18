import 'package:coruja/coruja.dart';

void main() {
  var coruja = Coruja();

  coruja.setRequestFactory(CorujaJsonRequestFactory());

  coruja.addGetRoute('/', (request) async {
    var json = await (request as CorujaJsonRequest).json;
    request.writeResponse(content: 'Hello World! Your name is ${json?["nome"]} ${json?["sobrenome"]}.');
  });

  coruja.addGetRoute('/say/hello/to/:name', (request) {
    request.writeResponse(content: 'Hello, ${request.routeParams["name"]}');
  });

  coruja.listen();
}
