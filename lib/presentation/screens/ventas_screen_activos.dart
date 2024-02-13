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

Future<List<dynamic>> obtenerAbonos(int idVenta) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print('Error in obtenerAbonos: Token not available');
      return [];
    }

    final response = await http.get(
      Uri.parse('https://api-postgress.onrender.com/api/abonos-venta/$idVenta'),
      headers: {'x-token': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      print('Error al obtener los abonos. Código de estado: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    print('Error al obtener los abonos: $error');
    return [];
  }
}

  List<Widget> buildDetalleAbonosWidgets(List<dynamic>? detalleAbonos) {
    List<Widget> widgets = [];

    if (detalleAbonos == null || detalleAbonos.isEmpty) {
      widgets.add(
        Center(
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: const Text(
              'No hay abonos registrados',
              style: TextStyle(
                color: Color.fromARGB(255, 138, 138, 138),
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      );
    } else {
      for (var detalleAbono in detalleAbonos) {
        widgets.add(Container(
          margin: const EdgeInsets.all(15.0),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fecha abono: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      detalleAbono['fechaabono'].toString(),
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
                      'Valor del Abono: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatPrecio(detalleAbono['valorabono']),
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
                      'Valor Restante: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatPrecio(detalleAbono['valorrestante']),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 138, 138, 138),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
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
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            color: Colors.white,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              // Sección de Detalles de Productos
              _buildSection(
                title: 'Detalles de Productos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildDetalleProductosWidgets(
                      venta['DetalleVentaProductos']),
                ),
              ),
              // Sección de Detalles de Servicios
              _buildSection(
                title: 'Detalles de Servicios',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildDetalleServiciosWidgets(
                      venta['DetalleVentaServicios']),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Container(
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          child: child,
        ),
      ],
    );
  }

  void _mostrarDetallesAbonosBottomSheet(
    BuildContext context,
    dynamic venta,
    dynamic cliente,
    int idVenta, // Agrega el parámetro idVenta aquí
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            color: Colors.white,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Detalles de Abonos
                  _buildSection(
                    title: 'Detalles de Abonos',
                    child: FutureBuilder<List<dynamic>>(
                      future: obtenerAbonos(idVenta), // Usa el idVenta aquí
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Cargando abonos...');
                        } else if (snapshot.hasError) {
                          return const Text('Error al cargar abonos');
                        } else {
                          List<dynamic> abonos = snapshot.data ?? [];
                          if (abonos.isEmpty) {
                            return const Text('No hay abonos registrados');
                          } else {
                            List<Widget> abonosWidgets =
                                buildDetalleAbonosWidgets(abonos);
                            return Column(children: abonosWidgets);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  // Obtener la fecha actual
  DateTime now = DateTime.now();

  // Obtiene el primer día del mes actual
  DateTime firstDayOfThisMonth = DateTime(now.year, now.month, 1);

  // Obtiene el último día del mes actual
  DateTime lastDayOfThisMonth = DateTime(now.year, now.month + 1, 0);

  // Filtra las ventas del mes actual
  List<dynamic> ventasDelMesActual = ventas.where((venta) {
    DateTime fechaVenta = DateTime.parse(venta['fecha']);
    return fechaVenta.isAfter(firstDayOfThisMonth) && fechaVenta.isBefore(lastDayOfThisMonth);
  }).toList();

  // Suma las ventas del mes actual
  double totalVentasMesActual = 0.0;
  for (var venta in ventasDelMesActual) {
    totalVentasMesActual += double.tryParse(venta['valortotal'].toString()) ?? 0.0;
  }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ventas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay ventas registradas',
                      style: TextStyle(
                        color: Color.fromARGB(255, 138, 138, 138),
                        fontSize: 16.0,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      if (index < clientes.length) {
                        final venta = ventas[index];
                        final cliente = clientes[index];

                        List<Widget> detallesProductosWidgets = [];
                        if (venta['DetalleVentaProductos'] != null &&
                            (venta['DetalleVentaProductos'] as List)
                                .isNotEmpty) {
                          detallesProductosWidgets =
                              buildDetalleProductosWidgets(
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
                            (venta['DetalleVentaServicios'] as List)
                                .isNotEmpty) {
                          detallesServiciosWidgets =
                              buildDetalleServiciosWidgets(
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

                        return Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(9.0),
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
                                        Icon(
                                          Icons.account_balance_wallet,
                                          size: 32,
                                          color: Colors.green.withOpacity(0.5),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${cliente['nombre']} ${cliente['apellido']}',
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Fecha: ${venta['fecha']}',
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 138, 138, 138),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                        100), // Espacio adicional entre la fecha y el estado de pago
                                                // Estado de pago
                                                Text(
                                                  '${venta['tipopago']}',
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
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _mostrarDetallesBottomSheet(
                                                context, venta, cliente);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.green,
                                            onPrimary: Colors.white,
                                            minimumSize: Size(0,
                                                30), // Ajusta el tamaño del botón según tus preferencias
                                          ),
                                          child: const Text(
                                            'Detalles',
                                          ),
                                        ),
                                        const SizedBox(
                                            width:
                                                10), // Ajusta el espacio según tus preferencias
                                        Visibility(
                                          visible:
                                              venta['tipopago'] == 'Credito',
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _mostrarDetallesAbonosBottomSheet(
                                                context,
                                                venta,
                                                cliente,
                                                venta[
                                                    'idventa'], // Pasa el idventa aquí
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              onPrimary: Colors.white,
                                              minimumSize: Size(0,
                                                  30), // Ajusta el tamaño del botón según tus preferencias
                                            ),
                                            child: const Text(
                                              'Abonos',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ]);
                      } else {
                        return Container();
                      }
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total ventas del último mes:',
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
                    future: formatTotalVentas(totalVentasMesActual),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Cargando...');
                      } else if (snapshot.hasError) {
                        return const Text('Error al formatear el total de ventas');
                      } else {
                        return Text(
                          snapshot.data ?? '',
                          style: const TextStyle(fontSize: 16.0),
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
