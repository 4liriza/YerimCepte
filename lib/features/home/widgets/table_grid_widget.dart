import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/session_manager.dart';

class TableGridWidget extends StatelessWidget {
  final Function(int, bool) onTableTap;

  const TableGridWidget({super.key, required this.onTableTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSizes.p12,
        mainAxisSpacing: AppSizes.p12,
        childAspectRatio: 1.0,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        int tableNum = index + 1;
        bool isMyTable = SessionManager().oturdugumMasa == 'Masa $tableNum';
        bool isFull = index < 4 || isMyTable; // Mock data logic

        Color getCardColor() {
          if (isMyTable) return AppColors.primary;
          if (isFull) return AppColors.error.withValues(alpha: 0.9);
          return AppColors.success.withValues(alpha: 0.9);
        }

        return InkWell(
          onTap: () => onTableTap(tableNum, isFull),
          borderRadius: BorderRadius.circular(AppSizes.r15),
          child: Container(
            decoration: BoxDecoration(
              color: getCardColor(),
              borderRadius: BorderRadius.circular(AppSizes.r15),
              boxShadow: [
                BoxShadow(
                  color: getCardColor().withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMyTable ? Icons.person : (isFull ? Icons.event_seat : Icons.event_seat_outlined),
                    color: Colors.white,
                    size: AppSizes.iconMedium,
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    'Masa $tableNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
