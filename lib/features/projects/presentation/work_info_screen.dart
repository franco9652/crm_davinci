import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:crm_app_dv/features/projects/controllers/work_info_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm_app_dv/features/projects/presentation/widgets/work_actions_widget.dart';

class WorkInfoScreen extends StatelessWidget {
  final String workId;
  WorkInfoScreen({required this.workId});

  @override
  Widget build(BuildContext context) {
    final WorkInfoController controller =
        Get.put(WorkInfoController(workRepository: Get.find()));
    controller.fetchWorkInfo(workId);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Obx(() {
        if (controller.isLoadingWork.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        }

        if (controller.work.value == null) {
          return const Center(
            child: Text(
              "No se encontró el proyecto.",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          );
        }

        final work = controller.work.value!;
        return CustomScrollView(
          slivers: [
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
                                  Icons.apartment,
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
                                      work.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      work.customerName,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WorkActionsWidget(
                                work: work,
                                onWorkUpdated: () => controller.fetchWorkInfo(workId),
                                onWorkDeleted: () => Get.back(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
          
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildStatusCard(work),
                    const SizedBox(height: 20),
                    
                    
                    _buildInfoSection('Información del Proyecto', [
                      _buildModernInfoRow(Icons.numbers, 'Número', work.number ?? 'No disponible'),
                      _buildModernInfoRow(Icons.location_on, 'Ubicación', work.workUbication),
                      _buildModernInfoRow(Icons.category, 'Tipo', work.projectType),
                      _buildModernInfoRow(Icons.attach_money, 'Presupuesto', '\$${work.budget.toStringAsFixed(2)}'),
                    ]),
                    const SizedBox(height: 20),
                    
                   
                    _buildInfoSection('Cronograma', [
                      _buildModernInfoRow(Icons.calendar_today, 'Inicio', _formatDate(work.startDate)),
                      if (work.endDate != null)
                        _buildModernInfoRow(Icons.event_available, 'Finalización', _formatDate(work.endDate!)),
                    ]),
                    const SizedBox(height: 20),
                    
                   
                    _buildInfoSection('Contacto', [
                      _buildModernInfoRow(Icons.person, 'Cliente', work.customerName),
                      if (work.emailCustomer != null)
                        _buildModernInfoRow(Icons.email, 'Email', work.emailCustomer!),
                    ]),
                    const SizedBox(height: 20),
                    
               
                    if (work.description != null && work.description!.isNotEmpty)
                      _buildDescriptionSection(work.description!),
                    
                    
                    if (work.documents.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDocumentsSection(work.documents),
                    ],
                    
                   
                    if (work.employeeInWork.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildEmployeesSection(work.employeeInWork),
                    ],
                    
                    
                    const SizedBox(height: 20),
                    _buildMapSection(context, work.workUbication),
                    
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  
  String _formatDate(String dateStr) {
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  
  Widget _buildStatusCard(work) {
    Color statusColor;
    IconData statusIcon;
    
    switch (work.statusWork.toLowerCase()) {
      case 'activo':
      case 'en progreso':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.play_circle_filled;
        break;
      case 'pausado':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.pause_circle_filled;
        break;
      case 'inactivo':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.stop_circle;
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del Proyecto',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  work.statusWork,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

 
  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildDescriptionSection(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: Color(0xFF8B5CF6), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Descripción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDocumentsSection(List<String> documents) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, color: Color(0xFFF59E0B), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Documentos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...documents.map((doc) => _buildDocumentItem(doc)).toList(),
        ],
      ),
    );
  }


  Widget _buildDocumentItem(String docName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              docName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildEmployeesSection(List<String> employees) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.group, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Equipo Asignado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...employees.map((emp) => _buildEmployeeItem(emp)).toList(),
        ],
      ),
    );
  }


  Widget _buildEmployeeItem(String employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.person, color: Color(0xFF10B981), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              employee,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMapSection(BuildContext context, String ubicacion) {
    final latLng = _parseLatLng(ubicacion);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFF06B6D4), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ubicación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  if (latLng != null) {
                    _openGoogleMaps(context, lat: latLng.latitude, lng: latLng.longitude);
                  } else {
                    _openGoogleMaps(context, query: ubicacion);
                  }
                },
                icon: const Icon(Icons.open_in_new, color: Color(0xFF06B6D4), size: 14),
                label: const Text(
                  'Maps',
                  style: TextStyle(color: Color(0xFF06B6D4), fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: latLng != null
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: latLng,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'crm_app_dv',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: latLng,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Color(0xFF06B6D4), size: 36),
                            ),
                          ],
                        ),
                      ],
                    )
                  : _mapErrorPlaceholder(context, ubicacion),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapErrorPlaceholder(BuildContext context, String ubicacion) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_outlined, color: Color(0xFF06B6D4), size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudo mostrar el mapa',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openGoogleMaps(context, query: ubicacion),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text(
                'Google Maps',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng? _parseLatLng(String value) {
    try {
      if (value.isEmpty) return null;
      // Normalizar separadores y extraer numeros (admite "," o "." como decimal)
      final text = value.replaceAll(';', ',');
      final reg = RegExp(r'-?\d+[\.,]?\d*');
      final matches = reg
          .allMatches(text)
          .map((m) => m.group(0)!)
          .map((s) => s.replaceAll(',', '.'))
          .toList();
      if (matches.length < 2) return null;
      double? a = double.tryParse(matches[0]);
      double? b = double.tryParse(matches[1]);
      if (a == null || b == null) return null;
      double lat = a;
      double lng = b;
      // Si el primer valor no parece latitud pero el segundo sí, intercambiamos
      bool aIsLat = lat.abs() <= 90;
      bool bIsLng = lng.abs() <= 180;
      bool bIsLat = lng.abs() <= 90;
      bool aIsLng = lat.abs() <= 180;
      if ((!aIsLat && bIsLat) || (aIsLng && !bIsLng)) {
        final tmp = lat;
        lat = lng;
        lng = tmp;
      }
      if (lat.abs() > 90 || lng.abs() > 180) return null;
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openGoogleMaps(BuildContext context, {double? lat, double? lng, String? query}) async {
    try {
      Uri? uri;
      if (lat != null && lng != null) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      } else if (query != null && query.trim().isNotEmpty) {
        final q = Uri.encodeComponent(query);
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
      }

      if (uri == null) throw 'No hay datos de ubicación válidos';

      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        throw 'No se pudo abrir Google Maps';
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir el mapa'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    }
  }
}
