import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../app/routes/app_routes.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppConstants.paddingMD : AppConstants.paddingLG,
            vertical: AppConstants.paddingMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(context),
              _buildMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return InkWell(
      onTap: () => Get.offAllNamed(AppRoutes.home),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: AppConstants.paddingSM),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return _HoverButton(
      onTap: () => Get.toNamed(AppRoutes.riwayat),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppConstants.paddingXS),
          Text(
            'Riwayat',
            style: TextStyle(
              fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _HoverButton({required this.onTap, required this.child});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD,
            vertical: AppConstants.paddingSM,
          ),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
