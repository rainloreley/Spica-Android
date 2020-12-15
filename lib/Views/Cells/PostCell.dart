import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Post.dart';
import 'package:spica/Structs/Post.dart';
import 'package:spica/Structs/User.dart';
import 'package:spica/Views/Main/AccountView.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCell extends StatefulWidget {
  PostCell({Key key, @required this.post, this.highlighted: false})
      : super(key: key);

  Post post;
  bool highlighted = false;

  @override
  _PostCellState createState() => _PostCellState();
}

class _PostCellState extends State<PostCell> {
  Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    loadPost();
  }

  void loadPost() async {
    MicroAPI.shared
        .loadPost(widget.post.id, loadRickroll: true)
        .then((newPost) => {
              setState(() {
                post = newPost;
              })
            })
        .catchError((err) {
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            border: widget.highlighted
                ? Border.all(color: Colors.yellow, width: 1)
                : Border(),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Container(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                child: (() {
                  if (post != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AccountView(user: post.author)),
                                    );
                                  }),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(post
                                                .author.profilepictureurl))),
                                    /*child: Image.network(post.author.profilepictureurl,
                                width: 50, height: 50),*/
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                        "${post.author.nickname ?? post.author.name}${post.author.plus ? "\u207A" : ""}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0)))
                              ],
                            )),
                        (() {
                          if (post.content != null) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: RichText(
                                text: TextSpan(
                                    children: (() {
                                  var splittedContent = post.content
                                      .replaceAll("\n", "\n ")
                                      .split(" ");
                                  List<TextSpan> wordTextSpans = [];
                                  for (var word in splittedContent) {
                                    var filteredWordForMentions =
                                        word.replaceAll(
                                            new RegExp(
                                                r'([^(A-Z)(a-z)\@\-(0-9)])+'),
                                            '');
                                    var filteredWordForURLs = word.replaceAll(
                                        word.replaceAll(
                                            new RegExp(
                                                r'(([(A-Z)(a-z)\@\-(0-9)\=\_\&\?\/\:\%])(\.*))+'),
                                            ''),
                                        '');

                                    if (filteredWordForMentions
                                        .startsWith("@")) {
                                      wordTextSpans.addAll(analyzeText(
                                          filteredWord: filteredWordForMentions,
                                          word: word,
                                          type: AnalyzeType.mention,
                                          function: (() {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => AccountView(
                                                      user: User(
                                                          id: filteredWordForMentions
                                                              .replaceAll(
                                                                  "@", "")))),
                                            );
                                          })));
                                    } else if (isURL(filteredWordForURLs)) {
                                      wordTextSpans.addAll(analyzeText(
                                          filteredWord: filteredWordForURLs,
                                          word: word,
                                          type: AnalyzeType.url,
                                          function: (() async {
                                            if (await canLaunch(
                                                filteredWordForURLs)) {
                                              await launch(filteredWordForURLs);
                                            }
                                          })));
                                    } else {
                                      wordTextSpans.addAll(analyzeText(
                                        filteredWord: word,
                                        word: word,
                                      ));
                                    }
                                  }
                                  return wordTextSpans;
                                }())),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        (() {
                          if (post.imageurl != null) {
                            return ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(post.imageurl));
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        (() {
                          if (post.url != null) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: GestureDetector(
                                onTap: (() async {
                                  if (await canLaunch(post.url)) {
                                    await launch(post.url);
                                  }
                                }),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.0, right: 8.0),
                                        child: Text(post.url,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16.0)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        (() {
                          if (post.containsRickroll && post.url != null) {
                            bool isJamRoll =
                                (post.url.contains("youtube.com") ||
                                        post.url.contains("youtu.be")) &&
                                    post.url.contains("Gc2u6AFImn8");
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: 16.0,
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    isJamRoll
                                        ? EvaIcons.musicOutline
                                        : EvaIcons.alertTriangleOutline,
                                    color: Colors.grey,
                                    size: 15,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Text(
                                        "This link might contain a ${isJamRoll ? "jamroll" : "rickroll"}",
                                        style: TextStyle(color: Colors.grey)),
                                  )
                                ],
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 50,
                              height: 23,
                              child: FlatButton(
                                  onPressed: (() {
                                    votePost(VoteType.upvote);
                                  }),
                                  child: Text("+",
                                      style: TextStyle(
                                          fontSize: 25.0,
                                          color: post.vote == 1
                                              ? Colors.green
                                              : post.vote == -1
                                                  ? Colors.grey
                                                  : Colors.blue))),
                            ),
                            Container(
                              child: Text(post.score.toString()),
                            ),
                            Container(
                              width: 50,
                              height: 28,
                              child: FlatButton(
                                  onPressed: (() {
                                    votePost(VoteType.downvote);
                                  }),
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                        fontSize: 35.0,
                                        color: post.vote == -1
                                            ? Colors.red
                                            : post.vote == 1
                                                ? Colors.grey
                                                : Colors.blue),
                                  )),
                            ),
                            Spacer(),
                            (() {
                              if (post.interactions != null) {
                                return Row(
                                  children: [
                                    Text(post.interactions.toString(),
                                        style: TextStyle(color: Colors.grey)),
                                    Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Icon(EvaIcons.eyeOutline,
                                            color: Colors.grey, size: 18))
                                  ],
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }()),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(post.children.length.toString(),
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(EvaIcons.messageCircleOutline,
                                    color: Colors.grey, size: 18)),
                            Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(Jiffy(post.createdAt).fromNow(),
                                    style: TextStyle(color: Colors.grey)))
                          ],
                        )
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }()),
              )),
        ));
  }

  List<TextSpan> analyzeText(
      {String filteredWord, String word, AnalyzeType type, Function function}) {
    if (((type == AnalyzeType.mention && filteredWord.startsWith("@")) ||
            (type == AnalyzeType.url && isURL(filteredWord))) &&
        word.contains(filteredWord)) {
      List<TextSpan> wordTextSpans = [];
      if (word.indexOf(filteredWord) != -1 &&
          word.substring(0, word.indexOf(filteredWord)) != "") {
        wordTextSpans.add(TextSpan(
            text: word.substring(0, word.indexOf(filteredWord)),
            style: TextStyle(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)));
      }
      wordTextSpans.add(TextSpan(
          text: filteredWord,
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()..onTap = function));
      if (word.substring(
              word.indexOf(filteredWord) + filteredWord.length, word.length) !=
          "") {
        wordTextSpans.add(TextSpan(
            text: word.substring(
                word.indexOf(filteredWord) + filteredWord.length, word.length),
            style: TextStyle(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)));
      }
      wordTextSpans.add(TextSpan(text: " "));
      return wordTextSpans;
    } else {
      if (word == "\n") {
        return [
          TextSpan(
              text: "\n",
              style: TextStyle(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black))
        ];
      } else {
        return [
          TextSpan(
              text: "$word ",
              style: TextStyle(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black))
        ];
      }
    }
  }

  void votePost(VoteType type) {
    MicroAPI.shared.votePost(post, type).then((newvotestatus) {
      setState(() {
        post.score = newvotestatus.score;
        post.vote = newvotestatus.vote;
      });
    }).catchError((err) {
      Get.dialog(MicroAPI.shared.renderErrorAlertDialog(error: err));
    });
  }
}

enum AnalyzeType { mention, url }
