class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'alumni' or 'student'
  final String? graduationYear;
  final String? company;
  final String? bio;
  final List<String>? skills;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.graduationYear,
    this.company,
    this.bio,
    this.skills,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'alumni',
      graduationYear: data['graduationYear'],
      company: data['company'],
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      if (graduationYear != null) 'graduationYear': graduationYear,
      if (company != null) 'company': company,
      if (bio != null) 'bio': bio,
      if (skills != null) 'skills': skills,
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? company,
    String? graduationYear,
    List<String>? skills,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role,
      bio: bio ?? this.bio,
      company: company ?? this.company,
      graduationYear: graduationYear ?? this.graduationYear,
      skills: skills ?? this.skills,
    );
  }
}