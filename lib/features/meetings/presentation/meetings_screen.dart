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
      backgroundColor: const Color(0xFF0F0F23),
      body: CustomScrollView(
        slivers: [
          // App Bar moderno con gradiente
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFF1E293B),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String>(
                                    future: _getPageTitle(),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? 'Calendario',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() => Text(
                                    controller.isFilterActive.value 
                                        ? 'Filtros aplicados'
                                        : 'Gestiona tus reuniones',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              _buildModernActionButton(
                Icons.filter_alt,
                'Filtros',
                () => _showModernFilterDialog(context, controller),
                controller.isFilterActive.value ? const Color(0xFFF59E0B) : Colors.white,
              ),
              _buildModernActionButton(
                Icons.refresh,
                'Refrescar',
                () => controller.fetchMeetings(forCurrentUser: true),
                Colors.white,
              ),
              _buildModernActionButton(
                Icons.notifications_active,
                'Test',
                () async {
                  await NotificationService.sendTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('🧪 Notificación de prueba programada'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          
          // Contenido principal
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Info banner para Employee
                _buildModernInfoBanner(),
                
                // 🔍 **Filtros Compactos Modernos**
                _buildCompactFilters(controller),
                
                // Lista de reuniones
                Obx(() {
                  if (controller.isLoading.value) {
                    return Container(
                      height: 200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      ),
                    );
                  }
                  if (controller.error.isNotEmpty) {
                    return _buildErrorState(controller.error.value);
                  }
                  return _buildModernMeetingsList(controller);
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildModernFAB(),
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

  // 🎨 **Botón de Acción Moderno**
  Widget _buildModernActionButton(IconData icon, String tooltip, VoidCallback onPressed, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  // 📋 **Banner de Información Moderno**
  Widget _buildModernInfoBanner() {
    return FutureBuilder<bool>(
      future: _shouldShowEmployeeBanner(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Mostrando solo las reuniones asignadas a ti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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

  // ❌ **Estado de Error Moderno**
  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar reuniones',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📅 **Lista de Reuniones Moderna**
  Widget _buildModernMeetingsList(MeetingsController controller) {
    final displayMeetings = controller.displayMeetings;
    
    if (displayMeetings.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.calendar_today, color: Color(0xFF6366F1), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay reuniones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay reuniones programadas.\nUsa el botón + para crear una.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchMeetings(forCurrentUser: true),
      color: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF1E293B),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: displayMeetings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final m = displayMeetings[i];
          final dateFmt = DateFormat('dd/MM/yyyy');
          return _buildModernMeetingCard(m, dateFmt);
        },
      ),
    );
  }

  // 🗓️ **Tarjeta de Reunión Moderna**
  Widget _buildModernMeetingCard(dynamic meeting, DateFormat dateFmt) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => MeetingDetailScreen(meeting: meeting)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event, color: Color(0xFF6366F1), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meeting.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF10B981),
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMeetingInfoRow(
                  Icons.calendar_today,
                  '${dateFmt.format(meeting.date)} • ${meeting.time}',
                  const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 8),
                _buildMeetingInfoRow(
                  Icons.schedule,
                  '${meeting.duration} minutos',
                  const Color(0xFFF59E0B),
                ),
                if (meeting.customerName != null) ...[
                  const SizedBox(height: 8),
                  _buildMeetingInfoRow(
                    Icons.person,
                    'Cliente: ${meeting.customerName}',
                    const Color(0xFF10B981),
                  ),
                ],
                if (meeting.projectTitle != null) ...[
                  const SizedBox(height: 8),
                  _buildMeetingInfoRow(
                    Icons.business,
                    'Proyecto: ${meeting.projectTitle}',
                    const Color(0xFF06B6D4),
                  ),
                ],
                const SizedBox(height: 8),
                _buildMeetingInfoRow(
                  Icons.category,
                  'Tipo: ${meeting.meetingType}',
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📝 **Fila de Información de Reunión**
  Widget _buildMeetingInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ➕ **FAB Moderno**
  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'createMeeting',
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Get.to(() => const CreateMeetingScreen()),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  
  void _showModernFilterDialog(BuildContext context, MeetingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.filter_alt, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Filtrar Reuniones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro por fecha específica
              Obx(() => _buildModernFilterOption(
                Icons.calendar_today,
                'Fecha específica',
                controller.selectedDate.value != null 
                    ? DateFormat('dd/MM/yyyy').format(controller.selectedDate.value!)
                    : 'Seleccionar fecha',
                const Color(0xFF8B5CF6),
                () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: const Color(0xFF6366F1),
                            surface: const Color(0xFF1E293B),
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
              )),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: const Color(0xFF334155),
              ),
              const SizedBox(height: 12),
              // Filtro por día de la semana
              Obx(() => _buildModernFilterOption(
                Icons.today,
                'Día de la semana',
                controller.selectedDay.value ?? 'Seleccionar día',
                const Color(0xFF10B981),
                () => _showModernDayPicker(context, controller),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Get.back();
            },
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎛️ **Opción de Filtro Moderna**
  Widget _buildModernFilterOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📅 **Selector de Día Moderno**
  void _showModernDayPicker(BuildContext context, MeetingsController controller) {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.today, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Seleccionar Día',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300, // Altura fija para evitar overflow
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: days.map((day) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.filterByDay(day);
                      Get.back(); // Cerrar selector de día
                      Get.back(); // Cerrar diálogo de filtros
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.calendar_today, color: Color(0xFF10B981), size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔍 **Filtros Compactos Modernos**
  Widget _buildCompactFilters(MeetingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Primera fila: Buscador
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar reuniones...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.search, color: Color(0xFF6366F1), size: 16),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Segunda fila: Filtros por tipo y estado
          Row(
            children: [
              // Filtro por tipo
              Expanded(
                child: _buildCompactDropdown(
                  label: 'Tipo',
                  icon: Icons.videocam,
                  value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
                  items: controller.meetingTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == 'virtual' ? Icons.videocam : Icons.location_on,
                          color: type == 'virtual' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(type == 'virtual' ? 'Virtual' : 'Presencial'),
                      ],
                    ),
                  )).toList(),
                  onChanged: controller.filterByType,
                  color: const Color(0xFF06B6D4),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filtro por estado
              Expanded(
                child: _buildCompactDropdown(
                  label: 'Estado',
                  icon: Icons.schedule,
                  value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
                  items: controller.meetingStatuses.map((status) => DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusDisplayName(status)),
                      ],
                    ),
                  )).toList(),
                  onChanged: controller.filterByStatus,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          
          // Botón limpiar filtros (solo si hay filtros activos)
          Obx(() => controller.isFilterActive.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: TextButton.icon(
                      onPressed: controller.clearFilters,
                      icon: const Icon(Icons.clear_all, size: 16, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Limpiar Filtros',
                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // 📋 **Dropdown Compacto**
  Widget _buildCompactDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required Color color,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                menuMaxHeight: 300,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B7280),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Todos', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  ...items,
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 **Helpers para iconos y colores de estado**
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'próxima':
        return Icons.schedule;
      case 'en curso':
        return Icons.play_circle;
      case 'finalizada':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'próxima':
        return const Color(0xFF06B6D4);
      case 'en curso':
        return const Color(0xFFF59E0B);
      case 'finalizada':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'próxima':
        return 'Próxima';
      case 'en curso':
        return 'En Curso';
      case 'finalizada':
        return 'Finalizada';
      default:
        return status;
    }
  }
}
