import 'dart:convert';

import 'package:uztelecom/core/config/app_endpoints.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/datasources/remote/api_client.dart';
import 'package:uztelecom/data/models/profile_models.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ProfileInfo> fetchProfile() async {
    final response = await _apiClient.get(
      AppEndpoints.profile(),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Profil ma\'lumotlarini olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const ParsingFailure('Profil ma\'lumotlari mavjud emas.');
    }

    return ProfileInfo(
      fullName: data['full_name']?.toString() ?? 'Foydalanuvchi',
      phone: data['phone']?.toString(),
      email: data['email']?.toString(),
      roleName: (data['selected_role'] as Map<String, dynamic>?)?['name']
          ?.toString(),
      passwordCreated: data['password_created'] != false,
    );
  }

  Future<EditableProfileInfo> fetchEditableProfile() async {
    final response = await _apiClient.get(
      AppEndpoints.profile(),
      authorized: true,
    );
    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Profil ma\'lumotlarini olishda xatolik.',
    );

    final body = ApiClient.decodeObjectBody(response.body);
    final data = ApiClient.dataMap(body);

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

    final response = await _apiClient.patch(
      AppEndpoints.changeProfile(),
      authorized: true,
      headers: ApiClient.defaultAuthorizedJsonHeaders,
      body: jsonEncode(payload),
    );
    ApiClient.ensureSuccess(
      response,
      okStatuses: const {200, 201, 202, 204},
      fallbackMessage: 'Profil ma\'lumotlarini yangilashda xatolik.',
    );
  }
}
