import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/providers/rating_provider.dart';
import 'package:testtale3/models/rating_model.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class RatingsReviewsScreen extends StatelessWidget {
  const RatingsReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId =
        context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.ratingsAndReviews,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<RatingModel>>(
          stream:
              context.read<RatingProvider>().driverRatingsStream(driverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final ratings = snapshot.data ?? [];
            final avg = ratings.isEmpty
                ? 0.0
                : ratings.map((r) => r.stars).reduce((a, b) => a + b) /
                    ratings.length;

            final counts = List.generate(5, (i) {
              final star = 5 - i;
              return ratings.where((r) => r.stars == star).length;
            });

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Rating overview
                  Container(
                    color: context.colors.surfaceColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              ratings.isEmpty
                                  ? '—'
                                  : avg.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: context.colors.textPrimary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (i) {
                                final full = i < avg.floor();
                                final half =
                                    !full && i < avg && (avg - avg.floor()) >= 0.5;
                                return Icon(
                                  full
                                      ? Icons.star
                                      : half
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  color: AppStyles.starRatingColor,
                                  size: 16,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${ratings.length} ${context.l10n.reviewsLabel}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              final star = 5 - i;
                              final frac = ratings.isEmpty
                                  ? 0.0
                                  : counts[i] / ratings.length;
                              return _buildDistributionBar(
                                  context, star, frac);
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reviews list
                  Container(
                    color: context.colors.surfaceColor,
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: ratings.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'No reviews yet.',
                                style: TextStyle(
                                    color: context.colors.textSecondary),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.passengerFeedback,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ...ratings.asMap().entries.map((entry) {
                                final i = entry.key;
                                final r = entry.value;
                                return Column(
                                  children: [
                                    if (i > 0)
                                      Divider(
                                          height: 32,
                                          color: context.colors.dividerColor),
                                    _buildReviewItem(context, r),
                                  ],
                                );
                              }),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDistributionBar(
      BuildContext context, int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              stars.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, color: context.colors.textSecondary, size: 10),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: context.colors.cardBackgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppStyles.primaryColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, RatingModel r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: context.colors.cardBackgroundColor,
              child: Text(
                r.passengerName.isNotEmpty
                    ? r.passengerName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.passengerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    _formatDate(r.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppStyles.starRatingLightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star,
                      color: AppStyles.starRatingColor, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    r.stars.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.starRatingDarkText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (r.comment.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            r.comment,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textDeep,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() > 1 ? 's' : ''} ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
