class ProfileInfo {
  final String fullName;
  final String? phone;
  final String? email;
  final String? roleName;
  final bool passwordCreated;

  const ProfileInfo({
    required this.fullName,
    this.phone,
    this.email,
    this.roleName,
    this.passwordCreated = true,
  });
}

class EditableProfileInfo {
  final String fullName;
  final String? birthdate;
  final String photo;
  final String position;
  final String email;
  final String genInformation;

  const EditableProfileInfo({
    required this.fullName,
    required this.birthdate,
    required this.photo,
    required this.position,
    required this.email,
    required this.genInformation,
  });
}
