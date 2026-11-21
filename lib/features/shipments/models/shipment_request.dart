class ShipmentRequest {
  const ShipmentRequest({
    required this.id,
    required this.userId,
    required this.tenantId,
    this.tenantName,
    required this.pickupCity,
    required this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.deliveryCity,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.senderFirstName,
    this.senderLastName,
    this.senderPhone,
    required this.recipientFirstName,
    required this.recipientLastName,
    required this.recipientPhone,
    required this.description,
    required this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.declaredValue,
    this.fragile = false,
    this.instructions,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String tenantId;
  final String? tenantName;
  final String pickupCity;
  final String pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String deliveryCity;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderPhone;
  final String recipientFirstName;
  final String recipientLastName;
  final String recipientPhone;
  final String description;
  final double weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? declaredValue;
  final bool fragile;
  final String? instructions;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  factory ShipmentRequest.fromJson(Map<String, dynamic> json) {
    return ShipmentRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tenantId: json['tenantId'] as String,
      tenantName: json['tenantName'] as String?,
      pickupCity: json['pickupCity'] as String,
      pickupAddress: json['pickupAddress'] as String,
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble(),
      deliveryCity: json['deliveryCity'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      senderFirstName: json['senderFirstName'] as String?,
      senderLastName: json['senderLastName'] as String?,
      senderPhone: json['senderPhone'] as String?,
      recipientFirstName: json['recipientFirstName'] as String,
      recipientLastName: json['recipientLastName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      description: json['description'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      lengthCm: (json['lengthCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      declaredValue: (json['declaredValue'] as num?)?.toDouble(),
      fragile: json['fragile'] as bool? ?? false,
      instructions: json['instructions'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}