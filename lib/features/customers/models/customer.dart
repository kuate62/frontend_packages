class Customer {
  const Customer({
    required this.id,
    this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.city,
    this.address,
  });

  final String id;
  final String? firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? city;
  final String? address;

  String get fullName => '${firstName ?? ''} $lastName'.trim();

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
    );
  }
}