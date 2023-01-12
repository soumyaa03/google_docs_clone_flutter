import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/view/colors.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  //flutter run -d chrome --web-hostname localhost --web-port 7357

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    } else {
      sMessenger.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
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
            minimumSize:
                user == null ? const Size(150, 50) : const Size(50, 150),
          ),
        ),
      ),
    );
  }
}
