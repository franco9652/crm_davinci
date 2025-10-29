import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm_app_dv/models/meeting_model.dart';
import 'package:crm_app_dv/features/meetings/controllers/meetings_controller.dart';

class MeetingDetailScreen extends StatelessWidget {
  final MeetingModel meeting;
  const MeetingDetailScreen({super.key, required this.meeting});

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Link inválido', url);
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('No se pudo abrir el link', url);
    }
  }

  Future<void> _openMaps(BuildContext context, String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('No se pudo abrir Maps', address);
    }
  }

  

  Future<void> _sendSummaryToCustomer() async {
    final controller = Get.find<MeetingsController>();
    await controller.sendSummaryToCustomer(meeting);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
         
          SliverAppBar(
            expandedHeight: 120,
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
                                Icons.event_note,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalle de Reunión',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meeting.title,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
              
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _sendSummaryToCustomer,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
         
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildModernSection(
                    title: 'Información Básica',
                    icon: Icons.info_outline,
                    color: const Color(0xFF6366F1),
                    children: [
                      _buildModernInfoRow(
                        icon: Icons.title,
                        label: 'Título',
                        value: meeting.title,
                        color: const Color(0xFF8B5CF6),
                      ),
                      _buildModernInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Fecha',
                        value: _fmtDate(meeting.date),
                        color: const Color(0xFF8B5CF6),
                      ),
                      _buildModernInfoRow(
                        icon: Icons.access_time,
                        label: 'Hora',
                        value: meeting.time,
                        color: const Color(0xFFF59E0B),
                      ),
                      _buildModernInfoRow(
                        icon: Icons.timer,
                        label: 'Duración',
                        value: '${meeting.duration} min',
                        color: const Color(0xFFF59E0B),
                      ),
                      _buildModernInfoRow(
                        icon: meeting.meetingType == 'virtual' ? Icons.videocam : Icons.location_on,
                        label: 'Tipo',
                        value: meeting.meetingType,
                        color: meeting.meetingType == 'virtual' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                 
                  if (meeting.customerName != null && meeting.customerName!.isNotEmpty)
                    _buildModernSection(
                      title: 'Participantes',
                      icon: Icons.people_outline,
                      color: const Color(0xFF10B981),
                      children: [
                        _buildModernInfoRow(
                          icon: Icons.person,
                          label: 'Cliente',
                          value: meeting.customerName!,
                          color: const Color(0xFF10B981),
                        ),
                        if (meeting.projectTitle != null && meeting.projectTitle!.isNotEmpty)
                          _buildModernInfoRow(
                            icon: Icons.work_outline,
                            label: 'Proyecto',
                            value: meeting.projectTitle!,
                            color: const Color(0xFF06B6D4),
                          ),
                      ],
                    ),
                  
                  const SizedBox(height: 20),
                  
                 
                  if ((meeting.meetingType == 'virtual' && (meeting.meetingLink ?? '').isNotEmpty) ||
                      (meeting.meetingType == 'presencial' && (meeting.address ?? '').isNotEmpty))
                    _buildModernSection(
                      title: meeting.meetingType == 'virtual' ? 'Link de Reunión' : 'Ubicación',
                      icon: meeting.meetingType == 'virtual' ? Icons.link : Icons.location_on,
                      color: meeting.meetingType == 'virtual' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                      children: [
                        if (meeting.meetingType == 'virtual' && (meeting.meetingLink ?? '').isNotEmpty)
                          _buildModernInfoRow(
                            icon: Icons.videocam,
                            label: 'Link de reunión',
                            value: meeting.meetingLink!,
                            color: const Color(0xFF06B6D4),
                            isLink: true,
                            onTap: () => _openLink(context, meeting.meetingLink!),
                          ),
                        if (meeting.meetingType == 'presencial' && (meeting.address ?? '').isNotEmpty)
                          _buildModernInfoRow(
                            icon: Icons.location_on,
                            label: 'Dirección',
                            value: meeting.address!,
                            color: const Color(0xFF10B981),
                            isLink: true,
                            onTap: () => _openMaps(context, meeting.address!),
                          ),
                      ],
                    ),
                  
                  const SizedBox(height: 20),
                  
                 
                  if ((meeting.description ?? '').isNotEmpty)
                    _buildModernSection(
                      title: 'Descripción',
                      icon: Icons.description_outlined,
                      color: const Color(0xFFF59E0B),
                      children: [
                        _buildModernInfoRow(
                          icon: Icons.notes,
                          label: 'Descripción',
                          value: meeting.description!,
                          color: const Color(0xFFF59E0B),
                          isMultiline: true,
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 20),
                  
                 
                  _buildModernSection(
                    title: 'Información Técnica',
                    icon: Icons.settings_outlined,
                    color: const Color(0xFF6B7280),
                    children: [
                      _buildModernInfoRow(
                        icon: Icons.fingerprint,
                        label: 'ID',
                        value: meeting.id,
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLink = false,
    bool isMultiline = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isLink && onTap != null)
                  InkWell(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: isMultiline ? null : 2,
                      overflow: isMultiline ? null : TextOverflow.ellipsis,
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: isMultiline ? null : 2,
                    overflow: isMultiline ? null : TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isLink && onTap != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.open_in_new,
                color: color,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }
}
