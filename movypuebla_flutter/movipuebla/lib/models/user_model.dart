enum UserRole { citizen, driver }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? assignedRouteId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.assignedRouteId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] == 'driver' ? UserRole.driver : UserRole.citizen,
      assignedRouteId: json['assignedRouteId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role == UserRole.driver ? 'driver' : 'citizen',
        if (assignedRouteId != null) 'assignedRouteId': assignedRouteId,
      };
}
