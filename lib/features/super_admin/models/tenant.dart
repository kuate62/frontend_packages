class Tenant {
  const Tenant({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.status,
  });

  final String id;
  final String name;
  final String? code;
  final String? city;
  final String? status;

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      city: json['city'] as String?,
      status: json['status'] as String?,
    );
  }
}