import 'dart:developer';

import 'package:http/http.dart';

const String apiKey = 'e6eabceb1d3e8261d879717141fcaf63';
const String apiId = 'f1029133';
const String apiUrl = 'https://api.edamam.com/search';

class RecipeService {
  // 1. Retorna un Future
  Future getData(String url) async {
    // 2. response no tiene un valor hasta que el await es completado.
    final response = await get(Uri.parse(url));
    // 3. Un statusCode de 200 signifaca que la petición fue exitosa.
    if (response.statusCode == 200) {
      // 4. Retorna el resultado embebido en response.body
      return response.body;
    } else {
      // 5. De otro modo, usted tiene un error.
      log(response.body);
    }
  }

  // getRecipes
  // 1. Crea un nuevo método, getRecipes(), Usa Future<dynamic> para este
  // método porque no sabe cual tipo de dato retornará o cuando este finaliza
  Future<dynamic> getRecipes(String query, int from, int to) async {
    // 2. Usa await para decirle a la app que espere hasta que getData()
    // returne su resultado
    final recipeData = await getData(
        '$apiUrl?app_id=$apiId&app_key=$apiKey&q=$query&from=$from&to=$to');
    // 3. Returna el dato recibido desde la API
    return recipeData;
  }
}
