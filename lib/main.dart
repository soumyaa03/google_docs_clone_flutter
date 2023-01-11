import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/view/screens/home_screen.dart';
import 'package:google_docs/view/screens/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();
    log("atleast got to getUserData");
    if (errorModel == null) {
      log("error model is only null");
    }
    log(errorModel!.error.toString());
    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    } else {
      log("could not get user data ");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      log("cause of error : user empty");
    } else {
      log("user not null ,  but some other error");
    }
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
