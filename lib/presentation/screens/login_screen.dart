import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modulos_api/main.dart';
import 'package:modulos_api/presentation/screens/auth.dart';
import 'package:modulos_api/presentation/screens/principal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isVisible = true;

  void apiLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showNotification("Por favor, llene todos los campos", Colors.red);
      return;
    }

    try {
      final response = await _authService.login(email, password);
      print('API Response: $response');

      if (response is Map<String, dynamic>) {
        final message = response['message'];
        final user = response['usuario']; // Puede variar según la estructura de tu respuesta

        _showNotification(message, Colors.green);

        // Verifica si la respuesta contiene un token
        if (response.containsKey('token')) {
          print('Redirigiendo a la pantalla principal...'); // Agrega un mensaje de depuración
          // Agrega un ligero retraso antes de la redirección
          Future.delayed(const Duration(milliseconds: 500), () {
            // Redirige a la pantalla principal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PrincipalScreen(),
              ),
            );
          });
        } else {
          print('La respuesta no contiene un token.'); // Agrega un mensaje de depuración
        }
      } else {
        // Manejar otros casos de respuesta de la API
        _showNotification("Error en la respuesta de la API", Colors.red);
      }
    } catch (error) {
      // Error durante el inicio de sesión
      print('Error during login: $error');

      if (error is Exception) {
        String errorMessage = 'Error en el inicio de sesión';

        if (error.toString().contains('El usuario está inactivo.')) {
          errorMessage = 'El usuario está inactivo.';
        } else if (error.toString().contains('Credenciales incorrectas.')) {
          errorMessage = 'Credenciales incorrectas.';
        } else if (error.toString().contains('El usuario no está registrado.')) {
          errorMessage = 'El usuario no está registrado.';
        }

        _showNotification(errorMessage, Colors.red);
      }
    }
  }

  void _showNotification(String message, Color backgroundColor) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        right: 10.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    Timer(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).viewInsets;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
              onPressed: () {
                final myAppState = MyApp.of(context);
                if (myAppState != null) {
                  myAppState.changeTheme();
                }
              },
              icon: Theme.of(context).brightness == Brightness.light
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true, // Añade esta línea
        child: Padding(
          padding: EdgeInsets.only(
            bottom: padding.bottom > 0 ? padding.bottom + 20.0 : 1.0,
            top: padding.bottom > 0 ? 20.0 : 70.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: AssetImage("assets/images/VISOR 1.png"),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: _isVisible,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.password_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: _isVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  apiLogin();
                },
                child: const Text(
                  "Iniciar Sesión",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 15, 176, 50),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
