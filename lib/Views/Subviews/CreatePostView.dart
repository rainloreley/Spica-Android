import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Post.dart';
import 'package:spica/Views/Subviews/PostDetailView.dart';

class CreatePostView extends StatefulWidget {
  CreatePostView(
      {Key key,
      @required this.type,
      this.initialText,
      this.initialLink,
      this.parent})
      : super(key: key);

  PostType type;
  String initialText = "";
  String initialLink = "";
  String parent;

  @override
  _CreatePostViewState createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  TextEditingController _editingController;
  TextEditingController _linkFieldEditingController;
  double _textProgress = 0;
  bool linkFieldShown = false;
  File _selectedImage;
  String signedinUserID;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.initialText);
    _linkFieldEditingController =
        TextEditingController(text: widget.initialLink);
    getSignedinUserID();
  }

  void getSignedinUserID() async {
    final id = await MicroAPI.shared.loadSignedInID();
    setState(() {
      signedinUserID = id;
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    _linkFieldEditingController.dispose();
    super.dispose();
  }

  Future<void> selectImage() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        _selectedImage = null;
      }
    });
  }

  Future<void> sendPost(BuildContext context) async {
    MicroAPI.shared
        .sendPost(
            content: _editingController.text,
            image: _selectedImage,
            parent: widget.parent,
            url: _linkFieldEditingController.text != ""
                ? _linkFieldEditingController.text
                : null)
        .then((newpost) {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostDetailView(post: newpost)),
      );
    }).catchError((err) {
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.type == PostType.reply ? "Reply" : "Post"),
          ),
          persistentFooterButtons: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(children: [
                    Container(
                      width: 45,
                      height: 30,
                      child: FlatButton(
                          onPressed: (() {
                            setState(() {
                              linkFieldShown = !linkFieldShown;
                            });
                          }),
                          child: Icon(EvaIcons.link2Outline)),
                    ),
                    Container(
                        width: 45,
                        height: 30,
                        child: FlatButton(
                          onPressed: (() async {
                            if (_selectedImage == null) {
                              await selectImage();
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Manage image"),
                                      actions: [
                                        TextButton(
                                            onPressed: (() {
                                              Navigator.of(context).pop();
                                              selectImage();
                                            }),
                                            child: Text("Select new image")),
                                        TextButton(
                                            onPressed: (() {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                _selectedImage = null;
                                              });
                                            }),
                                            child: Text("Remove image")),
                                        TextButton(
                                            onPressed: (() {
                                              Navigator.of(context).pop();
                                            }),
                                            child: Text("Cancel"))
                                      ],
                                    );
                                  });
                            }
                          }),
                          child: Icon(_selectedImage != null
                              ? EvaIcons.image2
                              : EvaIcons.imageOutline),
                        ))
                  ])),
            )
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: (() async {
              await sendPost(context);
            }),
            child: Icon(EvaIcons.paperPlaneOutline, color: Colors.white),
            backgroundColor: Colors.blue,
          ),
          body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (() {
                    if (linkFieldShown) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 16.0,
                        ),
                        child: TextField(
                          focusNode: FocusNode(),
                          controller: _linkFieldEditingController,
                          decoration:
                              InputDecoration(hintText: "https://abmgrt.dev"),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }()),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                          "https://avatar.alles.cc/${signedinUserID ?? "_"}"))),
                              /*child: Image.network(post.author.profilepictureurl,
                                width: 50, height: 50),*/
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: CircularPercentIndicator(
                                radius: 50.0,
                                lineWidth: 6.0,
                                animation: false,
                                percent: _textProgress,
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: (() {
                                  if (_textProgress == 0) {
                                    return Colors.grey.withOpacity(0.5);
                                  } else if (_textProgress < 0.5) {
                                    return Colors.greenAccent[700];
                                  } else if (_textProgress < 0.75) {
                                    return Colors.amber;
                                  } else {
                                    return Colors.red;
                                  }
                                }()),
                                backgroundColor: Colors.grey.withOpacity(0.5),
                              ))
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              //height: MediaQuery.of(context).size.height - 200,
                              child: TextField(
                                maxLines: null,
                                maxLength: 500,
                                keyboardType: TextInputType.multiline,
                                decoration:
                                    InputDecoration(hintText: "Hi! What's up?"),
                                controller: _editingController,
                                focusNode: FocusNode(),
                                style: TextStyle(),
                                cursorColor: Colors.green,
                                onChanged: ((string) {
                                  setState(() {
                                    _textProgress = string.length / 500;
                                  });
                                }),
                              ),
                            ),
                            (() {
                              if (_selectedImage != null) {
                                return Padding(
                                  padding:
                                      EdgeInsets.only(top: 32.0, bottom: 16.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    child: Image.file(_selectedImage),
                                  ),
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }())
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ))),
    );
  }
}

enum PostType { post, reply }
