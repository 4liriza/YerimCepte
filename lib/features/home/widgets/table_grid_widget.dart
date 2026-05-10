import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/session_manager.dart';

class TableGridWidget extends StatelessWidget {
  final Function(int, bool) onTableTap;
  final List<Map<String, dynamic>> tables;

  const TableGridWidget({
    super.key, 
    required this.onTableTap,
    required this.tables,
  });

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p24),
          child: Text("Bu filtreye uygun masa bulunamadı.", style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSizes.p12,
        mainAxisSpacing: AppSizes.p12,
        childAspectRatio: 1.0,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final int tableNum = table['id'];
        final bool isMyTable = SessionManager().oturdugumMasa == 'Masa $tableNum';
        final bool isFull = table['isFull'] || isMyTable;
        final bool isPassive = table['isPassive'] ?? false; // Filtreden geçemeyenler

        Color getCardColor() {
          if (isPassive) return Colors.grey.shade300;
          if (isMyTable) return AppColors.primary;
          if (isFull) return AppColors.error.withValues(alpha: 0.9);
          return AppColors.success.withValues(alpha: 0.9);
        }

        return InkWell(
          onTap: isPassive ? null : () => onTableTap(tableNum, isFull),
          borderRadius: BorderRadius.circular(AppSizes.r15),
          child: Container(
            decoration: BoxDecoration(
              color: getCardColor(),
              borderRadius: BorderRadius.circular(AppSizes.r15),
              boxShadow: isPassive ? [] : [
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
                    color: isPassive ? Colors.grey.shade500 : Colors.white,
                    size: AppSizes.iconMedium,
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    'Masa $tableNum',
                    style: TextStyle(
                      color: isPassive ? Colors.grey.shade500 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  // Priz ikonu
                  if (table['hasSocket'])
                    Icon(Icons.power, size: 12, color: isPassive ? Colors.transparent : Colors.white70),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
