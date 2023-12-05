import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VentasScreenActivos extends StatefulWidget {
  const VentasScreenActivos({Key? key}) : super(key: key);

  @override
  State<VentasScreenActivos> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreenActivos> {
  List<dynamic> ventas = [];
  List<dynamic> clientes = [];
  List<dynamic> productos = [];
  List<dynamic> servicios = [];

  @override
  void initState() {
    super.initState();
    fetchVentas();
  }

  void refreshClientes() {
    setState(() {
      fetchVentas();
    });
  }

  Future<void> fetchVentas() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in fetchClientes: Token not available');
        return;
      }

      final response = await http.get(
        Uri.parse('https://api-postgress.onrender.com/api/ventas-activas'),
        headers: {'x-token': token},
      );

      if (response.statusCode == 200) {
        setState(() {
          ventas = json.decode(response.body);
        });

        fetchClientesInfo();
      } else {
        throw Exception(
            'Error loading the list of clients. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in fetchClientes: $error');
    }
  }

  Future<String> formatTotalVentas(double totalVentas) async {
    final formatter =
        NumberFormat('#,###.##', 'es'); // 'es' para formato en español
    return formatter.format(totalVentas);
  }

  Future<void> fetchClientesInfo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in fetchClientesInfo: Token not available');
        return;
      }

      List<dynamic> nuevosClientes = [];

      for (var venta in ventas) {
        final idCliente = venta['idcliente'];
        print('Venta: $venta');

        final response = await http.get(
          Uri.parse(
              'https://api-postgress.onrender.com/api/clientes/$idCliente'),
          headers: {'x-token': token},
        );

        if (response.statusCode == 200) {
          nuevosClientes.add(json.decode(response.body));
        } else {
          throw Exception(
              'Error loading client information. Status code: ${response.statusCode}');
        }
      }

      setState(() {
        clientes = nuevosClientes;
      });
    } catch (error) {
      print('Error in fetchClientesInfo: $error');
    }
  }

  Future<String> getNombreProducto(int idProducto) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in getNombreProducto: Token not available');
        return 'Nombre no disponible';
      }

      final response = await http.get(
        Uri.parse(
            'https://api-postgress.onrender.com/api/productos/$idProducto'),
        headers: {'x-token': token},
      );

      if (response.statusCode == 200) {
        final producto = json.decode(response.body);
        return producto['nombre'];
      } else {
        throw Exception(
            'Error loading product information. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in getNombreProducto: $error');
      return 'Nombre no disponible';
    }
  }

  Future<String> getNombreServicio(int idServicio) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in getNombreServicio: Token not available');
        return 'Nombre no disponible';
      }

      final response = await http.get(
        Uri.parse(
            'https://api-postgress.onrender.com/api/servicios/$idServicio'),
        headers: {'x-token': token},
      );

      if (response.statusCode == 200) {
        final servicio = json.decode(response.body);
        return servicio['nombre'];
      } else {
        throw Exception(
            'Error loading service information. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in getNombreServicio: $error');
      return 'Nombre no disponible';
    }
  }

  String formatPrecio(num precio) {
    final formatter = NumberFormat('#,###.##', 'es');
    return formatter.format(precio);
  }

  String formatSubtotal(num subtotal) {
    final formatter = NumberFormat('#,###.##', 'es');
    return formatter.format(subtotal);
  }

  List<Widget> buildDetalleProductosWidgets(List<dynamic> detalleProductos) {
    List<Widget> widgets = [];

    if (detalleProductos.isEmpty) {
      widgets.add(
        Center(
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: const Text(
              'No hay productos registrados',
              style: TextStyle(
                color: Color.fromARGB(255, 138, 138, 138),
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      );
    } else {
      for (var detalleProducto in detalleProductos) {
        if (detalleProducto['precio'] != null &&
            detalleProducto['cantidadproducto'] != null) {
          var subtotal = double.parse(detalleProducto['precio'].toString()) *
              detalleProducto['cantidadproducto'];
          widgets.add(
            Container(
              margin: const EdgeInsets.all(15.0), // Márgenes exteriores
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Padding interno
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: getNombreProducto(detalleProducto['idproducto']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return const Text(
                            'Error obteniendo el nombre del producto',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          final nombreProducto =
                              snapshot.data ?? 'Nombre no disponible';
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Producto: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                nombreProducto,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 138, 138, 138),
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cantidad: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${detalleProducto['cantidadproducto']}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 138, 138, 138),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2), // Reduzco el espacio vertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Precio: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatPrecio(detalleProducto['precio']),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 138, 138, 138),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2), // Reduzco el espacio vertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal: ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatSubtotal(subtotal),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 138, 138, 138),
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    // Agrega aquí otros atributos según sea necesario
                  ],
                ),
              ),
            ),
          );
        } else {
          widgets.add(const Text(
            'No se puede calcular el subtotal porque el precio o la cantidad es nula.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ));
        }
      }
    }

    return widgets;
  }

  List<Widget> buildDetalleServiciosWidgets(List<dynamic> detalleServicios) {
    List<Widget> widgets = [];

    if (detalleServicios.isEmpty) {
      widgets.add(
        Center(
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: const Text(
              'No hay servicios registrados',
              style: TextStyle(
                color: Color.fromARGB(255, 138, 138, 138),
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      );
    } else {
      for (var detalleServicio in detalleServicios) {
        widgets.add(Container(
          margin: const EdgeInsets.all(15.0), // Márgenes exteriores
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0), // Padding interno
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: getNombreServicio(detalleServicio['idservicio']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error obteniendo el nombre del servicio',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      final nombreServicio =
                          snapshot.data ?? 'Nombre no disponible';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Servicio: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            nombreServicio,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 138, 138, 138),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatPrecio(detalleServicio['precio']),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 138, 138, 138),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatPrecio(detalleServicio['precio']),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 138, 138, 138),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5), // Espacio reducido entre servicios
              ],
            ),
          ),
        ));
      }
    }

    return widgets;
  }

  void _mostrarDetallesBottomSheet(
      BuildContext context, dynamic venta, dynamic cliente) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.5, // Ajusta el factor según sea necesario
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              // Título de Detalles de Productos
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Detalles de Productos',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Lista de Detalles de Productos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildDetalleProductosWidgets(
                  venta['DetalleVentaProductos'],
                ),
              ),
              const SizedBox(height: 16.0),
              // Título de Detalles de Servicios
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Detalles de Servicios',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Lista de Detalles de Servicios
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildDetalleServiciosWidgets(
                  venta['DetalleVentaServicios'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalVentas = 0.0;

    for (var venta in ventas) {
      totalVentas += double.parse(venta['valortotal'].toString());
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                if (index < clientes.length) {
                  final venta = ventas[index];
                  final cliente = clientes[index];

                  List<Widget> detallesProductosWidgets = [];
                  if (venta['DetalleVentaProductos'] != null &&
                      (venta['DetalleVentaProductos'] as List).isNotEmpty) {
                    detallesProductosWidgets = buildDetalleProductosWidgets(
                        venta['DetalleVentaProductos']);
                  } else {
                    detallesProductosWidgets.add(
                      const Text(
                        'No hay productos registrados',
                        style: TextStyle(
                          color: Color.fromARGB(255, 138, 138, 138),
                          fontSize: 14.0,
                        ),
                      ),
                    );
                  }

                  List<Widget> detallesServiciosWidgets = [];
                  if (venta['DetalleVentaServicios'] != null &&
                      (venta['DetalleVentaServicios'] as List).isNotEmpty) {
                    detallesServiciosWidgets = buildDetalleServiciosWidgets(
                        venta['DetalleVentaServicios']);
                  } else {
                    detallesServiciosWidgets.add(
                      const Text(
                        'No hay servicios registrados',
                        style: TextStyle(
                          color: Color.fromARGB(255, 138, 138, 138),
                          fontSize: 14.0,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: InkWell(
                          onTap: () {
                            _mostrarDetallesBottomSheet(
                                context, venta, cliente);
                          },
                          child: Card(
                            elevation: 2.0,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet,
                                          size: 32,
                                          color: Colors.green.withOpacity(0.5)),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${cliente['nombre']} ${cliente['apellido']}',
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Text(
                                            'Fecha: ${venta['fecha']}',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 138, 138, 138),
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: 'No: ',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const WidgetSpan(
                                                  child: SizedBox(
                                                    width: 8,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${venta['numerofactura']}',
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
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money,
                                              color: Colors.green),
                                          Text(
                                            '${formatPrecio(venta['valortotal'])}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      _mostrarDetallesBottomSheet(
                                          context, venta, cliente);
                                    },
                                    child: const Text(
                                      'Mostrar Detalles',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 0.01),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            color: const Color.fromARGB(
                255, 255, 255, 255), // Color de fondo del área del botón
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Ventas:',
                  style: TextStyle(fontSize: 16.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.black),
                  ),
                  child: FutureBuilder<String>(
                    future: formatTotalVentas(totalVentas),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Cargando...');
                      } else if (snapshot.hasError) {
                        return Text('Error al formatear el total de ventas');
                      } else {
                        return Text(
                          snapshot.data ?? '',
                          style: TextStyle(fontSize: 16.0),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
