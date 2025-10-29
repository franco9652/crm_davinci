import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/meetings/controllers/meetings_controller.dart';
import 'package:crm_app_dv/features/meetings/presentation/create_meeting_screen.dart';
import 'package:crm_app_dv/features/meetings/presentation/meeting_detail_screen.dart';
import 'package:crm_app_dv/shared/widgets/modern_pagination_widget.dart';
import 'package:intl/intl.dart';

class MeetingsListPage extends StatelessWidget {
  const MeetingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MeetingsController controller = Get.put(MeetingsController());
    
    return Scaffold(
      backgroundColor: const Color(0xFF1B1926),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1926),
        title: const Text(
          "Reuniones",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
               
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
          ),
          
        
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayedMeetings = controller.displayMeetings;

              if (displayedMeetings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.isFilterActive.value 
                            ? 'No hay reuniones que coincidan con los filtros'
                            : 'No hay reuniones programadas',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayedMeetings.length,
                      itemBuilder: (context, index) {
                        final meeting = displayedMeetings[index];
                        return _buildMeetingCard(context, meeting);
                      },
                    ),
                  ),
                  
                  Obx(() => ModernPaginationWidget(
                    currentPage: controller.currentPage.value,
                    totalPages: controller.totalPages,
                    onPageChanged: (page) => controller.goToPage(page),
                    isLoading: controller.isLoading.value,
                  )),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  
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

  
  Widget _buildMeetingCard(BuildContext context, meeting) {
    final now = DateTime.now();
    final meetingDate = meeting.date;
    final isToday = meetingDate.year == now.year && 
                   meetingDate.month == now.month && 
                   meetingDate.day == now.day;
    
    return Card(
      color: const Color(0xFF242038),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday ? const Color(0xFF6366F1) : const Color(0xFF4380FF),
          width: isToday ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => Get.to(() => MeetingDetailScreen(meeting: meeting)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMeetingStatusColor(meeting).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getMeetingStatusColor(meeting).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMeetingStatusIcon(meeting),
                          color: _getMeetingStatusColor(meeting),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getMeetingStatusText(meeting),
                          style: TextStyle(
                            color: _getMeetingStatusColor(meeting),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
             
              Row(
                children: [
               
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(meetingDate),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          meeting.time,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              
              Row(
                children: [
                  Icon(
                    meeting.meetingType == 'virtual' ? Icons.videocam : Icons.location_on,
                    color: meeting.meetingType == 'virtual' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    meeting.meetingType == 'virtual' ? 'Virtual' : 'Presencial',
                    style: TextStyle(
                      color: meeting.meetingType == 'virtual' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${meeting.duration} min',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              
              if (meeting.customerName != null && meeting.customerName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      meeting.customerName!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

 
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

 
  Color _getMeetingStatusColor(meeting) {
    try {
      final timeParts = meeting.time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final meetingDateTime = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day,
        hour,
        minute,
      );
      
      final durationMinutes = int.tryParse(meeting.duration) ?? 60;
      final endTime = meetingDateTime.add(Duration(minutes: durationMinutes));
      final now = DateTime.now();
      
      if (meetingDateTime.isAfter(now)) {
        return const Color(0xFF06B6D4); 
      } else if (meetingDateTime.isBefore(now) && endTime.isAfter(now)) {
        return const Color(0xFFF59E0B); 
      } else {
        return const Color(0xFF10B981); 
      }
    } catch (e) {
      return const Color(0xFF6B7280); 
    }
  }

  IconData _getMeetingStatusIcon(meeting) {
    try {
      final timeParts = meeting.time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final meetingDateTime = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day,
        hour,
        minute,
      );
      
      final durationMinutes = int.tryParse(meeting.duration) ?? 60;
      final endTime = meetingDateTime.add(Duration(minutes: durationMinutes));
      final now = DateTime.now();
      
      if (meetingDateTime.isAfter(now)) {
        return Icons.schedule; 
      } else if (meetingDateTime.isBefore(now) && endTime.isAfter(now)) {
        return Icons.play_circle; 
      } else {
        return Icons.check_circle; 
      }
    } catch (e) {
      return Icons.help_outline; 
    }
  }

  String _getMeetingStatusText(meeting) {
    try {
      final timeParts = meeting.time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final meetingDateTime = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day,
        hour,
        minute,
      );
      
      final durationMinutes = int.tryParse(meeting.duration) ?? 60;
      final endTime = meetingDateTime.add(Duration(minutes: durationMinutes));
      final now = DateTime.now();
      
      if (meetingDateTime.isAfter(now)) {
        return 'Próxima';
      } else if (meetingDateTime.isBefore(now) && endTime.isAfter(now)) {
        return 'En Curso';
      } else {
        return 'Finalizada';
      }
    } catch (e) {
      return 'Error';
    }
  }
}
