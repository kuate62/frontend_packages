class Claim {
  const Claim({
    required this.id,
    required this.reference,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    this.resolution,
  });

  final String id;
  final String reference;
  final String category;
  final String subject;
  final String description;
  final String status;
  final String? resolution;

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      reference: json['reference'] as String,
      category: json['category'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      resolution: json['resolution'] as String?,
    );
  }
}