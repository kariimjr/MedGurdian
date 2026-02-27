class PatientModel {
  final String uid;
  final String email;
  final String fullName;
  final int age;
  final String gender;
  final String phoneNumber;

  PatientModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
  });

  // Convert our Object to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Convert Firebase Map back to our Object (useful later)
  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age']?.toInt() ?? 0,
      gender: map['gender'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}