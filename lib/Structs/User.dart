import 'package:spica/Structs/Status.dart';
import 'package:spica/Structs/XP.dart';

class User {
  String id;
  String name;
  String tag;
  bool plus;
  String nickname;
  String username;
  String profilepictureurl;
  DateTime createdAt;
  XP xp;

  int followercount;
  bool iamfollowing;

  int followingcount;
  bool isfollowingme;

  int postscount;
  int repliescount;
  Status status;

  User(
      {this.id,
      this.name,
      this.tag,
      this.plus,
      this.nickname,
      this.username,
      this.profilepictureurl,
      this.createdAt,
      this.xp,
      this.followercount,
      this.iamfollowing,
      this.followingcount,
      this.isfollowingme,
      this.postscount,
      this.repliescount,
      this.status});

  static var sample = User(
      id: "87cd0529-f41b-4075-a002-059bf2311ce7",
      name: "Lea",
      tag: "0001",
      plus: true,
      nickname: "Lea",
      username: "lea",
      profilepictureurl:
          "https://avatar.alles.cc/87cd0529-f41b-4075-a002-059bf2311ce7",
      createdAt: DateTime.now(),
      xp: XP(
          total: 2190, level: 2, levelXP: 90, levelXPMax: 1200, progress: 0.25),
      followercount: 420,
      iamfollowing: true,
      followingcount: 69,
      isfollowingme: true,
      postscount: 11,
      repliescount: 394,
      status: Status(
          id: "000",
          content: "hey",
          date: DateTime.now().subtract(Duration(hours: 2))));

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      tag: json["tag"] ?? "0000",
      plus: json["plus"] ?? false,
      nickname: json["nickname"] ?? json["name"] ?? "",
      username: json["username"] ?? null,
      profilepictureurl: "https://avatar.alles.cc/${json["id"] ?? "_"}",
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      xp: XP.fromJson(json["xp"] ?? {}),
      followercount: (json["followers"] ?? {})["count"] ?? 0,
      iamfollowing: (json["followers"] ?? {})["me"] ?? false,
      followingcount: (json["following"] ?? {})["count"] ?? 0,
      isfollowingme: (json["following"] ?? {})["me"] ?? false,
      postscount: (json["posts"] ?? {})["count"] ?? 0,
      repliescount: (json["posts"] ?? {})["replies"] ?? 0,
      status: Status(),
    );
  }
}
