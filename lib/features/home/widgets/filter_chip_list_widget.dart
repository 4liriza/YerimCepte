import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class FilterChipListWidget extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChipListWidget({
    super.key, 
    required this.activeFilter, 
    required this.onFilterChanged
  });

  final List<String> filters = const [
    AppStrings.filterAll,
    AppStrings.filterEmpty,
    AppStrings.filterWithSocket,
    AppStrings.filterSilentArea,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filterName = filters[index];
          final isSelected = activeFilter == filterName;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.p8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filterName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.r20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filterName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
