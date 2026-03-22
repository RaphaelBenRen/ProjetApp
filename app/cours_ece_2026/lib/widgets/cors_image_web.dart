import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class CorsImage extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CorsImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  State<CorsImage> createState() => _CorsImageState();
}

class _CorsImageState extends State<CorsImage> {
  late final String _viewType;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'cors-image-${widget.url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final img = html.ImageElement()..src = widget.url;
      img.style
        ..height = '100%'
        ..width = '100%'
        ..objectFit = widget.fit == BoxFit.cover ? 'cover' : 'contain';

      img.onError.listen((_) {
        if (mounted) {
          setState(() => _hasError = true);
        }
      });

      return img;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && widget.errorBuilder != null) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: widget.errorBuilder!(context, 'Image failed to load', null),
      );
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
