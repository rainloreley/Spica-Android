class XP {
  int total;
  int level;
  int levelXP;
  int levelXPMax;
  double progress;

  XP({this.total, this.level, this.levelXP, this.levelXPMax, this.progress});

  factory XP.fromJson(Map<String, dynamic> json) {
    return XP(
        total: json["total"] ?? 0,
        level: json["level"] ?? 0,
        levelXP: json["levelXp"] ?? 0,
        levelXPMax: json["levelXpMax"] ?? 0,
        progress: json["levelProgress"] ?? 0);
  }
}
