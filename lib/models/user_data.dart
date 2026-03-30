class UserData {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? summary;
  final String? email;
  final String? phone;
  final String? address;
  final String? zipCode;
  final String? city;
  final String? country;
  final String? website1;
  final String? url1;
  final String? website2;
  final String? url2;

  UserData({
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.summary,
    this.email,
    this.phone,
    this.address,
    this.zipCode,
    this.city,
    this.country,
    this.website1,
    this.url1,
    this.website2,
    this.url2,
  });

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'summary': summary ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
      'address': address ?? '',
      'zipCode': zipCode ?? '',
      'city': city ?? '',
      'country': country ?? '',
      'website1': website1 ?? '',
      'url1': url1 ?? '',
      'website2': website2 ?? '',
      'url2': url2 ?? '',
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName']?.isEmpty == true ? null : map['middleName'],
      lastName: map['lastName'] ?? '',
      summary: map['summary']?.isEmpty == true ? null : map['summary'],
      email: map['email']?.isEmpty == true ? null : map['email'],
      phone: map['phone']?.isEmpty == true ? null : map['phone'],
      address: map['address']?.isEmpty == true ? null : map['address'],
      zipCode: map['zipCode']?.isEmpty == true ? null : map['zipCode'],
      city: map['city']?.isEmpty == true ? null : map['city'],
      country: map['country']?.isEmpty == true ? null : map['country'],
      website1: map['website1']?.isEmpty == true ? null : map['website1'],
      url1: map['url1']?.isEmpty == true ? null : map['url1'],
      website2: map['website2']?.isEmpty == true ? null : map['website2'],
      url2: map['url2']?.isEmpty == true ? null : map['url2'],
    );
  }
}
