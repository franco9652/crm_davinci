import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/meetings/controllers/meetings_controller.dart';
import 'package:crm_app_dv/features/meetings/presentation/create_meeting_screen.dart';
import 'package:intl/intl.dart';
import 'package:crm_app_dv/features/meetings/presentation/meeting_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app_dv/core/services/notification_service.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MeetingsController controller = Get.put(MeetingsController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getPageTitle(),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Calendario / Reuniones',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Filtros',
            onPressed: () => _showFilterDialog(context, controller),
            icon: Obx(() => Icon(
              controller.isFilterActive.value ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: controller.isFilterActive.value ? Colors.orange : Colors.white,
            )),
          ),
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => controller.fetchMeetings(forCurrentUser: true),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          // Botón temporal para probar notificaciones
          IconButton(
            tooltip: 'Probar notificación',
            onPressed: () async {
              await NotificationService.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🧪 Notificación de prueba programada para 10 segundos'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            icon: const Icon(Icons.notifications_active, color: Colors.yellow),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner para Employee
          _buildInfoBanner(),
          Expanded(
            child: Obx(() {
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
              return _buildMeetingsList(controller);
            }),
          ),
        ],
      ),
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

  Future<String> _getPageTitle() async {
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('user_role') ?? '').trim();
    
    switch (role) {
      case 'Admin':
        return 'Todas las Reuniones';
      case 'Employee':
        return 'Mis Reuniones Asignadas';
      default:
        return 'Calendario / Reuniones';
    }
  }

  Widget _buildInfoBanner() {
    return FutureBuilder<bool>(
      future: _shouldShowEmployeeBanner(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📋 Mostrando solo las reuniones asignadas a ti',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<bool> _shouldShowEmployeeBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('user_role') ?? '').trim();
    return role == 'Employee';
  }

  Widget _buildMeetingsList(MeetingsController controller) {
    final displayMeetings = controller.displayMeetings;
    
    if (displayMeetings.isEmpty) {
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
        itemCount: displayMeetings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final m = displayMeetings[i];
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
                Get.to(() => MeetingDetailScreen(meeting: m));
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, MeetingsController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Filtrar Reuniones', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por fecha específica
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.white70),
                title: const Text('Fecha específica', style: TextStyle(color: Colors.white)),
                subtitle: Obx(() => Text(
                  controller.selectedDate.value != null 
                    ? DateFormat('dd/MM/yyyy').format(controller.selectedDate.value!)
                    : 'Seleccionar fecha',
                  style: const TextStyle(color: Colors.white60),
                )),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.orange,
                            surface: Color(0xFF1E293B),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    controller.filterByDate(date);
                  }
                },
              ),
              const Divider(color: Colors.white24),
              // Filtro por día de la semana
              ListTile(
                leading: const Icon(Icons.today, color: Colors.white70),
                title: const Text('Día de la semana', style: TextStyle(color: Colors.white)),
                subtitle: Obx(() => Text(
                  controller.selectedDay.value ?? 'Seleccionar día',
                  style: const TextStyle(color: Colors.white60),
                )),
                onTap: () => _showDayPicker(context, controller),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Limpiar', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  void _showDayPicker(BuildContext context, MeetingsController controller) {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Seleccionar Día', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: days.map((day) => ListTile(
              title: Text(day, style: const TextStyle(color: Colors.white)),
              onTap: () {
                controller.filterByDay(day);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Cerrar también el diálogo de filtros
              },
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }
}
