import 'dart:developer';
import 'dart:io';

import 'package:design_system/indicators/sw_loading_spinner.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  const CircularImage({required this.height, required this.width, required this.source, super.key});

  final double height, width;
  final CircularImageSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(shape: BoxShape.circle, color: CustomThemeExtension.of(context).gray200),
      clipBehavior: Clip.antiAlias,
      child: source.build(context),
    );
  }
}

abstract class CircularImageSource {
  Image build(BuildContext context);
}

class FileImageSource implements CircularImageSource {
  FileImageSource({required this.file});

  final File file;

  @override
  Image build(BuildContext context) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, _) {
        if (frame == null) return const SwLoadingSpinner(size: 20, strokeWidth: 2);
        return child;
      },
    );
  }
}

class MemoryImageSource implements CircularImageSource {
  MemoryImageSource({required this.data});

  final Uint8List data;

  @override
  Image build(BuildContext context) {
    return Image.memory(
      data,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, _) {
        if (frame == null) return const SwLoadingSpinner(size: 20, strokeWidth: 2);
        return child;
      },
    );
  }
}

class NetworkImageSource implements CircularImageSource {
  NetworkImageSource({required this.url});

  final String url;

  @override
  Image build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, _) {
        if (frame == null) return const SwLoadingSpinner(size: 20, strokeWidth: 2);
        return child;
      },
      errorBuilder: (_, __, ___) {
        log('Error when building CircularImage: $__');
        return const CircleAvatar(backgroundColor: Colors.red);
      },
    );
  }
}
