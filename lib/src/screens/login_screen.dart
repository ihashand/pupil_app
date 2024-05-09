// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pet_diary/src/components/my_textfield.dart';
import 'package:pet_diary/src/components/signin_button.dart';
import 'package:pet_diary/src/helper/helper_functions.dart';
import 'package:pet_diary/src/models/local_user_model.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;

  const LoginScreen({super.key, this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_outlined,
                size: 80, color: Theme.of(context).colorScheme.inversePrimary),
            const SizedBox(
              height: 25,
            ),
            const Text(
              "P U P I L   A P P",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 25,
            ),
            MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController),
            const SizedBox(
              height: 10,
            ),
            MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("Forgot password?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            SignInButton(
              text: "Login",
              onTap: login,
            ),
            const SizedBox(
              height: 7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an accouint?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary)),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    " Register Here",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
