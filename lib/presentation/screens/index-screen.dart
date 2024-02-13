import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  List<Map<String, dynamic>> productos = [];
  List<dynamic> categorias = [];

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener productos al iniciar el widget
    fetchProductos();
  }

  Future<void> fetchCategoriasInfo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in fetchCategoriasInfo: Token not available');
        return;
      }

      List<dynamic> nuevasCategorias = [];

      for (var producto in productos) {
        final idCategoria = producto['idcategoria'];
        print('Producto: $producto');

        final response = await http.get(
          Uri.parse(
              'https://api-postgress.onrender.com/api/categorias/$idCategoria'),
          headers: {'x-token': token},
        );

        if (response.statusCode == 200) {
          nuevasCategorias.add(json.decode(response.body));
        } else {
          throw Exception(
              'Error loading category information. Status code: ${response.statusCode}');
        }
      }

      setState(() {
        categorias = nuevasCategorias;
      });
    } catch (error) {
      print('Error in fetchCategoriasInfo: $error');
    }
  }

  
Future<void> fetchProductos() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print('Error in fetchProductos: Token not available');
      return;
    }

    final response = await http.get(
      Uri.parse('https://api-postgress.onrender.com/api/productos-activos'),
      headers: {'x-token': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Convertir List<dynamic> a List<Map<String, dynamic>>
      final List<Map<String, dynamic>> productosFiltrados =
          List<Map<String, dynamic>>.from(data);

      // Filtrar productos con cantidad menor al stock mínimo
      final List<Map<String, dynamic>> productosMenorStock = productosFiltrados
          .where((producto) => producto['cantidad'] < producto['stock_minimo'])
          .toList();

      for (var producto in productosMenorStock) {
        final idCategoria = producto['idcategoria'];
        final categoriaResponse = await http.get(
          Uri.parse(
              'https://api-postgress.onrender.com/api/categorias/$idCategoria'),
          headers: {'x-token': token},
        );

        if (categoriaResponse.statusCode == 200) {
          final categoriaData = json.decode(categoriaResponse.body);
          producto['categoria'] = categoriaData;
        } else {
          throw Exception(
              'Error loading category information. Status code: ${categoriaResponse.statusCode}');
        }
      }

      setState(() {
        productos = productosMenorStock;
      });

      await fetchCategoriasInfo();
    } else {
      throw Exception(
        'Error loading the list of products. Status code: ${response.statusCode}',
      );
    }
  } catch (error) {
    print('Error in fetchProductos: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Estas son las recomendaciones de los productos que podrías comprar:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              productos.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay recomendaciones de productos en este momento.',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          final categoria = producto['categoria'];

                          return Card(
                            elevation: 2.0,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 32),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${producto['nombre']}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          Row(
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                      text: 'Cantidad: ',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const WidgetSpan(
                                                      child: SizedBox(
                                                        width: 8,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${producto['cantidad']}',
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 138, 138, 138),
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                      text: 'Categoria: ',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const WidgetSpan(
                                                      child: SizedBox(
                                                        width: 8,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${categoria['nombre']}',
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 138, 138, 138),
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
