import 'package:flutter/material.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/models/home_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:alpha_app/screens/planning/savings_allocation_screen.dart' as import_savings_allocation;

class BucketCardsSection extends StatelessWidget {
  final HomeBuckets? buckets;
  final bool isDark;
  final String? cycleId;

  const BucketCardsSection({
    Key? key,
    required this.buckets,
    required this.isDark,
    this.cycleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (buckets == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (buckets?.needs != null)
          _buildBucketCard(context, "Needs", buckets!.needs!,
              isDark: isDark, isSavings: false),
        const SizedBox(height: 12),
        if (buckets?.wants != null)
          _buildBucketCard(context, "Wants", buckets!.wants!,
              isDark: isDark, isSavings: false),
        const SizedBox(height: 12),
        if (buckets?.savings != null)
          _buildBucketCard(context, "Savings", buckets!.savings!,
              isDark: isDark, isSavings: true, cycleId: cycleId),
      ],
    );
  }

  Widget _buildBucketCard(BuildContext context, String title, HomeBucket bucket,
      {required bool isDark, required bool isSavings, String? cycleId}) {
    final statusColor = _getStatusColor(bucket.status, isDark);

    double progress = 0.0;
    if (isSavings && bucket.target != null && bucket.target! > 0) {
      final unallocated = bucket.unallocatedSavings ?? 0.0;
      progress = unallocated / bucket.target!;
    } else if (bucket.usagePercent != null) {
      progress = bucket.usagePercent! / 100.0;
    } else if (bucket.actual != null &&
        bucket.target != null &&
        bucket.target! > 0) {
      progress = bucket.actual! / bucket.target!;
    }
    progress = progress.clamp(0.0, 1.0);

    final String actualText = "JOD ${_formatAmount(bucket.actual ?? 0)}";
    final String targetText = "JOD ${_formatAmount(bucket.target ?? 0)}";

    Widget card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForTitle(title), color: statusColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (bucket.status != null && bucket.status != 'unavailable')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bucket.status!.toUpperCase(),
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetail("Target", targetText),
                _buildDetail("Actual", actualText),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 6.0,
            percent: progress,
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
            progressColor: statusColor,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          if (!isSavings && bucket.reserved != null && bucket.reserved! > 0)
            _buildSmallDetail("Reserved for commitments:",
                "${_formatAmount(bucket.reserved!)} JOD"),
          if (!isSavings && bucket.availableVariable != null)
            _buildSmallDetail("Available for variable:",
                "${_formatAmount(bucket.availableVariable!)} JOD"),
          if (isSavings &&
              bucket.plannedEmergencyFund != null &&
              bucket.plannedEmergencyFund! > 0)
            _buildSmallDetail("Emergency Fund:",
                "${_formatAmount(bucket.plannedEmergencyFund!)} JOD"),
          if (isSavings &&
              bucket.plannedGoalAllocations != null &&
              bucket.plannedGoalAllocations! > 0) ...[
            _buildSmallDetail("Goal Allocations:",
                "${_formatAmount(bucket.plannedGoalAllocations!)} JOD"),
            if (bucket.goalAllocationsList != null && bucket.goalAllocationsList!.isNotEmpty)
              ...bucket.goalAllocationsList!.map((g) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildSmallDetail("- ${g.name}", "${_formatAmount(g.amount)} JOD"),
              )),
          ],
          if (isSavings &&
              bucket.unallocatedSavings != null &&
              bucket.unallocatedSavings! > 0)
            _buildSmallDetail("Unallocated Savings:",
                "${_formatAmount(bucket.unallocatedSavings!)} JOD"),
          const SizedBox(height: 8),
          if (!isSavings && bucket.remaining != null)
            Text(
              "Remaining: ${_formatAmount(bucket.remaining!)} JOD",
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );

    if (isSavings && cycleId != null && cycleId.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  import_savings_allocation.SavingsAllocationScreen(cycleId: cycleId),
            ),
          );
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansArabic(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  Color _getStatusColor(String? status, bool isDark) {
    switch (status) {
      case 'healthy':
        return Colors.green;
      case 'moderate':
      case 'warning':
        return Colors.orange;
      case 'critical':
      case 'exceeded':
        return Colors.red;
      case 'unavailable':
      default:
        return isDark ? Colors.grey[600]! : Colors.grey[400]!;
    }
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'needs':
        return Icons.shopping_cart_outlined;
      case 'wants':
        return Icons.favorite_outline;
      case 'savings':
      default:
        return Icons.savings_outlined;
    }
  }
}
