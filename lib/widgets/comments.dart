import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rentalz_flutter/services/auth.dart';
import 'package:rentalz_flutter/services/db.dart';

class Comments extends StatefulWidget {
  final ownerId;
  final propertyId;

  const Comments({
    Key? key,
    required this.ownerId,
    required this.propertyId,
  }) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  DatabaseService db = DatabaseService();
  AuthService auth = AuthService();

  var userId;

  final _formCommentKey = GlobalKey<FormBuilderState>();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = auth.getUser?.uid;
  }

  _handleAddComment() async {
    _formCommentKey.currentState!.save();
    final commentData = _formCommentKey.currentState?.value;

    var newComment =
        await db.setNewComment(commentData, widget.ownerId, widget.propertyId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Posting comment'),
          duration: Duration(microseconds: 50)),
    );

    setState(() {
      _commentController.clear();
    });

    return newComment?.id;
  }

  Widget addComment(String? userId) {
    return FormBuilder(
        key: _formCommentKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FormBuilderTextField(
                controller: _commentController,
                name: 'content',
                decoration: InputDecoration(
                  hintText: "What do you think about this property?",
                  labelText: "Add new comment",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (_formCommentKey.currentState!.validate()) {
                          _handleAddComment();
                        }
                      },
                      icon: const Icon(Icons.add_comment_outlined)),
                  //
                ),
                validator: (value) {
                  if ((value == null) || (value == "")) {
                    return "Please enter something before post it!";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.multiline,
              ),
              Visibility(
                visible: false,
                maintainState: true,
                child: FormBuilderTextField(
                  initialValue: userId,
                  name: 'createdBy',
                  decoration: InputDecoration(
                    hintText: "creadtedBy",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _handleAddComment();
                        },
                        icon: const Icon(Icons.add_comment_outlined)),
                    //
                  ),
                ),
              ),
              Visibility(
                visible: false,
                maintainState: true,
                child: FormBuilderDateTimePicker(
                  initialValue: DateTime.now(),
                  name: 'createdAt',
                  decoration: InputDecoration(
                    hintText: "creadtedAt",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _handleAddComment();
                        },
                        icon: const Icon(Icons.data_saver_on_outlined)),
                    //
                  ),
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          children: const [
            Icon(Icons.question_answer_outlined),
            SizedBox(width: 4),
            Text(
              "Comments",
              style: (TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      FutureBuilder(
          future: db.getComments(widget.propertyId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else {
              var comments = snapshot.data;
              return Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (BuildContext context, int index) {
                        var userId = comments[index]['createdBy'];
                        return Container(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4.0))),
                                  child: FutureBuilder(
                                      future: db.getUserDataFromId(userId),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          var userData = snapshot.data;
                                          return Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundImage: NetworkImage(
                                                    userData['photoURL']),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userData['displayName'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    width: 250,
                                                    child: Text(comments[index]
                                                        ['content']),
                                                  )
                                                ],
                                              )
                                            ],
                                          );
                                        } else {
                                          return const CircularProgressIndicator
                                              .adaptive();
                                        }
                                      }),
                                ),
                              ],
                            ));
                      }));
            }
          }),
      userId != null
          ? addComment(userId)
          : Container(
              padding: EdgeInsets.all(16),
              child: Text(
                "Login to add comment",
                style: TextStyle(
                    color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            )
    ]));
  }
}
