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

  // Lógica de negocio movida a MeetingsController

  Future<void> _sendSummaryToCustomer() async {
    final controller = Get.find<MeetingsController>();
    await controller.sendSummaryToCustomer(meeting);
  }

  @override
  Widget build(BuildContext context) {
    final items = <_DetailItem>[
      _DetailItem('Título', meeting.title),
      _DetailItem('Fecha', _fmtDate(meeting.date)),
      _DetailItem('Hora', meeting.time),
      _DetailItem('Duración', '${meeting.duration} min'),
      _DetailItem('Tipo', meeting.meetingType),
      if (meeting.customerName != null && meeting.customerName!.isNotEmpty)
        _DetailItem('Cliente', meeting.customerName!),
      if (meeting.projectTitle != null && meeting.projectTitle!.isNotEmpty)
        _DetailItem('Proyecto', meeting.projectTitle!),
      if (meeting.meetingType == 'virtual' && (meeting.meetingLink ?? '').isNotEmpty)
        _DetailItem('Link de reunión', meeting.meetingLink!, isLink: true, onTap: () => _openLink(context, meeting.meetingLink!)),
      if (meeting.meetingType == 'presencial' && (meeting.address ?? '').isNotEmpty)
        _DetailItem('Dirección', meeting.address!, isLink: true, onTap: () => _openMaps(context, meeting.address!)),
      if ((meeting.description ?? '').isNotEmpty)
        _DetailItem('Descripción', meeting.description!),
      _DetailItem('ID', meeting.id),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Detalle de reunión', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Enviar resumen al cliente',
            onPressed: _sendSummaryToCustomer,
            icon: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final it = items[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                if (it.onTap != null || it.isLink)
                  InkWell(
                    onTap: it.onTap,
                    child: Text(
                      it.value,
                      style: const TextStyle(color: Colors.lightBlueAccent, decoration: TextDecoration.underline),
                    ),
                  )
                else
                  Text(it.value, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;
  _DetailItem(this.label, this.value, {this.isLink = false, this.onTap});
}
