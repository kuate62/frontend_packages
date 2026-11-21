class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    this.type,
    this.capacityKg,
    this.capacityUnit,
    this.status = 'ACTIVE',
    this.description,
  });

  final String id;
  final String plate;
  final String? type;
  final double? capacityKg;
  final String? capacityUnit;
  final String status;
  final String? description;

  bool get isActive => status == 'ACTIVE';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      plate: json['plate'] as String,
      type: json['type'] as String?,
      capacityKg: (json['capacityKg'] as num?)?.toDouble(),
      capacityUnit: json['capacityUnit'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      description: json['description'] as String?,
    );
  }
}