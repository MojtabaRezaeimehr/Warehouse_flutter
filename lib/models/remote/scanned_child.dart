import 'dart:convert';

class ScannedChild {
  final String uid;
  final int levelId;
  final bool hasChildren;
  ScannedChild({
    required this.uid,
    required this.levelId,
    required this.hasChildren,
  });

  ScannedChild copyWith({
    String? uid,
    int? levelId,
    bool? hasChildren,
  }) {
    return ScannedChild(
      uid: uid ?? this.uid,
      levelId: levelId ?? this.levelId,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uid,
      'LevelId': levelId,
      'hasChildren': hasChildren,
    };
  }

  factory ScannedChild.fromMap(Map<String, dynamic> map) {
    return ScannedChild(
      uid: map['uuid'] as String,
      levelId: map['LevelId'] as int,
      hasChildren: (map['hasChildren'] as String) == "true" ,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScannedChild.fromJson(String source) => ScannedChild.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ScannedChild(uid: $uid, levelId: $levelId, hasChildren: $hasChildren)';

  @override
  bool operator ==(covariant ScannedChild other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.levelId == levelId &&
      other.hasChildren == hasChildren;
  }

  @override
  int get hashCode => uid.hashCode ^ levelId.hashCode ^ hasChildren.hashCode;
}
