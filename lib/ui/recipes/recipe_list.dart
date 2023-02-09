import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/recipe_model.dart';
import '../../network/recipe_service.dart';
import '../colors.dart';
import '../recipe_card.dart';
import '../widgets/custom_dropdown.dart';
import 'recipe_details.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';

  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List<APIHits> currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  List<String> previousSearches = <String>[];
  // Add _currentRecipes1 - Paso 1
  APIRecipeQuery? _currentRecipes1;

  @override
  void initState() {
    super.initState();
    // Call loadRecipes() - Paso 3
    loadRecipes();
    getPreviousSearches();
    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

  // getRecipeData() here
  // 1. Toma una consulta y las posiciones inicial y final de los datos de la
  // receta, que desde y para representar, respectivamente.
  Future<APIRecipeQuery> getRecipeData(String query, int from, int to) async {
    // 2. You define recipeJson, which stores the results from getRecipes(
    // after it finishes. It uses the from and to fields from step 1.
    final recipeJson = await RecipeService().getRecipes(query, from, to);
    // 3. La variable RecipeMap usa json.decode() de Dart para decodificar la
    // cadena en un mapa de tipo Map<String, dynamic>.
    final recipeMap = json.decode(recipeJson);
    // 4. Utilice el método de parseo JSON que creó en el capítulo anterior
    // para crear un modelo APIRecipeQuery.
    return APIRecipeQuery.fromJson(recipeMap);
  }

  // loadRecipes - Paso 2
  Future loadRecipes() async {
    // 1. Carga recipes1.json del directorio assets. rootBundle es una propiedad
    // de alto nivel que mantiene referencias a todos los items en la carpeta
    // assets. Este carga el archivo como un string.
    final jsonString = await rootBundle.loadString('assets/recipes1.json');
    setState(() {
      // 2. Usa el método incorporado jsonDecode() para convertir el string a un
      // mapa, luego usa fromJson(), el cual fue generado por tí, para hacer
      // una instancia de APIRecipeQuery.
      _currentRecipes1 = APIRecipeQuery.fromJson(jsonDecode(jsonString));
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void savePreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSearchKey)) {
      final searches = prefs.getStringList(prefSearchKey);
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                startSearch(searchTextController.text);
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Search'),
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      startSearch(searchTextController.text);
                    },
                    controller: searchTextController,
                  )),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
                              previousSearches.remove(value);
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startSearch(String value) {
    setState(() {
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();
      if (!previousSearches.contains(value)) {
        previousSearches.add(value);
        savePreviousSearches();
      }
    });
  }

  Widget _buildRecipeLoader(BuildContext context) {
    // 1. Chequea para ver si la lista de recetas es null
    if (_currentRecipes1 == null || _currentRecipes1?.hits == null) {
      return Container();
    }
    // Show a loading indicator while waiting for the movies
    return Flexible(
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Center(
            child: _buildRecipeCard(context, _currentRecipes1!.hits, 1),
          );
        },
      ),
    );
  }

  // Add _buildRecipeList()
  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
    // 2. Utiliza MediaQuery para obtener el tamaño de pantalla del dispositivo.
    // Luego establece una altura de elemento fija y crea dos columnas de
    // tarjetas cuyo ancho es la mitad del ancho del dispositivo.
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;
    // 3. Devuelves un widget que es flexible en ancho y alto.
    return Flexible(
      // 4. GridView es similar a ListView, pero permite algunas combinaciones
      // interesantes de filas y columnas. En este caso, usa GridView.builder()
      // porque conoce la cantidad de elementos y usará un itemBuilder.
      child: GridView.builder(
        // 5. Utiliza _scrollController, creado en initState(), para detectar
        // cuándo el desplazamiento llega a aproximadamente el 70% desde abajo.
        controller: _scrollController,
        // 6. El delegado SliverGridDelegateWithFixedCrossAxisCount tiene dos
        // columnas y establece la relación de aspecto.
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        // 7. La longitud de los elementos de la cuadrícula depende del número
        // de elementos en la lista de resultados.
        itemCount: hits.length,
        // 8. itemBuilder ahora usa _buildRecipeCard() para devolver una
        // tarjeta para cada receta. _buildRecipeCard() recupera la receta de
        // la lista de aciertos usando hits[index].recipe.
        itemBuilder: (BuildContext context, int index) {
          return _buildRecipeCard(recipeListContext, hits, index);
        },
      ),
    );
  }

  // Add _buildRecipeCard - Paso 4
  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    // 1. Encuentra la receta en el indice dado
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          topLevelContext,
          MaterialPageRoute(builder: (context) {
            return const RecipeDetails();
          }),
        );
      },
      // 2. Llama recipeStringCard, el cual muestra una bonita tarjeta debajo
      // del campo de búsqueda
      child: recipeCard(recipe),
    );
  }
}
