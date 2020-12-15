import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_User.dart';
import 'package:spica/Structs/Post.dart';
import 'package:spica/Structs/User.dart';
import 'package:spica/Views/Cells/PostCell.dart';
import 'package:spica/Views/Cells/XPProgessBarView.dart';
import 'package:spica/Views/Subviews/PostDetailView.dart';

class AccountView extends StatefulWidget {
  AccountView({Key key, @required this.user}) : super(key: key);

  User user;

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  User user;
  List<Post> posts = [];

  bool dataLoaded = false;
  bool postsLoaded = false;

  String signedinUserID;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    loadSignedinUser();
  }

  void loadSignedinUser() async {
    signedinUserID = await MicroAPI.shared.loadSignedInID();
    loadAccount();
  }

  void loadAccount() async {
    await MicroAPI.shared
        .loadUser(id: user.id ?? widget.user.id, loadStatus: true)
        .then((newuser) async {
      user = newuser;
      dataLoaded = true;
      setState(() {});
      loadUserPosts();
    }).catchError((err) {
      setState(() {
        dataLoaded = true;
      });
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  void loadUserPosts() async {
    MicroAPI.shared.loadUserPosts(id: user.id).then((newuserposts) {
      setState(() {
        posts = newuserposts;
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        postsLoaded = true;
      });
    }).catchError((err) {
      setState(() {
        postsLoaded = true;
      });
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.nickname ?? "Account"),
      ),
      body: Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.grey[100],
          child: RefreshIndicator(
            child: (() {
              if (dataLoaded) {
                return ListView.builder(
                  itemCount: (postsLoaded ? posts.length + 1 : 2),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(
                            top: 60.0, left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 120,
                                height: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60.0),
                                  child: Image.network(user.profilepictureurl),
                                )),
                            Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nickname,
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${user.name}#${user.tag}",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    (() {
                                      if (user.username != null) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 2.0),
                                          child: Text("@${user.username}",
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }()),
                                    (() {
                                      if (user.isfollowingme) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 2.0),
                                          child: Text("Follows you",
                                              style: TextStyle(
                                                  color: Colors.grey[700])),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }()),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                                text: "${user.followercount} ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black)),
                                            TextSpan(
                                                text:
                                                    "Follower${user.followercount != 1 ? "s" : "s"}",
                                                style: TextStyle(
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black))
                                          ])),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      "${user.followingcount} ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black)),
                                              TextSpan(
                                                  text: "Following",
                                                  style: TextStyle(
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black))
                                            ])),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "${user.postscount} ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)),
                                        TextSpan(
                                            text:
                                                "Post${user.postscount != 1 ? "s" : ""}",
                                            style: TextStyle(
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black))
                                      ])),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "${user.repliescount} ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)),
                                        TextSpan(
                                            text:
                                                "Repl${user.repliescount != 1 ? "ies" : "y"}",
                                            style: TextStyle(
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black))
                                      ])),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Joined: ",
                                            style: TextStyle(
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)),
                                        TextSpan(
                                            text:
                                                "${DateFormat("dd. MMM yyyy").format(user.createdAt)}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)),
                                      ])),
                                    ),
                                    (() {
                                      if (user.status.content != null) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("\"${user.status.content}\"",
                                                  style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic)),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                    "${Jiffy(user.status.date).fromNow()}",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }()),
                                    Padding(
                                      padding: EdgeInsets.only(top: 16.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: XPProgressBarView(
                                            xp: user.xp,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2),
                                      ),
                                    ),
                                  ],
                                )),
                            (() {
                              if (user.id != signedinUserID) {
                                return Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: FlatButton(
                                      onPressed: (() {
                                        MicroAPI.shared
                                            .followUnfollowUser(
                                                id: user.id,
                                                action: user.iamfollowing
                                                    ? FollowUnfollow.unfollow
                                                    : FollowUnfollow.follow)
                                            .then((response) {
                                          setState(() {
                                            user.iamfollowing = response;
                                          });
                                        }).catchError((err) {
                                          Get.dialog(MicroAPI.shared
                                              .renderErrorAlertDialog(
                                                  error: err));
                                        });
                                      }),
                                      child: Container(
                                        width: 120,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: user.iamfollowing
                                                ? Colors.blue[600]
                                                : Colors.grey.withOpacity(0.25),
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        child: Center(
                                          child: Text(
                                              "${user.iamfollowing ? "Following" : "Follow"}",
                                              style: TextStyle(
                                                  color: user.iamfollowing
                                                      ? Colors.white
                                                      : Colors.blue)),
                                        ),
                                      )),
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }())
                          ],
                        ),
                      );
                    } else {
                      if (postsLoaded) {
                        return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: (() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostDetailView(
                                          post: posts[index - 1])),
                                );
                              }),
                              child: PostCell(
                                post: posts[index - 1],
                              ),
                            ));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }
                  },
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
      postsLoaded = false;
      loadAccount();
    });
  }
}
