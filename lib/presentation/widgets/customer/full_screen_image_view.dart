import 'package:flutter/material.dart';

// 1. First, create a new widget for the full screen image view
class FullScreenImageView extends StatefulWidget {
  final String imagePath;

  const FullScreenImageView({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  void _zoomIn() {
    setState(() {
      _currentScale = _currentScale + 0.5;
      if (_currentScale > 5.0) _currentScale = 5.0;
      _updateTransformationController();
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = _currentScale - 0.5;
      if (_currentScale < 0.5) _currentScale = 0.5;
      _updateTransformationController();
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _updateTransformationController() {
    final Matrix4 matrix = Matrix4.identity()
      ..scale(_currentScale, _currentScale);
    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          onInteractionEnd: (details) {
            // Update current scale after gesture interaction
            final scale = _transformationController.value.getMaxScaleOnAxis();
            if (scale != _currentScale) {
              setState(() {
                _currentScale = scale;
              });
            }
          },
          child: Image.network(
            widget.imagePath,
            fit: BoxFit.contain,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: Colors.white,
                  ),
                );
              }
            },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.withOpacity(0.2),
                ),
                child: const Icon(Icons.hide_image_outlined,
                    color: Colors.white, size: 50),
              );
            },
          ),
        ),
      ),
    );
  }
}
