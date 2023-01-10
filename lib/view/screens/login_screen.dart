import 'package:flutter/material.dart';
import 'package:google_docs/view/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Image.asset(
            'assets/images/google-logo-9808.png',
            height: 20,
          ),
          label: const Text(
            'Sign-in with Google',
            style: TextStyle(
              color: blackcolor,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: whitecolor,
            minimumSize: const Size(150, 50),
          ),
        ),
      ),
    );
  }
}
