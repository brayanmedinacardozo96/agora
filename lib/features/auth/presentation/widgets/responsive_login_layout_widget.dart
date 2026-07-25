import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/assets_constants.dart';
import '../../../../core/constants/ui_strings.dart';

/// Widget que maneja el layout responsivo del login con imagen a la izquierda
/// en pantallas grandes
class ResponsiveLoginLayout extends StatelessWidget {
  final Widget loginForm;

  const ResponsiveLoginLayout({super.key, required this.loginForm});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 800;
        if (isLargeScreen) {
          return _buildLargeScreenLayout();
        } else {
          return _buildSmallScreenLayout();
        }
      },
    );
  }

  /// Layout para pantallas grandes: imagen a la izquierda + formulario a la derecha
  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: _buildLoginImage(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: loginForm,
            ),
          ),
        ),
      ],
    );
  }

  /// Layout para pantallas pequeñas: solo formulario centrado
  Widget _buildSmallScreenLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: loginForm,
      ),
    );
  }

  /// Widget de imagen de login con estados de carga y error
  Widget _buildLoginImage() {
    return CachedNetworkImage(
      imageUrl: AssetsConstants.loginImageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildImagePlaceholder(),
      errorWidget: (context, url, error) => _buildImageError(error),
    );
  }

  /// Placeholder mientras se carga la imagen
  Widget _buildImagePlaceholder() {
    return Container(
      width: 500,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[400], strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            UIStrings.loadingImage,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Widget de error cuando falla la carga de imagen
  Widget _buildImageError(Object error) {
    return Container(
      width: 500,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            UIStrings.imageLoadError,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
