import 'package:spica/Structs/Post.dart';

class PostDetail {
  List<Post> postAncestors;
  Post mainPost;
  List<Post> postReplies;

  PostDetail({this.postAncestors, this.mainPost, this.postReplies});
}
