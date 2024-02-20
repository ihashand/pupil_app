import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/my_textfield.dart';
import 'package:pet_diary/src/components/signin_button.dart';
import '../helper/helper_functions.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // text controlers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameControlerr = TextEditingController();

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
            // logo
            Icon(Icons.pets_outlined,
                size: 80, color: Theme.of(context).colorScheme.inversePrimary),

            const SizedBox(
              height: 25,
            ),

            // app name
            const Text(
              "P U P I L   A P P",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(
              height: 25,
            ),

            // username textfield
            MyTextField(
                hintText: "Username",
                obscureText: false,
                controller: userNameControlerr),

            const SizedBox(
              height: 10,
            ),

            // email textfield
            MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController),

            const SizedBox(
              height: 10,
            ),

            // password textfield
            MyTextField(
                hintText: "Password",
                obscureText: true,
                controller: passwordController),

            const SizedBox(
              height: 10,
            ),

            // password textfield
            MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmPasswordController),

            const SizedBox(
              height: 10,
            ),

            // forgot password
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

            // register button
            SignInButton(
              text: "Register",
              onTap: registerUser,
            ),

            const SizedBox(
              height: 7,
            ),

            // dont have an account register here
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
      )),
    );
  }

  // Log to the app method
  void registerUser() async {
    // Show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    // Make sure password match
    if (passwordController.text != confirmPasswordController.text) {
      // Pop loading circle
      Navigator.pop(context);

      // Show error to the user
      displayMessageToUser("Password don't match!", context);
    }

    // Until password doesn't match w're not creating acc
    else {
      try {
        // Create user
        // ignore: unused_local_variable
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        // Pop loadin circle
        if (context.mounted) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        // Pop loading circle
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Display error message to user
        if (context.mounted) {
          displayMessageToUser(e.code, context);
        }
      }
    }
  }
}
