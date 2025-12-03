import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hasil_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';

class HasilView extends GetView<HasilController> {
  const HasilView({super.key});

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
            _buildResultCard(context),
            const SizedBox(height: AppConstants.paddingLG),
            _buildKriteriaSection(context),
            const SizedBox(height: AppConstants.paddingLG),
            _buildRankingTable(context),
            const SizedBox(height: AppConstants.paddingXL),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BackButton(onTap: controller.goBack),
            const SizedBox(width: AppConstants.paddingMD),
            Expanded(
              child: Text(
                'Hasil Ranking TOPSIS',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSM),
        Obx(() => Text(
          'File: ${controller.namaFile.value}',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: AppColors.textSecondary,
          ),
        )),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Obx(() {
      final total = controller.hasilRanking.length;
      final top3 = controller.hasilRanking.take(3).toList();

      return Container(
        padding: EdgeInsets.all(isMobile ? AppConstants.paddingMD : AppConstants.paddingLG),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                const SizedBox(width: AppConstants.paddingSM),
                Text(
                  'Top 3 Siswa Terbaik',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLG),
            Wrap(
              spacing: AppConstants.paddingMD,
              runSpacing: AppConstants.paddingMD,
              alignment: WrapAlignment.center,
              children: top3.map((siswa) => _buildTopCard(context, siswa)).toList(),
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Text(
              'Total: $total siswa diproses',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTopCard(BuildContext context, dynamic siswa) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final ranking = siswa.ranking ?? 0;
    final medalColor = _getMedalColor(ranking);

    return Container(
      width: isMobile ? double.infinity : 180,
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: medalColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#$ranking',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSM),
          Text(
            siswa.nama,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            siswa.kelas,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            'Skor: ${(siswa.skorTopsis ?? 0).toStringAsFixed(4)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int ranking) {
    switch (ranking) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  Widget _buildKriteriaSection(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Obx(() {
      if (controller.kriteriaList.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(isMobile ? AppConstants.paddingMD : AppConstants.paddingLG),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: AppColors.primary, size: 20),
                const SizedBox(width: AppConstants.paddingSM),
                const Text(
                  'Kriteria yang Digunakan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Wrap(
              spacing: AppConstants.paddingSM,
              runSpacing: AppConstants.paddingSM,
              children: controller.kriteriaList.map((kriteria) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMD,
                    vertical: AppConstants.paddingSM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        kriteria.nama,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingXS),
                      Text(
                        '(${(kriteria.bobot * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRankingTable(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? AppConstants.paddingMD : AppConstants.paddingLG),
            child: Row(
              children: [
                Icon(Icons.leaderboard, color: AppColors.primary, size: 20),
                const SizedBox(width: AppConstants.paddingSM),
                const Text(
                  'Tabel Ranking Lengkap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (controller.hasilRanking.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppConstants.paddingXL),
                child: Center(
                  child: Text(
                    'Tidak ada data',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            return isMobile
                ? _buildMobileTable()
                : _buildDesktopTable();
          }),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.background),
        columns: [
          const DataColumn(label: Text('Rank', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Nama Siswa', style: TextStyle(fontWeight: FontWeight.w600))),
          const DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.w600))),
          ...controller.kriteriaList.map((k) => DataColumn(
            label: Text(k.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
            numeric: true,
          )),
          const DataColumn(label: Text('Skor TOPSIS', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
        ],
        rows: controller.hasilRanking.map((siswa) {
          return DataRow(
            color: siswa.ranking != null && siswa.ranking! <= 3
                ? WidgetStateProperty.all(_getMedalColor(siswa.ranking!).withOpacity(0.1))
                : null,
            cells: [
              DataCell(_buildRankCell(siswa.ranking ?? 0)),
              DataCell(Text(siswa.nama)),
              DataCell(Text(siswa.kelas)),
              ...controller.kriteriaList.map((k) => DataCell(
                Text((siswa.nilai[k.nama] ?? 0).toStringAsFixed(1)),
              )),
              DataCell(Text(
                (siswa.skorTopsis ?? 0).toStringAsFixed(4),
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileTable() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.hasilRanking.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final siswa = controller.hasilRanking[index];
        return Container(
          color: siswa.ranking != null && siswa.ranking! <= 3
              ? _getMedalColor(siswa.ranking!).withOpacity(0.1)
              : null,
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          child: Row(
            children: [
              _buildRankCell(siswa.ranking ?? 0),
              const SizedBox(width: AppConstants.paddingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      siswa.kelas,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Skor',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  Text(
                    (siswa.skorTopsis ?? 0).toStringAsFixed(4),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankCell(int ranking) {
    final color = _getMedalColor(ranking);
    final isTop3 = ranking <= 3;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isTop3 ? color : AppColors.background,
        shape: BoxShape.circle,
        border: isTop3 ? null : Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          '$ranking',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isTop3 ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: AppConstants.paddingMD,
        runSpacing: AppConstants.paddingMD,
        alignment: WrapAlignment.center,
        children: [
          _ActionButton(
            label: 'Upload File Baru',
            icon: Icons.upload_file,
            isPrimary: true,
            onTap: controller.uploadNewFile,
          ),
          _ActionButton(
            label: 'Lihat Riwayat',
            icon: Icons.history,
            isPrimary: false,
            onTap: controller.goToRiwayat,
          ),
        ],
      ),
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

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
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
            color: widget.isPrimary
                ? (_isHovering ? AppColors.primaryDark : AppColors.primary)
                : (_isHovering ? AppColors.primary.withOpacity(0.1) : AppColors.surface),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMD),
            border: widget.isPrimary
                ? null
                : Border.all(color: AppColors.primary),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(_isHovering ? 0.4 : 0.3),
                      blurRadius: _isHovering ? 15 : 10,
                      offset: Offset(0, _isHovering ? 6 : 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isPrimary ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: AppConstants.paddingSM),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
