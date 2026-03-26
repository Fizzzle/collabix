class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.description,
    required this.dayStreak,
    required this.boardsCreated,
    required this.aiAssists,
  });

  final String uid;
  final String name;
  final String email;
  final String description;
  final int dayStreak;
  final int boardsCreated;
  final int aiAssists;

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'description': description,
      'dayStreak': dayStreak,
      'boardsCreated': boardsCreated,
      'aiAssists': aiAssists,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      description: json['description'],
      dayStreak: json['dayStreak'],
      boardsCreated: json['boardsCreated'],
      aiAssists: json['aiAssists'],
    );
  }
}
