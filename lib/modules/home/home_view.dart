import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/hero_section.dart';
import '../widgets/info_section.dart';
import '../widgets/usage_guide_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const HeroSection(),
                  _buildInfoSections(context),
                  const UsageGuideSection(),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSections(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final padding = ResponsiveHelper.getHorizontalPadding(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.08),
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.paddingXL,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
        padding: padding,
        child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InfoSection(
                      title: AppConstants.tujuanTitle,
                      description: AppConstants.tujuanDescription,
                      icon: Icons.track_changes,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingLG),
                  Expanded(
                    child: InfoSection(
                      title: AppConstants.mengapaTopsisTitle,
                      description: AppConstants.mengapaTopsisDescription,
                      icon: Icons.psychology,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                InfoSection(
                  title: AppConstants.tujuanTitle,
                  description: AppConstants.tujuanDescription,
                  icon: Icons.track_changes,
                ),
                const SizedBox(height: AppConstants.paddingLG),
                InfoSection(
                  title: AppConstants.mengapaTopsisTitle,
                  description: AppConstants.mengapaTopsisDescription,
                  icon: Icons.psychology,
                ),
              ],
            ),
      ),
    );
  }
}
