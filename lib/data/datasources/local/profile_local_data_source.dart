import 'package:shared_preferences/shared_preferences.dart';
import 'package:uztelecom/data/models/profile_models.dart';

class ProfileLocalDataSource {
  static const _fullNameKey = 'profile_full_name';
  static const _studentIdKey = 'profile_student_id';
  static const _usernameKey = 'profile_username';
  static const _imageUrlKey = 'profile_image_url';
  static const _passwordCreatedKey = 'profile_password_created';

  Future<ProfileInfo?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString(_fullNameKey);
    final phone = prefs.getString(_studentIdKey);
    final email = prefs.getString(_usernameKey);
    final roleName = prefs.getString(_imageUrlKey);
    if (fullName == null && phone == null && email == null) return null;
    return ProfileInfo(
      fullName: fullName ?? 'Foydalanuvchi',
      phone: phone,
      email: email,
      roleName: roleName,
      passwordCreated: prefs.getBool(_passwordCreatedKey) ?? true,
    );
  }

  Future<void> saveProfile(ProfileInfo profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, profile.fullName);
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      await prefs.setString(_studentIdKey, profile.phone!);
    } else {
      await prefs.remove(_studentIdKey);
    }
    if (profile.email != null && profile.email!.isNotEmpty) {
      await prefs.setString(_usernameKey, profile.email!);
    } else {
      await prefs.remove(_usernameKey);
    }
    if (profile.roleName != null && profile.roleName!.isNotEmpty) {
      await prefs.setString(_imageUrlKey, profile.roleName!);
    } else {
      await prefs.remove(_imageUrlKey);
    }
    await prefs.setBool(_passwordCreatedKey, profile.passwordCreated);
  }

  Future<void> updateCachedEditableProfile(EditableProfileInfo profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, profile.fullName);
    if (profile.email.isNotEmpty) {
      await prefs.setString(_usernameKey, profile.email);
    } else {
      await prefs.remove(_usernameKey);
    }
  }

  Future<void> clearCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fullNameKey);
    await prefs.remove(_studentIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_imageUrlKey);
    await prefs.remove(_passwordCreatedKey);
  }
}
