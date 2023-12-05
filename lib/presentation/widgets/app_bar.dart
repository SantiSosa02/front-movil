import 'package:flutter/material.dart';
import 'package:modulos_api/main.dart';
import 'package:modulos_api/presentation/screens/login_screen.dart';
import 'package:modulos_api/presentation/styles/color_scheme.dart';
import 'package:modulos_api/presentation/screens/auth.dart';

class AppBarMenu extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const AppBarMenu({Key? key, required this.title}) : super(key: key);

  @override
  State<AppBarMenu> createState() => _AppBarMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _AppBarMenuState extends State<AppBarMenu> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dialogTheme: DialogTheme(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12.0), // Ajusta el radio de las esquinas
                      ),
                    ),
                  ),
                  child: AlertDialog(
                    title: const Text("Cerrar Sesión"),
                    content:
                        const Text("¿Está seguro de que desea cerrar sesión?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                              color: Colors.black.withOpacity(
                                  0.7)), // Cambia el color del texto a gris
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await authService.logout();

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Cerrar Sesión",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Row(
            children: [
              Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            final myAppState = MyApp.of(context);
            if (myAppState != null) {
              myAppState.changeTheme(); // Call the changeTheme method
            }
          },
          icon: Theme.of(context).brightness == Brightness.light
              ? const Icon(Icons.dark_mode)
              : const Icon(Icons.light_mode),
        )
      ],
    );
  }
}
