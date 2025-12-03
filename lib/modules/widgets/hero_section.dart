import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../home/home_controller.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  late DropzoneViewController _dropzoneController;
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppConstants.paddingMD : AppConstants.paddingXL,
        vertical: isMobile ? AppConstants.paddingXL : AppConstants.paddingXXL,
      ),
      child: Column(
        children: [
          Text(
            AppConstants.appTitle,
            style: TextStyle(
              fontSize: isMobile ? 24 : (isTablet ? 32 : 40),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMD),
          Text(
            'Upload file Excel (.xlsx) untuk memulai perhitungan ranking',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? AppConstants.paddingLG : AppConstants.paddingXL),
          _buildDropzone(context),
          const SizedBox(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  Widget _buildDropzone(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Obx(() {
      final isHovering = controller.isHovering.value;
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;

      return Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 500,
            ),
            height: isMobile ? 200 : 250,
            decoration: BoxDecoration(
              color: isHovering
                  ? AppColors.dropzoneBackground
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLG),
              border: Border.all(
                color: isHovering ? AppColors.primary : AppColors.dropzoneBorder,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovering
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isHovering ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                DropzoneView(
                  onCreated: (ctrl) => _dropzoneController = ctrl,
                  onHover: () => controller.setHovering(true),
                  onLeave: () => controller.setHovering(false),
                  onDropFile: (ev) async {
                    final bytes = await _dropzoneController.getFileData(ev);
                    final name = await _dropzoneController.getFilename(ev);
                    controller.processDroppedFile(bytes, name);
                  },
                  onDropInvalid: (ev) {
                    controller.errorMessage.value =
                        'File tidak valid. Gunakan file .xlsx';
                  },
                  mime: const [
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                    'application/vnd.ms-excel',
                  ],
                ),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      : _buildDropzoneContent(context, isHovering),
                ),
              ],
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.paddingMD),
              child: Text(
                error,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }

  Widget _buildDropzoneContent(BuildContext context, bool isHovering) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isHovering ? 1.1 : 1.0),
          child: Icon(
            Icons.cloud_upload_outlined,
            size: isMobile ? 48 : 64,
            color: isHovering ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMD),
        _UploadButton(
          onTap: controller.pickFile,
          isMobile: isMobile,
        ),
        const SizedBox(height: AppConstants.paddingMD),
        Text(
          'Atau Drop File Kesini',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _UploadButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isMobile;

  const _UploadButton({required this.onTap, required this.isMobile});

  @override
  State<_UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<_UploadButton> {
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
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 24 : 32,
            vertical: widget.isMobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: _isHovering ? AppColors.primaryDark : AppColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_isHovering ? 0.4 : 0.3),
                blurRadius: _isHovering ? 15 : 10,
                offset: Offset(0, _isHovering ? 6 : 4),
              ),
            ],
          ),
          child: Text(
            'Pilih XLSX File',
            style: TextStyle(
              fontSize: widget.isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
