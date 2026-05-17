import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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

        return Container(
          height: rows * cellSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.r15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 2.0,
            child: SizedBox(
              width: (columns + 2) * cellSize,
              height: rows * cellSize,
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

                    return Positioned(
                      left: pos.dx * cellSize + (cellSize * 0.1),
                      top: pos.dy * cellSize + (cellSize * 0.1),
                      child: GestureDetector(
                        onTap: () => onTableTap(table),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: cellSize * 0.8,
                          height: cellSize * 0.8,
                          decoration: BoxDecoration(
                            color: isEffectivelyFull
                                ? AppColors.error
                                : AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              if (isHighlighted)
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isHighlighted
                                  ? Colors.yellow
                                  : Colors.white,
                              width: isHighlighted ? 3 : 1,
                            ),
                          ),
                          child: Center(
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
                                if (table.hasSocket)
                                  const Icon(
                                    Icons.power,
                                    color: Colors.white,
                                    size: 10,
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
        );
      },
    );
  }

  bool _checkHighlight(TableModel table) {
    if (activeFilter == "Prizli") return table.hasSocket;
    if (activeFilter == "Sessiz Alan") return table.isSilentArea;
    if (activeFilter == "Boş Masalar") return !table.isFull;
    return false;
  }
}
