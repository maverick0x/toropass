class VerifyKycParams {
  final String firstName;
  final String middleName;
  final String lastName;
  final String bvn;
  final String currency;
  final String phoneNumber;
  final String dob;
  final String address;

  const VerifyKycParams({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.bvn,
    required this.currency,
    required this.phoneNumber,
    required this.dob,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "bvn": bvn,
        "currency": currency,
        "phoneNumber": phoneNumber,
        "dob": dob,
        "address": address,
      };
}
