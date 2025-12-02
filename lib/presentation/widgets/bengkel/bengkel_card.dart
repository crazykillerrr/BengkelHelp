import 'package:flutter/material.dart';
import '../../../data/models/bengkel_model.dart';
import '../../../core/themes/app_theme.dart';

class BengkelCard extends StatelessWidget {
  final BengkelModel bengkel;
  final VoidCallback onTap;
  
  const BengkelCard({
    super.key,
    required this.bengkel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.shadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusM),
                topRight: Radius.circular(AppTheme.radiusM),
              ),
              child: bengkel.photoUrl != null
                  ? Image.network(
                      bengkel.photoUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Verification
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bengkel.name,
                          style: AppTheme.h3.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bengkel.isVerified)
                        const Icon(
                          Icons.verified,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        bengkel.rating.toStringAsFixed(1),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${bengkel.totalReviews} ulasan)',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          bengkel.address,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // Services
                  Wrap(
                    spacing: AppTheme.spacingXS,
                    runSpacing: AppTheme.spacingXS,
                    children: bengkel.services.take(3).map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          service,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppTheme.backgroundColor,
      child: const Icon(
        Icons.build_circle,
        size: 48,
        color: AppTheme.textHint,
      ),
    );
  }
}
