import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class APIRecipeQuery {
  // Add APIRecipeQuery.fromJson
  factory APIRecipeQuery.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeQueryFromJson(json);

  Map<String, dynamic> toJson() => _$APIRecipeQueryToJson(this);
  //Add fields here
  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;

  //APIRecipeQuery constructor
  APIRecipeQuery({
    required this.query,
    required this.from,
    required this.to,
    required this.more,
    required this.count,
    required this.hits,
  });
}

// @JsonSerializable() class APIHits
// 1. Marca la clase como serializable
@JsonSerializable()
class APIHits {
  // 2. Define un campo de clase APIRecipe, el cual creará pronto
  APIRecipe recipe;

  // 3. Define un constructor the acepta un parámetro recipe
  APIHits({required this.recipe});

  // 4. Añade los métodos para la serialización de JSON
  factory APIHits.fromJson(Map<String, dynamic> json) =>
      _$APIHitsFromJson(json);
}

// Add @JsonSerializable() class APIRecipe
@JsonSerializable()
class APIRecipe {
  // 1. Define los campos para una receta. label es el text mostrado e image es
  // la URL para la imagen a mostrar.
  String label;
  String image;
  String url;
  // 2. Indica que cada receta tiene una lista de ingredientes.
  List<APIIngredients> ingredients;
  double calories;
  double totalWeight;
  double totalTime;

  APIRecipe({
    required this.label,
    required this.image,
    required this.url,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
  });

  // 3. Crea los métodos factory para serializar JSON
  factory APIRecipe.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$APIRecipeToJson(this);
}

// Global Helper Functions
// 4. Añade un método ayudante para cambiar una caloria a un String
String getCalories(double? calories) {
  if (calories == null) return '0 KCAL';
  return '${calories.floor()} KCAL';
}

// 5. Añade un método ayudante para el peso a un String
String getWeight(double? weight) {
  if (weight == null) return '0g';
  return '${weight.floor()}g';
}

// @JsonSerializable() class APIIngredients
@JsonSerializable()
class APIIngredients {
  // 6. Indica que el campo nombre de esta clase mapea al campo JSON llamado
  // text
  @JsonKey(name: 'text')
  String name;
  double weight;

  APIIngredients({
    required this.name,
    required this.weight,
  });

  // 7. Crea los métodos para serializar JSON
  factory APIIngredients.fromJson(Map<String, dynamic> json) =>
      _$APIIngredientsFromJson(json);

  Map<String, dynamic> toJson() => _$APIIngredientsToJson(this);
}
