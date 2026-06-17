import 'package:flutter/material.dart';

class YoutubeThumbnail extends StatefulWidget {
  final String videoId;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const YoutubeThumbnail({
    super.key,
    required this.videoId,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.isCircular = false,
  });

  @override
  State<YoutubeThumbnail> createState() => _YoutubeThumbnailState();
}

class _YoutubeThumbnailState extends State<YoutubeThumbnail> {

  bool _useHd = true;

  @override
  void didUpdateWidget(
      covariant YoutubeThumbnail oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    //----------------------------------
    // Reset state jika video berubah
    //----------------------------------
    if (oldWidget.videoId != widget.videoId) {

      setState(() {
        _useHd = true;
      });

      debugPrint(
        '🔄 Thumbnail updated: ${oldWidget.videoId} -> ${widget.videoId}',
      );
    }
  }

  String get _thumbnailUrl {

    if (_useHd) {

      return
        'https://i.ytimg.com/vi/${widget.videoId}/maxresdefault.jpg';
    }

    return
      'https://i.ytimg.com/vi/${widget.videoId}/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {

    final imageWidget = Image.network(

      _thumbnailUrl,

      //----------------------------------
      // Paksa reload jika video berubah
      //----------------------------------
      key: ValueKey(
        '${widget.videoId}_$_useHd',
      ),

      width: widget.width,
      height: widget.height,

      fit: widget.fit ?? BoxFit.cover,

      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {

        //----------------------------------
        // Fallback HD -> HQ
        //----------------------------------
        if (_useHd) {

          WidgetsBinding.instance
              .addPostFrameCallback(
                (_) {

              if (!mounted) {
                return;
              }

              setState(() {
                _useHd = false;
              });
            },
          );

          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade800,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //----------------------------------
        // Final fallback
        //----------------------------------
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey.shade800,
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
          ),
        );
      },

      loadingBuilder: (
          context,
          child,
          loadingProgress,
          ) {

        if (loadingProgress == null) {
          return child;
        }

        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey.shade800,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );

    //----------------------------------
    // Circular Thumbnail
    //----------------------------------
    if (widget.isCircular) {

      return ClipOval(
        child: imageWidget,
      );
    }

    //----------------------------------
    // Rounded Thumbnail
    //----------------------------------
    if (widget.borderRadius != null) {

      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}