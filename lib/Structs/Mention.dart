import 'package:spica/Structs/Post.dart';

class Mention {
  bool read;
  Post post;

  Mention({this.post, this.read});
}
