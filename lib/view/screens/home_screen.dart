import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/common/widgets/custom_loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/view/colors.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    //no need of navigating as state returns null , so from main.dart we are automatically pushed to login screen
    //in main.dart , the state is watched by ref.watch() for state changes
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    final user = ref.read(userProvider);
    log(user!.token.toString());

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    final navigator = Routemaster.of(context);
    navigator.push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => createDocument(context, ref),
              icon: const Icon(
                Icons.add,
                color: blackcolor,
              ),
            ),
            IconButton(
              onPressed: () => signOut(ref),
              icon: const Icon(
                Icons.logout_outlined,
                color: blackcolor,
              ),
            ),
          ],
        ),
        body: FutureBuilder<ErrorModel>(
          future: ref.watch(documentRepositoryProvider).getDocuments(
                ref.watch(userProvider)!.token,
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomLoader();
            } else {
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 600,
                  child: ListView.builder(
                    itemCount: snapshot.data!.data.length,
                    itemBuilder: (context, index) {
                      DocumentModel documentModel = snapshot.data!.data[index];

                      return InkWell(
                        onTap: () =>
                            navigateToDocument(context, documentModel.id),
                        child: SizedBox(
                          height: 50,
                          child: Card(
                            color: Colors.blue,
                            child: Center(
                              child: Text(
                                documentModel.title,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        ));
  }
}
