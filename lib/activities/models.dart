
class Address {
  final String street;
  final String city;

  Address({required this.street, required this.city});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class Company {
  final String name;

  Company({required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(name: json['name'] ?? '');
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final Address address;
  final Company company;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      company: Company.fromJson(json['company'] ?? {}),
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
