import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Feed.dart';
import 'package:spica/Structs/Post.dart';
import 'package:spica/Views/Cells/PostCell.dart';
import 'package:spica/Views/Subviews/CreatePostView.dart';
import 'package:spica/Views/Subviews/PostDetailView.dart';

class FeedView extends StatefulWidget {
  FeedView({Key key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  List<Post> postIds = [];
  bool dataLoaded = false;

  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadFeed();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0 &&
          dataLoaded == true &&
          postIds.length != 0) {
        loadMoreFeed();
      }
    });
  }

  void loadFeed() async {
    MicroAPI.shared
        .loadFeed()
        .then((feed) => {
              setState(() {
                postIds = feed;
                postIds = postIds.toSet().toList();
                dataLoaded = true;
              })
            })
        .catchError((err) {
      setState(() {
        dataLoaded = true;
      });
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  void loadMoreFeed() async {
    MicroAPI.shared
        .loadFeed(before: postIds.last.createdAt.millisecondsSinceEpoch)
        .then((feed) {
      //postIds.addAll(feed);
      List<Post> unique = [];
      List<Post> newArray = [];
      newArray.addAll(postIds);
      newArray.addAll(feed);
      setState(() {
        for (var post in newArray) {
          var index = unique.firstWhere((element) => element.id == post.id,
              orElse: () => null);
          if (index == null) {
            unique.add(post);
          } else {}
        }
        postIds = unique;
        postIds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    }).catchError((err) {
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          showCupertinoModalBottomSheet(
              context: context,
              builder: (context) {
                return CreatePostView(type: PostType.post);
              });
        }),
        child: Icon(EvaIcons.edit, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.grey[100],
          child: RefreshIndicator(
            child: (() {
              if (dataLoaded) {
                return ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailView(post: postIds[index])),
                            );
                          }),
                          child: PostCell(
                            post: postIds[index],
                          ),
                        ));
                  },
                  itemCount: postIds.length,
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
      postIds = [];
      loadFeed();
    });
  }
}
