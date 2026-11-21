class Company {
  const Company({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.address,
    this.phone,
    this.email,
    this.status,
    this.agencyCount = 0,
  });

  final String id;
  final String name;
  final String? code;
  final String? city;
  final String? address;
  final String? phone;
  final String? email;
  final String? status;
  final int agencyCount;

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String?,
      agencyCount: json['agencyCount'] as int? ?? 0,
    );
  }
}

class Agency {
  const Agency({
    required this.id,
    this.tenantId,
    this.tenantName,
    this.code,
    required this.name,
    this.city,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.status,
  });

  final String id;
  final String? tenantId;
  final String? tenantName;
  final String? code;
  final String name;
  final String? city;
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? status;

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      tenantName: json['tenantName'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );
  }
}