
import 'package:flutter/material.dart';
import 'package:modulos_api/presentation/screens/index-screen.dart';
import 'package:modulos_api/presentation/screens/ventas_screen_activos.dart';
import 'package:modulos_api/presentation/widgets/app_bar.dart';
import 'package:modulos_api/presentation/widgets/drawer.dart';


import 'ventas_screen_inactivos.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({Key? key}) : super(key: key);

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    IndexScreen(),
    VentasScreenActivos(),
    VentasScreenInactivos(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(title: _appBarTitle()),
      drawer: MenuDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Ventas activas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Ventas anuladas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 92, 168, 215),
        onTap: _onItemTapped,
      ),
    );
  }
String _appBarTitle() {
  switch (_selectedIndex) {
    case 0:
      return 'Recomendaciones';
    case 1:
      return 'Ventas';
    default:
      return 'Ventas';
  }
}

}
