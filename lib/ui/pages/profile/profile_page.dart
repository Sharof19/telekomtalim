import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/profile/load_profile_use_case.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/pages/profile/settings_page.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_header.dart';
import 'package:uztelecom/ui/providers/profile/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  final bool embedded;

  const ProfilePage({super.key, this.embedded = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ProfileProvider(loadProfile: context.read<LoadProfileUseCase>())
      ..load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = ChangeNotifierProvider<ProfileProvider>.value(
      value: _provider,
      child: Container(
        color: isDark
            ? AppColors.darkBackground
            : AppColors.profileBackgroundLight,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileHeader(),
                SizedBox(height: 18),
                const SettingsSections(
                  scrollable: false,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return widget.embedded ? content : Scaffold(body: content);
  }
}
