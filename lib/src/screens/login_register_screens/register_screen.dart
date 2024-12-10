import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final double startScale = 1.0;
  final double endScale = 1.1;
  final Duration shineDuration = const Duration(seconds: 3);

  bool showRegistrationForm = false;

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
    _controller.dispose(); // Usunięcie animacji
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void toggleRegistrationForm() {
    setState(() {
      showRegistrationForm = !showRegistrationForm;
    });
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
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
      ),
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
                const SizedBox(height: 100),
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
                if (!showRegistrationForm) ...[
                  ElevatedButton(
                    onPressed: toggleRegistrationForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign up with Email',
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
                          // Rejestracja przez Google
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
                          // Rejestracja przez Apple
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: Text(
                          " Log in Here",
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
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextInput(emailController, 'Email', false),
                        const SizedBox(height: 20),
                        _buildTextInput(passwordController, 'Password', true),
                        const SizedBox(height: 20),
                        _buildTextInput(confirmPasswordController,
                            'Confirm Password', true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Akcja rejestracji
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: toggleRegistrationForm,
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
