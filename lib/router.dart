import 'package:flutter/material.dart';
import 'package:google_docs/view/screens/document_screen.dart';
import 'package:google_docs/view/screens/home_screen.dart';
import 'package:google_docs/view/screens/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) => MaterialPage(
        child: DocumentScreem(
          id: route.pathParameters['id'] ?? '',
        ),
      ),
});
