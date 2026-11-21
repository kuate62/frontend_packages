class Trip {
  const Trip({
    required this.id,
    this.departureAgency,
    this.arrivalAgency,
    this.vehiclePlate,
    this.driverName,
    this.plannedDepartureAt,
    this.plannedArrivalAt,
    this.status = 'PLANNED',
  });

  final String id;
  final String? departureAgency;
  final String? arrivalAgency;
  final String? vehiclePlate;
  final String? driverName;
  final String? plannedDepartureAt;
  final String? plannedArrivalAt;
  final String status;

  factory Trip.fromJson(Map<String, dynamic> json) {
    final departure = json['departureAgency'] as Map<String, dynamic>?;
    final arrival = json['arrivalAgency'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final driver = json['driver'] as Map<String, dynamic>?;
    return Trip(
      id: json['id'] as String,
      departureAgency: departure?['name'] as String? ?? departure?['city'] as String?,
      arrivalAgency: arrival?['name'] as String? ?? arrival?['city'] as String?,
      vehiclePlate: vehicle?['plate'] as String?,
      driverName: driver == null ? null : '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim(),
      plannedDepartureAt: json['plannedDepartureAt'] as String?,
      plannedArrivalAt: json['plannedArrivalAt'] as String?,
      status: json['status'] as String? ?? 'PLANNED',
    );
  }
}