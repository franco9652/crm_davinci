import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/meetings/controllers/meetings_controller.dart';
import 'package:crm_app_dv/features/meetings/presentation/create_meeting_screen.dart';
import 'package:intl/intl.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MeetingsController controller = Get.put(MeetingsController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Calendario / Reuniones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => controller.fetchMeetings(forCurrentUser: true),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${controller.error.value}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }
        if (controller.meetings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Aún no hay reuniones programadas. Usa el botón + para crear una.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchMeetings(forCurrentUser: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.meetings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final m = controller.meetings[i];
              final dateFmt = DateFormat('dd/MM/yyyy');
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    m.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${dateFmt.format(m.date)} • ${m.time} • ${m.duration} min',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (m.customerName != null)
                        Text('Cliente: ${m.customerName}', style: const TextStyle(color: Colors.white60)),
                      if (m.projectTitle != null)
                        Text('Proyecto: ${m.projectTitle}', style: const TextStyle(color: Colors.white60)),
                      Text('Tipo: ${m.meetingType}', style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                  onTap: () {
                    // Aquí podríamos navegar a detalle/editar en el futuro
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'createMeeting',
        backgroundColor: Colors.orange,
        onPressed: () {
          Get.to(() => const CreateMeetingScreen());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
