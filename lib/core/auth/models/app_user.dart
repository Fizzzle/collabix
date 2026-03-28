class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.description,
    required this.dayStreak,
    required this.boardsCreated,
    required this.aiAssists,
    this.photoURL,
  });

  final String uid;
  final String name;
  final String email;
  final String description;
  final int dayStreak;
  final int boardsCreated;
  final int aiAssists;
  final String? photoURL;

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'description': description,
      'dayStreak': dayStreak,
      'boardsCreated': boardsCreated,
      'aiAssists': aiAssists,
      if (photoURL != null) 'photoURL': photoURL,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dayStreak: (json['dayStreak'] as num?)?.toInt() ?? 0,
      boardsCreated: (json['boardsCreated'] as num?)?.toInt() ?? 0,
      aiAssists: (json['aiAssists'] as num?)?.toInt() ?? 0,
      photoURL: json['photoURL'] as String?,
    );
  }

  factory AppUser.fromFirestoreMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dayStreak: (map['dayStreak'] as num?)?.toInt() ?? 0,
      boardsCreated: (map['boardsCreated'] as num?)?.toInt() ?? 0,
      aiAssists: (map['aiAssists'] as num?)?.toInt() ?? 0,
      photoURL: map['photoURL'] as String?,
    );
  }

  AppUser copyWith({
    String? name,
    String? description,
    String? photoURL,
    int? dayStreak,
    int? boardsCreated,
    int? aiAssists,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      description: description ?? this.description,
      photoURL: photoURL ?? this.photoURL,
      dayStreak: dayStreak ?? this.dayStreak,
      boardsCreated: boardsCreated ?? this.boardsCreated,
      aiAssists: aiAssists ?? this.aiAssists,
    );
  }
}
