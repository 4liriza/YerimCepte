import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/table_model.dart';

class LibraryMapWidget extends StatelessWidget {
  final List<TableModel> tables;
  final Function(TableModel) onTableTap;
  final String activeFilter;

  const LibraryMapWidget({
    super.key,
    required this.tables,
    required this.onTableTap,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    // Harita boyutlarını belirle (örn: 6x8 lik bir grid)
    const int columns = 6;
    const int rows = 8;

    // Masa ID'lerini grid koordinatlarına eşleyen basit bir mantık (Simülasyon)
    // Gerçek uygulamada bu veriler Firestore'dan gelmelidir.
    Map<int, Offset> tablePositions = {};
    for (var i = 0; i < tables.length; i++) {
      int tableId = tables[i].id;
      // Basit bir yerleşim algoritması: Kenarlara masaları diz, ortayı boş bırak (koridor)
      int col = (tableId - 1) % columns;
      int row = (tableId - 1) ~/ columns;

      // Koridor efekti için orta kolonu boşaltalım
      if (col >= 2 && col <= 3) {
        col += 2; // Sağa kaydır
      }
      tablePositions[tableId] = Offset(col.toDouble(), row.toDouble());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize = constraints.maxWidth / (columns + 2);
        final double mapWidth = (columns + 2) * cellSize;
        final double mapHeight = rows * cellSize;

        return Container(
          height: 400, // Fixed height or more flexible one
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.r15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.r15),
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 4.0,
              child: SizedBox(
                width: mapWidth,
                height: mapHeight,
                child: Stack(
                  children: [
                    // Zemin çizgileri (isteğe bağlı)
                    ...List.generate(
                      columns + 3,
                      (i) => Positioned(
                        left: i * cellSize,
                        top: 0,
                        bottom: 0,
                        child: VerticalDivider(
                          color: Colors.black.withValues(alpha: 0.03),
                          width: 1,
                        ),
                      ),
                    ),

                    // Masalar
                    ...tables.map((table) {
                      Offset? pos = tablePositions[table.id];
                      if (pos == null) return const SizedBox.shrink();

                      bool isHighlighted = _checkHighlight(table);
                      bool isEffectivelyFull = table.isFull;
                      if (table.nextReservationTime != null &&
                          DateTime.now().isAfter(table.nextReservationTime!)) {
                        isEffectivelyFull = true;
                      }

                      // Determine if the table matches the filter or if no filter is active
                      bool matchesFilter = activeFilter == AppStrings.filterAll || isHighlighted;

                      Color tableColor;
                      if (!matchesFilter) {
                        tableColor = Colors.grey.shade400;
                      } else {
                        tableColor = isEffectivelyFull ? AppColors.error : AppColors.success;
                      }

                      return Positioned(
                        left: pos.dx * cellSize + (cellSize * 0.1),
                        top: pos.dy * cellSize + (cellSize * 0.1),
                        child: GestureDetector(
                          onTap: matchesFilter ? () => onTableTap(table) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: cellSize * 0.8,
                            height: cellSize * 0.8,
                            decoration: BoxDecoration(
                              color: tableColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${table.id}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (table.hasSocket)
                                        const Icon(
                                          Icons.power,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      if (table.isSilentArea)
                                        const Icon(
                                          Icons.volume_off,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _checkHighlight(TableModel table) {
    if (activeFilter == AppStrings.filterWithSocket) return table.hasSocket;
    if (activeFilter == AppStrings.filterSilentArea) return table.isSilentArea;
    if (activeFilter == AppStrings.filterEmpty) return !table.isFull;
    return false;
  }
}
