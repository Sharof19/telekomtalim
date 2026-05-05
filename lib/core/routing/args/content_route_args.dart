class ContentWebviewRouteArgs {
  final String url;
  final String title;
  final String? fallbackVideoUrl;

  const ContentWebviewRouteArgs({
    required this.url,
    required this.title,
    this.fallbackVideoUrl,
  });
}
