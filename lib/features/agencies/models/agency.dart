class Agency {
  const Agency({
    required this.id,
    this.tenantId,
    required this.code,
    required this.name,
    this.city,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.status = 'ACTIVE',
  });

  final String id;
  final String? tenantId;
  final String code;
  final String name;
  final String? city;
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String status;

  bool get isActive => status == 'ACTIVE';

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      code: json['code'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}