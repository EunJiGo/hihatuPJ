enum ApplyKind { commute, single, remote, other }

extension ApplyKindLabel on ApplyKind {
  String get label => switch (this) {
    ApplyKind.commute => '定期券申請',
    ApplyKind.single  => '交通費申請',
    ApplyKind.remote  => '在宅勤務手当申請',
    ApplyKind.other   => '立替金申請',
  };
}