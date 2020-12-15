import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Mentions.dart';
import 'package:spica/Structs/Mention.dart';
import 'package:spica/Views/Cells/PostCell.dart';
import 'package:spica/Views/Subviews/PostDetailView.dart';

class MentionsView extends StatefulWidget {
  MentionsView({Key key}) : super(key: key);

  @override
  _MentionsViewState createState() => _MentionsViewState();
}

class _MentionsViewState extends State<MentionsView> {
  List<Mention> mentions = [];
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    loadMentions();
  }

  void loadMentions() async {
    MicroAPI.shared.loadMentions().then((loadedMentions) {
      setState(() {
        mentions = loadedMentions;
        dataLoaded = true;
      });
      markAsRead();
    }).catchError((err) {
      setState(() {
        dataLoaded = true;
      });
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  void markAsRead() async {
    await MicroAPI.shared.markMentionsAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mentions"),
      ),
      body: Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.grey[100],
          child: RefreshIndicator(
            child: (() {
              if (dataLoaded) {
                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PostDetailView(
                                      post: mentions[index].post)),
                            );
                          }),
                          child: Stack(
                            children: [
                              PostCell(
                                post: mentions[index].post,
                              ),
                              (() {
                                if (!mentions[index].read) {
                                  return Row(children: [
                                    Spacer(),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 8.0, right: 8.0),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                      ),
                                    )
                                  ]);
                                } else {
                                  return SizedBox.shrink();
                                }
                              }())
                            ],
                          ),
                        ));
                  },
                  itemCount: mentions.length,
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }()),
            onRefresh: _getData,
          )),
    );
  }

  Future<void> _getData() async {
    setState(() {
      dataLoaded = false;
      mentions = [];
      loadMentions();
    });
  }
}
