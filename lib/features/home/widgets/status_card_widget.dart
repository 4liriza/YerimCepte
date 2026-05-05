import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class StatusCardWidget extends StatelessWidget {
  final bool isAtTable;
  final String? tableName;
  final VoidCallback onManageTap;

  const StatusCardWidget({
    super.key,
    required this.isAtTable,
    this.tableName,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.r30),
          bottomRight: Radius.circular(AppSizes.r30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x334F46E5), // Soft indigo shadow
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${AppStrings.welcomePrefix}, Enes 👋",
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          if (isAtTable)
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Glassmorphism
                borderRadius: BorderRadius.circular(AppSizes.r15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: const Icon(Icons.event_seat, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Text(
                      "$tableName ${AppStrings.tableReservedSuffix}",
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onManageTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                    ),
                    child: const Text(AppStrings.manageButtonText),
                  )
                ],
              ),
            )
          else
            const Text(
              AppStrings.noTableMessage,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
