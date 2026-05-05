import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/profile/profile_use_cases.dart';
import 'package:uztelecom/core/errors/app_failure.dart';
import 'package:uztelecom/data/models/profile_models.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_field_box.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_gender_box.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_palette.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_saved_banner.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_sections.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  late final LoadEditableProfileUseCase _loadEditableProfile;
  late final UpdateProfileUseCase _updateProfile;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;
  String? _errorText;

  String _gender = 'Erkak';
  String _photo = '';
  String _position = '';
  String? _birthdateIso;
  String _initialFirstName = '';
  String _initialLastName = '';
  String _initialAge = '';
  String _initialGender = 'Erkak';
  String _initialEmail = '';

  @override
  void initState() {
    super.initState();
    _loadEditableProfile = context.read<LoadEditableProfileUseCase>();
    _updateProfile = context.read<UpdateProfileUseCase>();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final profile = await _loadEditableProfile();
      final parts = _splitName(profile.fullName);
      _firstNameController.text = parts.$1;
      _lastNameController.text = parts.$2;
      _emailController.text = profile.email;

      _birthdateIso = profile.birthdate;
      final age = _ageFromBirthdate(profile.birthdate);
      _ageController.text = age == null ? '' : age.toString();

      _gender = _normalizeGender(profile.genInformation);
      _photo = profile.photo;
      _position = profile.position;
      _captureInitialState();
    } catch (e) {
      _errorText = appFailureMessage(e);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  (String, String) _splitName(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return ('', '');
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  int? _ageFromBirthdate(String? birthdate) {
    final parsed = DateTime.tryParse(birthdate ?? '');
    if (parsed == null) return null;
    final now = DateTime.now();
    var age = now.year - parsed.year;
    final birthdayPassed =
        now.month > parsed.month ||
        (now.month == parsed.month && now.day >= parsed.day);
    if (!birthdayPassed) age -= 1;
    if (age < 0) return null;
    return age;
  }

  String _normalizeGender(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'ayol' || value == 'female' || value == 'женский') {
      return 'Ayol';
    }
    return 'Erkak';
  }

  String _buildBirthdateFromAge(String ageText) {
    final parsedAge = int.tryParse(ageText);
    if (parsedAge == null || parsedAge < 0 || parsedAge > 120) {
      return _birthdateIso ?? DateTime.now().toIso8601String().split('T').first;
    }

    final now = DateTime.now();
    final oldDate = DateTime.tryParse(_birthdateIso ?? '');
    final month = oldDate?.month ?? 1;
    final day = oldDate?.day ?? 1;
    final date = DateTime(now.year - parsedAge, month, day);
    return date.toIso8601String().split('T').first;
  }

  void _captureInitialState() {
    _initialFirstName = _firstNameController.text.trim();
    _initialLastName = _lastNameController.text.trim();
    _initialAge = _ageController.text.trim();
    _initialGender = _gender;
    _initialEmail = _emailController.text.trim();
  }

  bool _hasNoChanges() {
    return _firstNameController.text.trim() == _initialFirstName &&
        _lastNameController.text.trim() == _initialLastName &&
        _ageController.text.trim() == _initialAge &&
        _gender == _initialGender &&
        _emailController.text.trim() == _initialEmail;
  }

  Future<void> _saveProfile() async {
    if (_saving) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.ismingizniKiriting))),
      );
      return;
    }

    if (_hasNoChanges()) {
      setState(() => _isEditing = false);
      showProfileInfoSavedBanner(context);
      return;
    }

    setState(() => _saving = true);
    try {
      final fullName = [
        firstName,
        lastName,
      ].where((part) => part.isNotEmpty).join(' ');
      final birthdate = _buildBirthdateFromAge(_ageController.text.trim());

      await _updateProfile(
        EditableProfileInfo(
          fullName: fullName,
          birthdate: birthdate,
          photo: _photo,
          position: _position,
          email: _emailController.text.trim(),
          genInformation: _gender,
        ),
      );

      if (!mounted) return;
      setState(() {
        _birthdateIso = birthdate;
        _isEditing = false;
      });
      _captureInitialState();
      showProfileInfoSavedBanner(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appFailureMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_isEditing) {
      await _saveProfile();
      return;
    }
    setState(() => _isEditing = true);
  }

  @override
  Widget build(BuildContext context) {
    const uniformFontSize = 16.0;
    final colors = ProfileInfoPalette.resolve(context);
    final fieldLabelStyle = TextStyle(
      fontSize: uniformFontSize,
      fontWeight: FontWeight.w700,
      color: colors.title,
    );
    final counterStyle = TextStyle(
      fontSize: uniformFontSize,
      fontWeight: FontWeight.w500,
      color: colors.counter,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.title),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr(context, TrKey.personalInfo),
          style: TextStyle(
            fontSize: uniformFontSize,
            fontWeight: FontWeight.w700,
            color: colors.title,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colors.button))
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                children: [
                  if (_errorText != null) ...[
                    ProfileInfoErrorCard(
                      message: _errorText!,
                      palette: colors,
                      fontSize: uniformFontSize,
                    ),
                    const SizedBox(height: 18),
                  ],
                  ProfileInfoFieldSection(
                    label: tr(context, TrKey.ismingiz),
                    labelStyle: fieldLabelStyle,
                    counterStyle: counterStyle,
                    counterText: '${_firstNameController.text.length}/32',
                    child: ProfileInfoFieldBox(
                      controller: _firstNameController,
                      enabled: _isEditing,
                      maxLength: 32,
                      palette: colors,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoFieldSection(
                    label: tr(context, TrKey.familiya),
                    labelStyle: fieldLabelStyle,
                    counterStyle: counterStyle,
                    counterText: '${_lastNameController.text.length}/32',
                    child: ProfileInfoFieldBox(
                      controller: _lastNameController,
                      enabled: _isEditing,
                      maxLength: 32,
                      palette: colors,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoFieldSection(
                    label: tr(context, TrKey.yosh),
                    labelStyle: fieldLabelStyle,
                    counterStyle: counterStyle,
                    counterText: '${_ageController.text.length}/2',
                    child: ProfileInfoFieldBox(
                      controller: _ageController,
                      enabled: _isEditing,
                      maxLength: 2,
                      palette: colors,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoFieldSection(
                    label: tr(context, TrKey.jins),
                    labelStyle: fieldLabelStyle,
                    counterStyle: counterStyle,
                    child: ProfileInfoGenderBox(
                      enabled: _isEditing,
                      value: _gender,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _gender = v);
                      },
                      palette: colors,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ProfileInfoFieldSection(
                    label: tr(context, TrKey.elektronPochta),
                    labelStyle: fieldLabelStyle,
                    counterStyle: counterStyle,
                    child: ProfileInfoFieldBox(
                      controller: _emailController,
                      enabled: _isEditing,
                      palette: colors,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 34),
                  ProfileInfoPrimaryButton(
                    loading: _saving,
                    onPressed: _handlePrimaryAction,
                    label: _isEditing
                        ? tr(context, TrKey.saveUppercase)
                        : tr(context, TrKey.editUppercase),
                    backgroundColor: colors.button,
                  ),
                ],
              ),
      ),
    );
  }
}
