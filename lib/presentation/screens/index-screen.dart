import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modulos_api/presentation/widgets/app_bar.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  List<Map<String, dynamic>> productos = [];

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener productos al iniciar el widget
    fetchProductos();
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
      // Decodificar la respuesta JSON
      final List<dynamic> data = json.decode(response.body);

      // Convertir List<dynamic> a List<Map<String, dynamic>>
      final List<Map<String, dynamic>> productosFiltrados =
          List<Map<String, dynamic>>.from(data);

      // Filtrar productos con cantidad menor al stock mínimo
      final List<Map<String, dynamic>> productosMenorStock = productosFiltrados
          .where((producto) => producto['cantidad'] < producto['stock_minimo'])
          .toList();

      // Asigna directamente productosMenorStock a productos
      setState(() {
        productos = productosMenorStock;
      });

      // Continúa con el resto de tu lógica
      // Por ejemplo, puedes llamar a fetchClientesInfo aquí
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
    appBar: AppBarMenu(
      title: 'Recomendaciones',
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Ajusta la posición hacia la parte superior
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Contenedor que envuelve el CircleAvatar para personalizar opacidad y espacio
          Container(
            margin: EdgeInsets.only(top: 50), // Espacio entre el avatar y el texto
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 90,
              backgroundImage: AssetImage("assets/images/VISOR 1.png"),
            ),
          ),
          SizedBox(height: 50),
          Text(
            'Estas son las recomendaciones de los productos que podrías comprar:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Table(
            defaultColumnWidth: FixedColumnWidth(180.0),
            border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'Producto',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'Recomendación',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              ...productos.map((producto) {
                return TableRow(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(producto['nombre']),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'Comprar',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    ),
  );
}
}