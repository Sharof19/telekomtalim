import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/media/build_authorized_video_headers_use_case.dart';

class AuthorizedNetworkImage extends StatefulWidget {
  const AuthorizedNetworkImage({
    super.key,
    required this.url,
    this.fit,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String url;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  @override
  State<AuthorizedNetworkImage> createState() => _AuthorizedNetworkImageState();
}

class _AuthorizedNetworkImageState extends State<AuthorizedNetworkImage> {
  late Future<Map<String, String>> _headersFuture;

  @override
  void initState() {
    super.initState();
    _headersFuture = context.read<BuildAuthorizedVideoHeadersUseCase>()();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _headersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.expand();
        }
        final headers = snapshot.data;
        return Image.network(
          widget.url,
          fit: widget.fit,
          headers: headers == null || headers.isEmpty ? null : headers,
          errorBuilder: widget.errorBuilder,
          loadingBuilder: widget.loadingBuilder,
        );
      },
    );
  }
}
