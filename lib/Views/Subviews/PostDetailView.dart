import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Post.dart';
import 'package:spica/Structs/Post.dart';
import 'package:spica/Structs/PostDetail.dart';
import 'package:spica/Views/Cells/PostCell.dart';

class PostDetailView extends StatefulWidget {
  PostDetailView({Key key, @required this.post}) : super(key: key);

  Post post;

  @override
  _PostDetailViewState createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  PostDetail postDetail;
  final _scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
    loadPostDetail();
  }

  void loadPostDetail() async {
    MicroAPI.shared.loadPostDetail(widget.post.id).then((detail) {
      setState(() {
        detail.postAncestors.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        postDetail = detail;
        _scrollController.scrollToIndex(
            postDetail.postAncestors
                .indexWhere((element) => element.id == postDetail.mainPost.id),
            duration: Duration(seconds: 1),
            preferPosition: AutoScrollPosition.middle);
      });
    }).catchError((err) {
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.grey[100],
          child: (() {
            if (postDetail != null) {
              return RefreshIndicator(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: (() {
                            if (index <
                                postDetail.postAncestors.length -
                                    1 +
                                    postDetail.postAncestors.length) {
                              if (index % 2 == 0) {
                                int count =
                                    List<int>.generate(index, (i) => i + 1)
                                        .where((element) => element % 2 != 0)
                                        .length;

                                return AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: _scrollController,
                                    index: index - count,
                                    child: PostCell(
                                        post: postDetail
                                            .postAncestors[index - count],
                                        highlighted: postDetail
                                                .postAncestors[index - count]
                                                .id ==
                                            postDetail.mainPost.id));
                              } else {
                                return Center(
                                  child: Container(
                                      height: 50,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.grey[400],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)))),
                                );
                              }
                            } else if (index ==
                                postDetail.postAncestors.length +
                                    postDetail.postAncestors.length -
                                    1) {
                              return Center(
                                  child: GestureDetector(
                                onTap: (() {}),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 64,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Color(0xFF2d539a),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Center(
                                      child: Text("Reply",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    )),
                              ));
                            } else {
                              return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: _scrollController,
                                  index: index -
                                      (postDetail.postAncestors.length +
                                          postDetail.postAncestors.length),
                                  child: GestureDetector(
                                      onTap: (() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PostDetailView(
                                                  post: postDetail.postReplies[
                                                      index -
                                                          (postDetail
                                                                  .postAncestors
                                                                  .length +
                                                              postDetail
                                                                  .postAncestors
                                                                  .length)])),
                                        );
                                      }),
                                      child: PostCell(
                                          post: postDetail.postReplies[index -
                                              (postDetail.postAncestors.length +
                                                  postDetail.postAncestors
                                                      .length)])));
                            }
                          }()));
                    },
                    itemCount: postDetail.postAncestors.length +
                        postDetail.postAncestors.length +
                        postDetail.postReplies
                            .length /* +
                      2 +
                      postDetail.postReplies.length*/
                    ,
                  ),
                ),
                onRefresh: _getData,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }())),
    );
  }

  Future<void> _getData() async {
    setState(() {
      postDetail = null;
      loadPostDetail();
    });
  }
}
