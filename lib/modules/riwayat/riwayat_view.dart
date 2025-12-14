import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'riwayat_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

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
                  _buildContent(context),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final padding = ResponsiveHelper.getHorizontalPadding(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
        padding: padding.copyWith(
          top: AppConstants.paddingXL,
          bottom: AppConstants.paddingXL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.paddingLG),
            _buildRiwayatList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Row(
      children: [
        _BackButton(onTap: controller.goBack),
        const SizedBox(width: AppConstants.paddingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Perhitungan',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXS),
              const Text(
                'Lihat dan kelola semua hasil perhitungan TOPSIS sebelumnya',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: controller.getFirebaseData,
          icon: const Icon(Icons.cloud_download),
          label: const Text('Get Firebase Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatList(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return GetBuilder<RiwayatController>(
      init: controller,
      builder: (ctrl) {
        final riwayatList = ctrl.riwayatList;

        if (riwayatList.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            _buildListHeader(context, riwayatList.length),
            const SizedBox(height: AppConstants.paddingMD),
            ...riwayatList.map((riwayat) => _RiwayatCard(
              riwayat: riwayat,
              isMobile: isMobile,
              onView: () => controller.lihatDetail(riwayat.id),
              onDelete: () => _showDeleteDialog(context, riwayat.id),
            )),
          ],
        );
      },
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD,
            vertical: AppConstants.paddingSM,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, color: AppColors.primary, size: 18),
              const SizedBox(width: AppConstants.paddingXS),
              Text(
                '$count Riwayat',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (count > 0)
          _SmallButton(
            label: 'Hapus Semua',
            icon: Icons.delete_sweep,
            color: AppColors.error,
            onTap: () => _showClearAllDialog(context),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLG),
          const Text(
            'Belum Ada Riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSM),
          const Text(
            'Upload file Excel untuk memulai perhitungan TOPSIS',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLG),
          _ActionButton(
            label: 'Mulai Perhitungan',
            icon: Icons.upload_file,
            onTap: controller.goHome,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
        ),
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.confirmHapusRiwayat(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
        ),
        title: const Text('Hapus Semua Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearAllRiwayat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatefulWidget {
  final dynamic riwayat;
  final bool isMobile;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _RiwayatCard({
    required this.riwayat,
    required this.isMobile,
    required this.onView,
    required this.onDelete,
  });

  @override
  State<_RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<_RiwayatCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final topSiswa = widget.riwayat.hasil.isNotEmpty ? widget.riwayat.hasil.first : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMD),
        padding: EdgeInsets.all(widget.isMobile ? AppConstants.paddingMD : AppConstants.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLG),
          border: Border.all(
            color: _isHovering ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isHovering ? 15 : 10,
              offset: Offset(0, _isHovering ? 6 : 4),
            ),
          ],
        ),
        child: widget.isMobile
            ? _buildMobileLayout(dateFormat, topSiswa)
            : _buildDesktopLayout(dateFormat, topSiswa),
      ),
    );
  }

  Widget _buildDesktopLayout(DateFormat dateFormat, dynamic topSiswa) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
          ),
          child: const Icon(
            Icons.description,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.riwayat.namaFile,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXS),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(widget.riwayat.tanggal),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMD),
                  Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.riwayat.jumlahSiswa} siswa',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (topSiswa != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMD,
              vertical: AppConstants.paddingSM,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text(
                  topSiswa.nama,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: AppConstants.paddingMD),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SmallButton(
              label: 'Lihat',
              icon: Icons.visibility,
              color: AppColors.primary,
              onTap: widget.onView,
            ),
            const SizedBox(width: AppConstants.paddingSM),
            _SmallButton(
              label: 'Hapus',
              icon: Icons.delete,
              color: AppColors.error,
              onTap: widget.onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(DateFormat dateFormat, dynamic topSiswa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
              ),
              child: const Icon(
                Icons.description,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSM),
            Expanded(
              child: Text(
                widget.riwayat.namaFile,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSM),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              dateFormat.format(widget.riwayat.tanggal),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppConstants.paddingSM),
            Icon(Icons.people, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${widget.riwayat.jumlahSiswa} siswa',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        if (topSiswa != null) ...[
          const SizedBox(height: AppConstants.paddingSM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSM,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusXS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 4),
                Text(
                  'Top: ${topSiswa.nama}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppConstants.paddingMD),
        Row(
          children: [
            Expanded(
              child: _SmallButton(
                label: 'Lihat Detail',
                icon: Icons.visibility,
                color: AppColors.primary,
                onTap: widget.onView,
                expand: true,
              ),
            ),
            const SizedBox(width: AppConstants.paddingSM),
            _SmallButton(
              label: '',
              icon: Icons.delete,
              color: AppColors.error,
              onTap: widget.onDelete,
            ),
          ],
        ),
      ],
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
          padding: const EdgeInsets.all(AppConstants.paddingSM),
          decoration: BoxDecoration(
            color: _isHovering ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
          ),
          child: Icon(
            Icons.arrow_back,
            color: _isHovering ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool expand;

  const _SmallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.expand = false,
  });

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
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
            horizontal: AppConstants.paddingSM,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _isHovering ? widget.color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
            border: Border.all(
              color: _isHovering ? widget.color : widget.color.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              if (widget.label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
            horizontal: AppConstants.paddingLG,
            vertical: AppConstants.paddingMD,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 20, color: Colors.white),
              const SizedBox(width: AppConstants.paddingSM),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
