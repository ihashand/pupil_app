import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/screens/login_register_screens/register_screen.dart';
import 'package:pet_diary/bottom_app_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final double startScale = 1.0;
  final double endScale = 1.1;
  final Duration shineDuration = const Duration(seconds: 3);

  bool showLoginForm = false;
  bool isLoading = false; // Flaga ładowania

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: shineDuration,
      vsync: this,
    )..repeat(reverse: true);

    _shineAnimation = Tween<double>(begin: startScale, end: endScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleLoginForm() {
    setState(() {
      showLoginForm = !showLoginForm;
    });
  }

  void navigateToRegister() {
    Navigator.of(context).push(_createRoute(const RegisterScreen()));
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  Future<void> login() async {
    setState(() {
      isLoading = true; // Pokaż spinner ładowania
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        isLoading = false; // Ukryj spinner ładowania
      });

      navigateToHomeScreen();
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false; // Ukryj spinner ładowania w przypadku błędu
      });

      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      setState(() {
        isLoading = false; // Ukryj spinner ładowania w przypadku błędu
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred.")),
      );
    }
  }

  void navigateToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BotomAppBar(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
      (route) => false,
    );
  }

  Widget _buildShinyLogo() {
    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _shineAnimation.value,
          child: child,
        );
      },
      child: Image.asset(
        'assets/logo/logo.png',
        width: 250,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTextInput(
      TextEditingController controller, String label, bool obscureText) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: Theme.of(context).primaryColorDark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      cursorColor: Theme.of(context).primaryColorDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Column(
                  children: [
                    _buildShinyLogo(),
                    const SizedBox(height: 10),
                    Text(
                      "P u p i l a",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Fraunces',
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                if (isLoading) // Wyświetlenie spinnera ładowania
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColorDark,
                  )
                else if (!showLoginForm) ...[
                  ElevatedButton(
                    onPressed: toggleLoginForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Log in with Email',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "or",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/logo/google_icon.png',
                          width: 50,
                          height: 50,
                        ),
                        onPressed: () {
                          // Logowanie przez Google
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: Image.asset(
                          'assets/logo/apple_icon.png',
                          width: 50,
                          height: 50,
                        ),
                        onPressed: () {
                          // Logowanie przez Apple
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: navigateToRegister,
                        child: Text(
                          " Register Here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Form(
                    child: Column(
                      children: [
                        _buildTextInput(emailController, 'Email', false),
                        const SizedBox(height: 20),
                        _buildTextInput(passwordController, 'Password', true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: toggleLoginForm,
                          child: Text(
                            'Go back to selection',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
