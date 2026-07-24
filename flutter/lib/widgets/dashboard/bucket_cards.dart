import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/models/home_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BucketCardsSection extends StatelessWidget {
  final HomeBuckets? buckets;
  final bool isDark;

  const BucketCardsSection({
    super.key,
    required this.buckets,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (buckets == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBucketCard(
          title: 'bucket_cards.needs'.tr(),
          bucket: buckets!.needs,
          icon: Icons.shopping_cart_outlined,
          color: isDark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary,
        ),
        const SizedBox(height: 12),
        _buildBucketCard(
          title: 'bucket_cards.wants'.tr(),
          bucket: buckets!.wants,
          icon: Icons.favorite_outline_rounded,
          color: isDark
              ? AppColors.darkAccent
              : AppColors.lightAccent,
        ),
        const SizedBox(height: 12),
        _buildBucketCard(
          title: 'bucket_cards.savings'.tr(),
          bucket: buckets!.savings,
          icon: Icons.savings_outlined,
          color: isDark
              ? AppColors.darkSecondary
              : AppColors.lightSecondary,
          isSavings: true,
        ),
      ],
    );
  }

  Widget _buildBucketCard({
    required String title,
    required HomeBucket? bucket,
    required IconData icon,
    required Color color,
    bool isSavings = false,
  }) {
    if (bucket == null) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(
      bucket.status,
      isDark,
    );

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final targetText = bucket.target != null
        ? "${bucket.target!.toStringAsFixed(2)} ${'common.jod'.tr()}"
        : 'common.not_available'.tr();

    final actualText = bucket.actual != null
        ? "${bucket.actual!.toStringAsFixed(2)} ${'common.jod'.tr()}"
        : 'common.not_available'.tr();

    double progress = 0;

    if (bucket.usagePercent != null) {
      progress = bucket.usagePercent! / 100;
    } else if (bucket.actual != null &&
        bucket.target != null &&
        bucket.target! > 0) {
      progress = bucket.actual! / bucket.target!;
    }

    progress = progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color.withOpacity(
          isDark ? 0.07 : 0.045,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (bucket.status != null &&
                  bucket.status != 'unavailable')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _translatedStatus(bucket.status!),
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _buildMainDetail(
                  label: 'bucket_cards.actual'.tr(),
                  value: actualText,
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
              ),
              Container(
                width: 1,
                height: 35,
                color: borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMainDetail(
                  label: 'bucket_cards.target'.tr(),
                  value: targetText,
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                'bucket_cards.progress'.tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  color: subTextColor,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.ibmPlexSansArabic(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearPercentIndicator(
            lineHeight: 7,
            percent: progress,
            backgroundColor: borderColor,
            progressColor: statusColor,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
            animation: false,
          ),
          if ((!isSavings &&
                  bucket.reserved != null &&
                  bucket.reserved! > 0) ||
              (!isSavings &&
                  bucket.availableVariable != null) ||
              (isSavings &&
                  bucket.plannedEmergencyFund != null &&
                  bucket.plannedEmergencyFund! > 0) ||
              (isSavings &&
                  bucket.plannedGoalAllocations != null &&
                  bucket.plannedGoalAllocations! > 0) ||
              (isSavings &&
                  bucket.unallocatedSavings != null &&
                  bucket.unallocatedSavings! > 0)) ...[
            const SizedBox(height: 15),
            Divider(
              color: borderColor,
              height: 1,
            ),
            const SizedBox(height: 13),
          ],
          if (!isSavings &&
              bucket.reserved != null &&
              bucket.reserved! > 0)
            _buildSmallDetail(
              'bucket_cards.reserved'.tr(),
              "${bucket.reserved!.toStringAsFixed(2)} ${'common.jod'.tr()}",
              subTextColor,
              textColor,
            ),
          if (!isSavings &&
              bucket.availableVariable != null)
            _buildSmallDetail(
              'bucket_cards.available_variable'.tr(),
              "${bucket.availableVariable!.toStringAsFixed(2)} ${'common.jod'.tr()}",
              subTextColor,
              textColor,
            ),
          if (isSavings &&
              bucket.plannedEmergencyFund != null &&
              bucket.plannedEmergencyFund! > 0)
            _buildSmallDetail(
              'bucket_cards.emergency_fund'.tr(),
              "${bucket.plannedEmergencyFund!.toStringAsFixed(2)} ${'common.jod'.tr()}",
              subTextColor,
              textColor,
            ),
          if (isSavings &&
              bucket.plannedGoalAllocations != null &&
              bucket.plannedGoalAllocations! > 0)
            _buildSmallDetail(
              'bucket_cards.goal_allocations'.tr(),
              "${bucket.plannedGoalAllocations!.toStringAsFixed(2)} ${'common.jod'.tr()}",
              subTextColor,
              textColor,
            ),
          if (isSavings &&
              bucket.unallocatedSavings != null &&
              bucket.unallocatedSavings! > 0)
            _buildSmallDetail(
              'bucket_cards.unallocated_savings'.tr(),
              "${bucket.unallocatedSavings!.toStringAsFixed(2)} ${'common.jod'.tr()}",
              subTextColor,
              textColor,
            ),
          if (bucket.remaining != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'bucket_cards.remaining'.tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    "${bucket.remaining!.toStringAsFixed(2)} ${'common.jod'.tr()}",
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainDetail({
    required String label,
    required String value,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            color: subTextColor,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.ibmPlexSansArabic(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDetail(
    String label,
    String value,
    Color subTextColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                color: subTextColor,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: GoogleFonts.ibmPlexSansArabic(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _translatedStatus(String status) {
    switch (status) {
      case 'healthy':
        return 'bucket_cards.status.healthy'.tr();
      case 'moderate':
        return 'bucket_cards.status.moderate'.tr();
      case 'warning':
        return 'bucket_cards.status.warning'.tr();
      case 'critical':
        return 'bucket_cards.status.critical'.tr();
      case 'exceeded':
        return 'bucket_cards.status.exceeded'.tr();
      default:
        return status;
    }
  }

  Color _getStatusColor(
    String? status,
    bool isDark,
  ) {
    switch (status) {
      case 'healthy':
        return isDark
            ? AppColors.darkPrimary
            : AppColors.lightPrimary;

      case 'moderate':
      case 'warning':
        return isDark
            ? AppColors.darkAccent
            : AppColors.lightAccent;

      case 'critical':
      case 'exceeded':
        return isDark
            ? AppColors.darkError
            : AppColors.lightError;

      case 'unavailable':
      default:
        return isDark
            ? AppColors.darkSubText
            : AppColors.lightSubText;
    }
  }
}
