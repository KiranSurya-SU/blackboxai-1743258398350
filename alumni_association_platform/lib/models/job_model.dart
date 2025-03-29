class JobModel {
  final String id;
  final String title;
  final String company;
  final String description;
  final List<String> requirements;
  final String postedBy;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.requirements,
    required this.postedBy,
    required this.createdAt,
  });

  factory JobModel.fromFirestore(Map<String, dynamic> data, String id) {
    return JobModel(
      id: id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      description: data['description'] ?? '',
      requirements: List<String>.from(data['requirements'] ?? []),
      postedBy: data['postedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'company': company,
      'description': description,
      'requirements': requirements,
      'postedBy': postedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}