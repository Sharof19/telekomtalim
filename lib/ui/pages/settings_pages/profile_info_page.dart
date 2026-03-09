import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uztelecom/domain/services/profile_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final ProfileService _service = ProfileService();
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
    _loadProfile();
  }

  @override
  void dispose() {
    _service.dispose();
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
      final profile = await _service.fetchEditableProfile();
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
      _errorText = e.toString().replaceFirst('Exception: ', '');
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

  void _showSavedBanner() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        elevation: 0,
        backgroundColor: const Color(0xFFEAF8F1),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(context, uz: "Ma'lumotlar saqlandi", ru: 'Данные сохранены'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF0F5132),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tr(
                context,
                uz: "Ma'lumotlaringiz muvaffaqiyatli saqlandi",
                ru: 'Ваши данные успешно сохранены',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF2E7D5B),
              ),
            ),
          ],
        ),
        leading: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFD6F2E4),
          child: Icon(Icons.verified_rounded, color: Color(0xFF2AB673)),
        ),
        actions: [
          IconButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            icon: const Icon(Icons.close, color: Color(0xFF6F7C75)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_saving) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, uz: "Ismingizni kiriting.", ru: 'Введите имя.'),
          ),
        ),
      );
      return;
    }

    if (_hasNoChanges()) {
      setState(() => _isEditing = false);
      _showSavedBanner();
      return;
    }

    setState(() => _saving = true);
    try {
      final fullName = [
        firstName,
        lastName,
      ].where((part) => part.isNotEmpty).join(' ');
      final birthdate = _buildBirthdateFromAge(_ageController.text.trim());

      await _service.updateProfile(
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
      _showSavedBanner();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const uniformFontSize = 16.0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = _ProfileColors(
      mode: isDarkMode ? _ProfileMode.dark : _ProfileMode.light,
    );
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
          tr(context, uz: "Shaxsiy ma'lumotlar", ru: 'Личные данные'),
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.input,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        _errorText!,
                        style: TextStyle(
                          color: colors.value,
                          fontSize: uniformFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Text(
                    tr(context, uz: 'Ismingiz', ru: 'Имя'),
                    style: fieldLabelStyle,
                  ),
                  const SizedBox(height: 10),
                  _FieldBox(
                    controller: _firstNameController,
                    editable: _isEditing,
                    maxLength: 32,
                    colors: colors,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_firstNameController.text.length}/32',
                      style: counterStyle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(context, uz: 'Familiya', ru: 'Фамилия'),
                    style: fieldLabelStyle,
                  ),
                  const SizedBox(height: 10),
                  _FieldBox(
                    controller: _lastNameController,
                    editable: _isEditing,
                    maxLength: 32,
                    colors: colors,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_lastNameController.text.length}/32',
                      style: counterStyle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(context, uz: 'Yosh', ru: 'Возраст'),
                    style: fieldLabelStyle,
                  ),
                  const SizedBox(height: 10),
                  _FieldBox(
                    controller: _ageController,
                    editable: _isEditing,
                    maxLength: 2,
                    colors: colors,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_ageController.text.length}/2',
                      style: counterStyle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(context, uz: 'Jins', ru: 'Пол'),
                    style: fieldLabelStyle,
                  ),
                  const SizedBox(height: 10),
                  _GenderBox(
                    editable: _isEditing,
                    value: _gender,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _gender = v);
                    },
                    colors: colors,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    tr(context, uz: 'Elektron pochta', ru: 'Электронная почта'),
                    style: fieldLabelStyle,
                  ),
                  const SizedBox(height: 10),
                  _FieldBox(
                    controller: _emailController,
                    editable: _isEditing,
                    colors: colors,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () {
                              if (_isEditing) {
                                _saveProfile();
                              } else {
                                setState(() => _isEditing = true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colors.button,
                        disabledBackgroundColor: colors.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              tr(
                                context,
                                uz: _isEditing ? 'SAQLASH' : 'TAHRIRLASH',
                                ru: _isEditing ? 'СОХРАНИТЬ' : 'РЕДАКТИРОВАТЬ',
                              ),
                              style: const TextStyle(
                                fontSize: uniformFontSize,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final TextEditingController controller;
  final bool editable;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final _ProfileColors colors;
  final ValueChanged<String>? onChanged;

  const _FieldBox({
    required this.controller,
    required this.editable,
    required this.colors,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: editable,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: colors.value,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: colors.input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.borderFocused, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _GenderBox extends StatelessWidget {
  final bool editable;
  final String value;
  final ValueChanged<String?> onChanged;
  final _ProfileColors colors;

  const _GenderBox({
    required this.editable,
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (!editable) {
      return Container(
        height: 72,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: colors.input,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: colors.value,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.input,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.value,
            size: 30,
          ),
          dropdownColor: colors.input,
          borderRadius: BorderRadius.circular(14),
          style: TextStyle(
            color: colors.value,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            DropdownMenuItem(value: 'Erkak', child: Text('Erkak')),
            DropdownMenuItem(value: 'Ayol', child: Text('Ayol')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

enum _ProfileMode { dark, light }

class _ProfileColors {
  final Color background;
  final Color title;
  final Color input;
  final Color value;
  final Color border;
  final Color borderFocused;
  final Color counter;
  final Color button;

  _ProfileColors({required _ProfileMode mode})
    : background = mode == _ProfileMode.dark
          ? const Color(0xFF011326)
          : const Color(0xFFF7F7F8),
      title = mode == _ProfileMode.dark
          ? const Color(0xFFF4F7FB)
          : const Color(0xFF202530),
      input = mode == _ProfileMode.dark
          ? const Color(0xFF222736)
          : Colors.white,
      value = mode == _ProfileMode.dark
          ? const Color(0xFFDCE2EA)
          : const Color(0xFF3A404A),
      border = mode == _ProfileMode.dark
          ? const Color(0xFF222736)
          : const Color(0xFFD2D4DA),
      borderFocused = mode == _ProfileMode.dark
          ? const Color(0xFF4A97EC)
          : const Color(0xFFB6BBC5),
      counter = mode == _ProfileMode.dark
          ? const Color(0xFFC8CFDA)
          : const Color(0xFF4D5563),
      button = mode == _ProfileMode.dark
          ? const Color(0xFF4A98ED)
          : const Color(0xFF2F6BFF);
}
