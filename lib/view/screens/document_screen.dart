import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/common/widgets/custom_loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/socket_repository.dart';
import 'package:google_docs/view/colors.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreem extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreem({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreemState();
}

class _DocumentScreemState extends ConsumerState<DocumentScreem> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _quillController;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      _quillController?.compose(
        quill.Delta.fromJson(data['delta']),
        _quillController?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.REMOTE,
      );
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _quillController!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _quillController = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    _quillController!.document.changes.listen((event) {
      // 1-> entire content of the document
      //2-> changes made from the previous part
      //3-> local? -> we have typed it , remote? ->

      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          "delta": event.item2,
          "room": widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void updateDocumentTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_quillController == null) {
      return const Scaffold(
        body: CustomLoader(),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: whitecolor,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                          text:
                              'http://localhost:3000/#/document/${widget.id}'))
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Link Copied',
                        ),
                      ),
                    );
                  });
                },
                icon: const Icon(
                  Icons.lock,
                  size: 16,
                ),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(backgroundColor: bluecolor),
              ),
            ),
          ],
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Routemaster.of(context).replace('/');
                  },
                  child: Image.asset(
                    'assets/images/61447cd55953a50004ee16d9.png',
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: bluecolor)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                    onSubmitted: (value) => updateDocumentTitle(
                      ref,
                      value,
                    ),
                  ),
                )
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: greyColor,
                  width: 0.1,
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              quill.QuillToolbar.basic(controller: _quillController!),
              const SizedBox(height: 10),
              Expanded(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: whitecolor,
                    elevation: 9,
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: quill.QuillEditor.basic(
                        controller: _quillController!,
                        readOnly: false,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

//  IconButton(
//               onPressed: () => navigateToHomeScreen(context),
//               icon: const Icon(
//                 Icons.logout_outlined,
//                 color: blackcolor,
//               ),
//             ),

//  void navigateToHomeScreen(BuildContext context) {
//     final navigator = Routemaster.of(context);
//     navigator.replace('/');
//   }
