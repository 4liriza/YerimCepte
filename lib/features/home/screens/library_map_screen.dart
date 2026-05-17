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

  void _onTableTap(TableModel table) async {
    final session = SessionManager();
    final user = session.currentUser;
    if (user == null) return;

    // Admin check: fetch user data to check isAdmin
    final userModel = await _firestoreService.getUser(user.uid);
    if (userModel?.isAdmin == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yöneticiler rezervasyon yapamaz.')),
        );
      }
      return;
    }

    bool isEffectivelyFull = table.isFull;
    if (table.nextReservationTime != null && DateTime.now().isAfter(table.nextReservationTime!)) {
      isEffectivelyFull = true;
    }

    if (isEffectivelyFull) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu masa dolu.'), backgroundColor: AppColors.error),
        );
      }
    } else {
      if (session.activeTableId != null || session.reservationStartTime != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Zaten aktif bir masanız veya rezervasyonunuz var.'), 
              backgroundColor: AppColors.error
            ),
          );
        }
        return;
      }
      _showReservationDialog(table);
    }
  }

  void _showReservationDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        TimeOfDay selectedStartTime = TimeOfDay.now();
        TimeOfDay selectedEndTime = TimeOfDay(hour: (selectedStartTime.hour + 1) % 24, minute: selectedStartTime.minute);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Masa ${table.id} Rezerve Et', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (table.futureReservations.isNotEmpty) ...[
                      const Text(
                        "Mevcut Rezervasyonlar:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      ...table.futureReservations.map((res) {
                        final start = res['startTime'] as DateTime;
                        final end = res['endTime'] as DateTime;
                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                          child: Text(
                            "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    const Text("Kütüphaneye ne zaman geleceksiniz ve ne zaman ayrılacaksınız? Geldiğinizde QR okutmayı unutmayın."),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Başlangıç Saati: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedStartTime,
                            );
                            if (time != null) {
                              setStateDialog(() => selectedStartTime = time);
                            }
                          },
                          child: Text(selectedStartTime.format(context), style: const TextStyle(fontSize: 16, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Bitiş Saati: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: selectedEndTime,
                            );
                            if (time != null) {
                              setStateDialog(() => selectedEndTime = time);
                            }
                          },
                          child: Text(selectedEndTime.format(context), style: const TextStyle(fontSize: 16, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
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
                    final nowWithoutSeconds = DateTime(now.year, now.month, now.day, now.hour, now.minute);
                    DateTime startTime = DateTime(now.year, now.month, now.day, selectedStartTime.hour, selectedStartTime.minute);
                    DateTime endTime = DateTime(now.year, now.month, now.day, selectedEndTime.hour, selectedEndTime.minute);
                    
                    if (startTime.isBefore(nowWithoutSeconds)) {
                      startTime = startTime.add(const Duration(days: 1));
                    }
                    if (endTime.isBefore(startTime)) {
                      endTime = endTime.add(const Duration(days: 1));
                    }

                    // Validation against existing reservations
                    bool hasConflict = false;
                    for (var res in table.futureReservations) {
                      final resStart = res['startTime'] as DateTime;
                      final resEnd = res['endTime'] as DateTime;

                      // Condition for NO conflict:
                      // newEnd <= resStart - 10 mins  OR  newStart >= resEnd + 10 mins
                      final validBefore = endTime.isBefore(resStart.subtract(const Duration(minutes: 9))); // using 9 to be safe with <=
                      final validAfter = startTime.isAfter(resEnd.add(const Duration(minutes: 9)));
                      
                      if (!(validBefore || validAfter) || 
                          endTime.isAtSameMomentAs(resStart.subtract(const Duration(minutes: 10))) == false && endTime.isAfter(resStart.subtract(const Duration(minutes: 10))) && startTime.isBefore(resEnd.add(const Duration(minutes: 10)))) {
                         // A more exact check:
                         final minRequiredEnd = resStart.subtract(const Duration(minutes: 10));
                         final minRequiredStart = resEnd.add(const Duration(minutes: 10));
                         
                         if (endTime.isAfter(minRequiredEnd) && startTime.isBefore(minRequiredStart)) {
                           hasConflict = true;
                           break;
                         }
                      }
                    }

                    if (hasConflict) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Seçtiğiniz saat aralığı diğer rezervasyonlarla (10 dk aralık kuralı) çakışıyor!"),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    await SessionManager().rezerveEt(table.id, startTime, endTime);
                    
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
