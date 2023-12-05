
import 'package:flutter/material.dart';
import 'package:modulos_api/presentation/screens/login_screen.dart';
import 'package:modulos_api/presentation/screens/principal_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 111, 174, 194),
      child: Column(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 178, 222, 180),
              image: DecorationImage(
                image: AssetImage('assets/images/VISOR 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: 270,
            child: ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.black,
              ),
              title: const Text(
                "Pagina principal",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrincipalScreen(),
                  ),
                );
              },
            ),
          ),
         
          const SizedBox(
            height: 400,
          ),
          Container(
              child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Cerrar Sesión"
                          ),
                        content: const Text("¿Está seguro de que desea cerrar sesión?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            
                            child: const Text(
                              "Cerrar Sesión",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.exit_to_app,color:Colors.black),
                    SizedBox(width: 9,),
                    Text("Cerrar Sesión",
                    style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
