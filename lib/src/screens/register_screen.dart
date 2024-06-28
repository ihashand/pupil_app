import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/my_textfield.dart';
import 'package:pet_diary/src/components/signin_button.dart';
import '../helper/helper_functions.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, this.onTap});

  @override
  createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser("Passwords don't match!", context);
      }
      return;
    }

    final userName = userNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final userCollection = FirebaseFirestore.instance.collection('users');

      if (kDebugMode) {
        print("Checking if username exists...");
      }
      final usernameQuery =
          await userCollection.where('username', isEqualTo: userName).get();

      if (usernameQuery.docs.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context);
          displayMessageToUser("Username already exists!", context);
        }
        return;
      }

      if (kDebugMode) {
        print("Checking if email exists...");
      }
      final emailQuery =
          await userCollection.where('email', isEqualTo: email).get();

      if (emailQuery.docs.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context);
          displayMessageToUser("Email already exists!", context);
        }
        return;
      }

      if (kDebugMode) {
        print("Creating user...");
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateProfile(displayName: userName);

      if (kDebugMode) {
        print("Saving user to Firestore...");
      }
      await userCollection.doc(userCredential.user!.uid).set({
        'username': userName,
        'email': email,
        'uid': userCredential.user!.uid,
      });

      if (mounted) {
        Navigator.pop(context); // Zamknij dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser(e.message ?? e.code, context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser(e.toString(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(height: 25),
              const Text(
                "P U P I L   A P P",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 25),
              MyTextField(
                  hintText: "Username",
                  obscureText: false,
                  controller: userNameController),
              const SizedBox(height: 10),
              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController),
              const SizedBox(height: 10),
              MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController),
              const SizedBox(height: 10),
              MyTextField(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPasswordController),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Forgot password?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
              const SizedBox(height: 25),
              SignInButton(
                text: "Register",
                onTap: registerUser,
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Login Here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
