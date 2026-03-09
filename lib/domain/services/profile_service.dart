import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login_service.dart';

class ProfileService {
  ProfileService({http.Client? client, LoginService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? LoginService();

  final http.Client _client;
  final LoginService _authService;

  static const _fullNameKey = 'profile_full_name';
  static const _studentIdKey = 'profile_student_id';
  static const _usernameKey = 'profile_username';
  static const _imageUrlKey = 'profile_image_url';
  static const _profileUrl = 'https://eduapi.uztelecom.uz/api/v1/profile/';
  static const _changeProfileUrl =
      'https://eduapi.uztelecom.uz/api/v1/change-profile/';

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
    );
  }

  Future<void> clearCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fullNameKey);
    await prefs.remove(_studentIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_imageUrlKey);
  }

  Future<ProfileInfo> fetchProfile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await getCachedProfile();
      if (cached != null) return cached;
    }

    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        Uri.parse(_profileUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            'Profil ma\'lumotlarini olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Profil ma\'lumotlari mavjud emas.');
    }

    final profile = ProfileInfo(
      fullName: data['full_name']?.toString() ?? 'Foydalanuvchi',
      phone: data['phone']?.toString(),
      email: data['email']?.toString(),
      roleName: (data['selected_role'] as Map<String, dynamic>?)?['name']
          ?.toString(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, profile.fullName);
    if (profile.phone != null) {
      await prefs.setString(_studentIdKey, profile.phone!);
    }
    if (profile.email != null) {
      await prefs.setString(_usernameKey, profile.email!);
    }
    if (profile.roleName != null) {
      await prefs.setString(_imageUrlKey, profile.roleName!);
    }

    return profile;
  }

  Future<EditableProfileInfo> fetchEditableProfile() async {
    final response = await _authService.authorizedRequest(
      request: (token) => _client.get(
        Uri.parse(_profileUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(response.body) ??
            'Profil ma\'lumotlarini olishda xatolik.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return EditableProfileInfo(
      fullName: data['full_name']?.toString() ?? '',
      birthdate: data['birthdate']?.toString(),
      photo: data['photo']?.toString() ?? '',
      position: data['position']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      genInformation: data['gen_information']?.toString() ?? '',
    );
  }

  Future<void> updateProfile(EditableProfileInfo profile) async {
    final payload = <String, dynamic>{
      'full_name': profile.fullName,
      'photo': profile.photo,
      'position': profile.position,
      'email': profile.email,
      'gen_information': profile.genInformation,
    };
    if (profile.birthdate != null && profile.birthdate!.isNotEmpty) {
      payload['birthdate'] = profile.birthdate;
    }

    final response = await _authService.authorizedRequest(
      request: (token) => _client.patch(
        Uri.parse(_changeProfileUrl),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 202 &&
        response.statusCode != 204) {
      throw Exception(
        _extractMessage(response.body) ??
            'Profil ma\'lumotlarini yangilashda xatolik.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, profile.fullName);
    if (profile.email.isNotEmpty) {
      await prefs.setString(_usernameKey, profile.email);
    } else {
      await prefs.remove(_usernameKey);
    }
  }

  String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        return json['message']?.toString();
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _client.close();
  }
}

class ProfileInfo {
  final String fullName;
  final String? phone;
  final String? email;
  final String? roleName;

  const ProfileInfo({
    required this.fullName,
    this.phone,
    this.email,
    this.roleName,
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
