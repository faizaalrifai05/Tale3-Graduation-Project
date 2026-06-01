import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtale3/theme/app_styles.dart';
import '../../providers/auth_provider.dart' as app_auth;
import 'package:testtale3/l10n/app_localizations.dart';

// ignore_for_file: use_build_context_synchronously

class ReportScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  final String reportedUserRole;
  final String rideId;
  final String origin;
  final String destination;

  const ReportScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportedUserRole,
    required this.rideId,
    required this.origin,
    required this.destination,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _db = FirebaseFirestore.instance;
  final _descriptionController = TextEditingController();
  String? _selectedReason;
  bool _isSubmitting = false;

  List<String> _getReasons(BuildContext context) => [
    context.l10n.reasonInappropriate,
    context.l10n.reasonNoShow,
    context.l10n.reasonUnsafeDriving,
    context.l10n.reasonHarassment,
    context.l10n.reasonScamFraud,
    context.l10n.reasonWrongVehicle,
    context.l10n.reasonRude,
    context.l10n.reasonOtherReport,
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.selectReasonError),
          backgroundColor: AppStyles.errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final auth = context.read<app_auth.AuthProvider>();
      final reporter = auth.currentUser;

      await _db.collection('reports').add({
        'reporterId': reporter?.uid ?? '',
        'reporterName': reporter?.name ?? '',
        'reporterRole': reporter?.role.name ?? '',
        'reportedUserId': widget.reportedUserId,
        'reportedUserName': widget.reportedUserName,
        'reportedUserRole': widget.reportedUserRole,
        'reason': _selectedReason,
        'description': _descriptionController.text.trim(),
        'rideId': widget.rideId,
        'origin': widget.origin,
        'destination': widget.destination,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 26),
              const SizedBox(width: 10),
              Text(
                context.l10n.reportSubmitted,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: const Text(
            'Your report has been submitted and will be reviewed by our team. '
            'Thank you for helping keep Tale3 safe.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to rating screen
              },
              child: Text(
                context.l10n.ok,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppStyles.primaryColor),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reportFailed),
          backgroundColor: AppStyles.errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.reportDriver,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Who you are reporting ──────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: context.colors.borderColor
                          .withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppStyles.primaryColor
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.reportedUserName.isNotEmpty
                                  ? widget.reportedUserName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppStyles.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reporting',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.textTertiary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.reportedUserName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              Text(
                                'Driver',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Trip route
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.colors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.route_rounded,
                              size: 16,
                              color: context.colors.textTertiary),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.origin} → ${widget.destination}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Reason ────────────────────────────────────────
              Text(
                context.l10n.whatHappened,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.selectReason,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getReasons(context).map((reason) {
                  final isSelected = _selectedReason == reason;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedReason = reason),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppStyles.primaryColor
                            : context.colors.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppStyles.primaryColor
                              : context.colors.borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : context.colors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Description ───────────────────────────────────
              Text(
                context.l10n.tellUsMore,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: context.l10n.describeWhatHappened,
                  hintStyle: TextStyle(
                      color: context.colors.inputHintColor,
                      fontSize: 14),
                  filled: true,
                  fillColor: context.colors.inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: context.colors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: context.colors.borderColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                        color: AppStyles.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Disclaimer ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: context.colors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reports are reviewed by our team within 24 hours. '
                        'False reports may result in action against your account.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.errorColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    disabledBackgroundColor:
                        context.colors.borderColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          context.l10n.reportDriver,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}