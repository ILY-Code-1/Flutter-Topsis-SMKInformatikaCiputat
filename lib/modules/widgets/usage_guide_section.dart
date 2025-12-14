import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class UsageGuideSection extends StatelessWidget {
  const UsageGuideSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final padding = ResponsiveHelper.getHorizontalPadding(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
      padding: padding.copyWith(
        top: AppConstants.paddingXL,
        bottom: AppConstants.paddingXL,
      ),
      child: Column(
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: AppConstants.paddingXL),
          _buildSteps(context),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMD),
        Text(
          'Cara Penggunaan Aplikasi',
          style: TextStyle(
            fontSize: isMobile ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingSM),
        Text(
          'Ikuti langkah-langkah berikut untuk melakukan perankingan siswa',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSteps(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final steps = [
      _StepData(
        number: '1',
        title: 'Download Template',
        description: 'Download template Excel yang telah disediakan untuk memastikan format data sesuai dengan sistem.',
        icon: Icons.download_rounded,
        color: const Color(0xFF6366F1),
      ),
      _StepData(
        number: '2',
        title: 'Isi Data Siswa',
        description: 'Isi data siswa pada template: Nama, Kelas, Nilai Produktif, Nilai Sikap, Jumlah Absen, dan Nilai Raport.',
        icon: Icons.edit_document,
        color: const Color(0xFF8B5CF6),
      ),
      _StepData(
        number: '3',
        title: 'Upload File Excel',
        description: 'Upload file Excel yang sudah diisi melalui tombol "Pilih File" atau drag & drop ke area upload.',
        icon: Icons.cloud_upload_rounded,
        color: const Color(0xFF06B6D4),
      ),
      _StepData(
        number: '4',
        title: 'Proses TOPSIS',
        description: 'Sistem akan otomatis memproses data menggunakan metode TOPSIS dengan bobot kriteria yang telah ditentukan.',
        icon: Icons.calculate_rounded,
        color: const Color(0xFF10B981),
      ),
      _StepData(
        number: '5',
        title: 'Lihat Hasil Ranking',
        description: 'Hasil perankingan akan ditampilkan lengkap dengan skor TOPSIS setiap siswa.',
        icon: Icons.leaderboard_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _StepData(
        number: '6',
        title: 'Simpan & Download',
        description: 'Simpan key unik untuk akses kembali dan download hasil dalam format PDF.',
        icon: Icons.save_alt_rounded,
        color: const Color(0xFFEF4444),
      ),
    ];

    if (isMobile) {
      return Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;
          return _StepCard(
            step: step,
            isMobile: true,
            showConnector: !isLast,
          );
        }).toList(),
      );
    }

    // Desktop/Tablet: 2 atau 3 columns
    final crossAxisCount = isTablet ? 2 : 3;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppConstants.paddingLG,
        mainAxisSpacing: AppConstants.paddingLG,
        childAspectRatio: isTablet ? 1.3 : 1.4,
      ),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _StepCard(
          step: steps[index],
          isMobile: false,
          showConnector: false,
        );
      },
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _StepCard extends StatefulWidget {
  final _StepData step;
  final bool isMobile;
  final bool showConnector;

  const _StepCard({
    required this.step,
    required this.isMobile,
    required this.showConnector,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return _buildMobileCard();
    }
    return _buildDesktopCard();
  }

  Widget _buildMobileCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepNumber(),
              const SizedBox(width: AppConstants.paddingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.step.icon,
                          color: widget.step.color,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.paddingSM),
                        Expanded(
                          child: Text(
                            widget.step.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSM),
                    Text(
                      widget.step.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.showConnector)
          Container(
            width: 2,
            height: 24,
            margin: const EdgeInsets.only(left: 27),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.step.color.withOpacity(0.5),
                  widget.step.color.withOpacity(0.1),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopCard() {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLG),
                border: Border.all(
                  color: _isHovering
                      ? widget.step.color.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovering
                        ? widget.step.color.withOpacity(0.15)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _isHovering ? 20 : 10,
                    offset: Offset(0, _isHovering ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStepNumber(),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppConstants.paddingSM),
                        decoration: BoxDecoration(
                          color: widget.step.color.withOpacity(_isHovering ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
                        ),
                        child: Icon(
                          widget.step.icon,
                          color: widget.step.color,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMD),
                  Text(
                    widget.step.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSM),
                  Expanded(
                    child: Text(
                      widget.step.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepNumber() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.step.color,
            widget.step.color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSM),
        boxShadow: [
          BoxShadow(
            color: widget.step.color.withOpacity(_isHovering ? 0.4 : 0.2),
            blurRadius: _isHovering ? 10 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.step.number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
