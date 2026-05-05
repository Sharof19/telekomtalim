class OtpRouteArgs {
  final String login;
  final bool resetPassword;

  const OtpRouteArgs({required this.login, this.resetPassword = false});
}
