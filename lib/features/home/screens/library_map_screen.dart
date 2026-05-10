import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/table_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/session_manager.dart';
import '../widgets/library_map_widget.dart';
import '../widgets/filter_chip_list_widget.dart';

class LibraryMapScreen extends StatefulWidget {
  const LibraryMapScreen({super.key});

  @override
  State<LibraryMapScreen> createState() => _LibraryMapScreenState();
}

class _LibraryMapScreenState extends State<LibraryMapScreen> {
  String _activeFilter = AppStrings.filterAll;
  final FirestoreService _firestoreService = FirestoreService();

  void _onTableTap(int tableNumber, bool isFull) {
    if (isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu masa dolu.'), backgroundColor: AppColors.error),
      );
    } else {
      _showReservationDialog(tableNumber);
    }
  }

  void _showReservationDialog(int tableNumber) {
    showDialog(
      context: context,
      builder: (context) {
        TimeOfDay selectedTime = TimeOfDay.now();
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Masa $tableNumber Rezerve Et', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kütüphaneye ne zaman geleceksiniz? Geldiğinizde QR okutmayı unutmayın."),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Seçilen Saat: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setStateDialog(() => selectedTime = time);
                          }
                        },
                        child: Text(selectedTime.format(context), style: const TextStyle(fontSize: 18, color: AppColors.primary)),
                      ),
                    ],
                  )
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r15)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancelButton, style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    DateTime startTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                    if (startTime.isBefore(now)) {
                      startTime = startTime.add(const Duration(days: 1));
                    }
                    
                    await SessionManager().rezerveEt(tableNumber, startTime);
                    
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rezervasyon başarıyla oluşturuldu!")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                  ),
                  child: const Text("Rezerve Et"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kütüphane Yerleşimi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showMapInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSizes.p8),
          FilterChipListWidget(
            activeFilter: _activeFilter,
            onFilterChanged: (filter) => setState(() => _activeFilter = filter),
          ),
          const SizedBox(height: AppSizes.p16),
          Expanded(
            child: StreamBuilder<List<TableModel>>(
              stream: _firestoreService.getTables(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                final tables = snapshot.data ?? [];
                return LibraryMapWidget(
                  tables: tables,
                  onTableTap: _onTableTap,
                  activeFilter: _activeFilter,
                );
              }
            ),
          ),
          const SizedBox(height: AppSizes.p16),
        ],
      ),
    );
  }

  void _showMapInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Harita Kullanımı"),
        content: const Text("Haritayı kaydırmak için sürükleyin, masalara dokunarak rezervasyon yapın.\n\nYeşil: Boş\nKırmızı: Dolu"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Anladım"))],
      ),
    );
  }
}
