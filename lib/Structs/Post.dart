import 'package:spica/Structs/User.dart';

class Post {
  String id;
  User author;
  String parent;
  List<String> children;
  String content;
  String imageurl;
  String url;
  int score;
  int vote;
  int interactions;
  DateTime createdAt;
  List<User> mentionedUsers;
  bool isDeleted;
  bool containsRickroll;

  Post(
      {this.id,
      this.author,
      this.parent,
      this.children,
      this.content,
      this.imageurl,
      this.url,
      this.score,
      this.vote,
      this.interactions,
      this.createdAt,
      this.mentionedUsers,
      this.isDeleted,
      this.containsRickroll});

  static var sample = Post(
      id: "lol",
      author: User.sample,
      parent: null,
      children: [],
      content: "Hello",
      imageurl: null,
      url: null,
      score: 69,
      vote: 1,
      interactions: 22,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      mentionedUsers: [],
      isDeleted: false,
      containsRickroll: false);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json["id"],
        author: User.fromJson(json["author"]),
        parent: json["parent"] ?? null,
        children: List.from(json["children"][
            "list"]) /*(json["children"]["list"] as List).map((i) {
          return i;
        })..toList()*/
        ,
        content: json["content"] ?? "",
        imageurl: json["image"] != null
            ? "https://walnut1.alles.cc/${json["image"]}"
            : null,
        url: json["url"] ?? null,
        score: json["vote"]["score"] ?? 0,
        vote: json["vote"]["me"] ?? 0,
        interactions: json["interactions"] ?? null,
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
        mentionedUsers: [],
        isDeleted: false,
        containsRickroll: false);
  }
}
