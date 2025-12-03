import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class InfoSection extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;

  const InfoSection({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: isMobile ? AppConstants.paddingMD : 0),
        padding: EdgeInsets.all(isMobile ? AppConstants.paddingMD : AppConstants.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLG),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isHovering ? 20 : 10,
              offset: Offset(0, _isHovering ? 8 : 4),
            ),
          ],
          border: Border.all(
            color: _isHovering ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
            width: 1,
          ),
        ),
        transform: _isHovering
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isHovering
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isHovering ? Colors.white : AppColors.primary,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMD),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
