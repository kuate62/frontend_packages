class AgencySummary {
  const AgencySummary({this.name, this.city});

  final String? name;
  final String? city;

  factory AgencySummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AgencySummary();
    return AgencySummary(
      name: json['name'] as String?,
      city: json['city'] as String?,
    );
  }
}

class MyParcel {
  const MyParcel({
    required this.id,
    required this.trackingCode,
    required this.status,
    required this.statusLabel,
    this.description,
    this.weightKg,
    this.departureAgency,
    this.arrivalAgency,
    this.createdAt,
    this.updatedAt,
    this.isSender = false,
    this.isRecipient = false,
  });

  final String id;
  final String trackingCode;
  final String status;
  final String statusLabel;
  final String? description;
  final double? weightKg;
  final AgencySummary? departureAgency;
  final AgencySummary? arrivalAgency;
  final String? createdAt;
  final String? updatedAt;
  final bool isSender;
  final bool isRecipient;

  factory MyParcel.fromJson(Map<String, dynamic> json) {
    return MyParcel(
      id: json['id'] as String,
      trackingCode: json['trackingCode'] as String,
      status: json['status'] as String,
      statusLabel: json['statusLabel'] as String? ?? json['status'] as String,
      description: json['description'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      departureAgency: AgencySummary.fromJson(json['departureAgency'] as Map<String, dynamic>?),
      arrivalAgency: AgencySummary.fromJson(json['arrivalAgency'] as Map<String, dynamic>?),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isSender: json['isSender'] as bool? ?? false,
      isRecipient: json['isRecipient'] as bool? ?? false,
    );
  }
}