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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Por favor, llene todos los campos"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final response = await _authService.login(email, password);

if (response.containsKey('token')) {
  // Inicio de sesión exitoso
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Inicio de sesión exitoso"),
      backgroundColor: Colors.green,
    ),
  );

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
} else if (response.containsKey('error')) {
    final error = response['error'];

    if (error == 'El usuario está inactivo.') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El usuario está inactivo."),
          backgroundColor: Colors.yellow,
        ),
      );

      // Puedes agregar más lógica aquí, como redirigir a una pantalla de reactivación, etc.
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error en el inicio de sesión"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // Establece la altura deseada
        child: AppBar(
          automaticallyImplyLeading: false, // Oculta la flecha de retroceso
          actions: [
            IconButton(
              onPressed: () {
                final myAppState = MyApp.of(context);
                if (myAppState != null) {
                  myAppState
                      .changeTheme(); // Llama al método para cambiar el tema
                }
              },
              icon: Theme.of(context).brightness == Brightness.light
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 38),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 70,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.3), // Color de la sombra
                      spreadRadius: 5, // Cuánto se extiende la sombra
                      blurRadius: 7, // Cuánto se difumina la sombra
                      offset:
                          Offset(0,2), // Desplazamiento de la sombra (x, y)
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: AssetImage("assets/images/VISOR 1.png"),
                ),
              ),
              const SizedBox(
                height: 90,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Correo electronico",
                  hintText: "Ingrese su correo",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: passwordController,
                obscureText: _isVisible,
                decoration: InputDecoration(
                    labelText: "Contraseña",
                    hintText: "Ingrese su contraseña",
                    prefixIcon: const Icon(Icons.password_outlined),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isVisible = !_isVisible;
                          });
                        },
                        icon: _isVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off))),
              ),
              const SizedBox(
                height: 63,
              ),
              ElevatedButton(
                onPressed: () {
                  apiLogin();
                },
                child: const Text(
                  "Iniciar Sesión",
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 15, 176, 50))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
