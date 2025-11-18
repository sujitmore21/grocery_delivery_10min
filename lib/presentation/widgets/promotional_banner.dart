import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PromotionalBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateRange;
  final String? imageUrl;
  final String? imageAsset;
  final VoidCallback? onTap;

  const PromotionalBanner({
    super.key,
    required this.title,
    this.subtitle = '',
    this.dateRange = '',
    this.imageUrl,
    this.imageAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null || imageAsset != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: hasImage ? 140 : null,
        decoration: BoxDecoration(
          color: const Color(0xFF00B761),
          borderRadius: BorderRadius.circular(8),
          boxShadow: hasImage
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Background Image
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Container(color: const Color(0xFF00B761));
                        },
                      )
                    : imageAsset != null
                    ? Image.asset(
                        imageAsset!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: const Color(0xFF00B761));
                        },
                      )
                    : Container(color: const Color(0xFF00B761)),
              ),
            // Gradient Overlay for better text readability
            if (hasImage)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (dateRange.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              dateRange,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
