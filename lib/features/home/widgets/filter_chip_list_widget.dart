import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class FilterChipListWidget extends StatefulWidget {
  const FilterChipListWidget({super.key});

  @override
  State<FilterChipListWidget> createState() => _FilterChipListWidgetState();
}

class _FilterChipListWidgetState extends State<FilterChipListWidget> {
  int _selectedIndex = 0;
  
  final List<String> filters = [
    AppStrings.filterAll,
    AppStrings.filterEmpty,
    AppStrings.filterWithSocket,
    AppStrings.filterSilentArea,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.p8),
            child: FilterChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
            ),
          );
        },
      ),
    );
  }
}
