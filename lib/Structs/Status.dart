class Status {
  String id;
  String content;
  DateTime date;
  DateTime end;

  Status({this.id, this.content, this.date, this.end});

  factory Status.fromJson(Map<String, dynamic> json) {
    if (json["status"] == null) {
      return Status(id: null, content: null, date: null, end: null);
    } else {
      return Status(
          id: (json["status"] ?? {})["id"] ?? "",
          content: (json["status"] ?? {})["content"] ?? "",
          date: (json["status"] ?? {})["date"] != null
              ? DateTime.parse((json["status"] ?? {})["date"])
              : DateTime.now(),
          end: (json["status"] ?? {})["end"] != null
              ? DateTime.parse((json["status"] ?? {})["end"])
              : DateTime.now());
    }
  }
}
