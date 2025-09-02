import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:crm_app_dv/features/projects/controllers/work_info_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkInfoScreen extends StatelessWidget {
  final String workId;
  WorkInfoScreen({required this.workId});

  @override
  Widget build(BuildContext context) {
    final WorkInfoController controller =
        Get.put(WorkInfoController(workRepository: Get.find()));
    controller.fetchWorkInfo(workId);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Detalles del Proyecto",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingWork.value) {
          return const Center(child: CircularProgressIndicator());
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          work.name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, thickness: 1),

                  // 🔹 **Información Detallada**
                  _buildInfoRow(Icons.numbers, "Número de Proyecto",
                      work.number ?? "No disponible"),
                  _buildInfoRow(
                      Icons.person, "Cliente", work.customerName),
                  _buildInfoRow(Icons.email, "Email del Cliente",
                      work.emailCustomer ?? "No disponible"),
                  _buildInfoRow(Icons.location_on, "Ubicación",
                      work.workUbication),

                  const SizedBox(height: 12),
                  _buildMapSection(context, work.workUbication),
                  _buildInfoRow(Icons.attach_money, "Presupuesto",
                      "\$${work.budget.toStringAsFixed(2)}"),
                  _buildInfoRow(Icons.assignment, "Estado", work.statusWork),
                  _buildInfoRow(Icons.category, "Tipo de Proyecto",
                      work.projectType),

                  // 📅 Fechas Formateadas
                  _buildInfoRow(Icons.calendar_today, "Fecha de Inicio",
                      _formatDate(work.startDate)),
                  if (work.endDate != null)
                    _buildInfoRow(
                        Icons.calendar_today, "Fecha de Finalización", _formatDate(work.endDate!)),

                  if (work.description != null)
                    _buildInfoRow(Icons.description, "Descripción",
                        work.description!),

                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, thickness: 1),

                  // 🔹 **Documentos Adjuntos**
                  if (work.documents.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text("📄 Documentos Adjuntos",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: work.documents
                          .map((doc) =>
                              _buildDocumentItem(doc))
                          .toList(),
                    ),
                  ] else ...[
                    _buildInfoRow(Icons.insert_drive_file, "Documentos",
                        "No hay documentos disponibles"),
                  ],

                  // 🔹 **Empleados en la Obra**
                  if (work.employeeInWork.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text("👷‍♂️ Empleados Asignados",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: work.employeeInWork
                          .map((emp) =>
                              _buildEmployeeItem(emp))
                          .toList(),
                    ),
                  ] else ...[
                    _buildInfoRow(Icons.person, "Empleados Asignados",
                        "No hay empleados en esta obra"),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // 📅 **Función para Formatear Fechas**
  String _formatDate(String dateStr) {
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  // 🔹 **Widget para Información General**
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 **Widget para Documentos**
  Widget _buildDocumentItem(String docName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              docName,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 **Widget para Empleados**
  Widget _buildEmployeeItem(String employee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              employee,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Sección de mapa con fallback a Google Maps
  Widget _buildMapSection(BuildContext context, String ubicacion) {
    final latLng = _parseLatLng(ubicacion);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final title = const Text(
              'Mapa de ubicación',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            );
            final btn = TextButton.icon(
              onPressed: () {
                if (latLng != null) {
                  _openGoogleMaps(context, lat: latLng.latitude, lng: latLng.longitude);
                } else {
                  _openGoogleMaps(context, query: ubicacion);
                }
              },
              icon: const Icon(Icons.map, color: Colors.orangeAccent, size: 18),
              label: const Text('Google Maps',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.orangeAccent)),
            );
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 6), btn],
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: title),
                  btn,
                ],
              );
            }
          },
        ),
        const SizedBox(height: 8),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4380FF).withOpacity(0.5)),
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
                            child: const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
                          ),
                        ],
                      ),
                    ],
                  )
                : _mapErrorPlaceholder(context, ubicacion),
          ),
        ),
      ],
    );
  }

  Widget _mapErrorPlaceholder(BuildContext context, String ubicacion) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, color: Colors.white54, size: 36),
            const SizedBox(height: 8),
            const Text(
              'No se pudo mostrar el mapa',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _openGoogleMaps(context, query: ubicacion),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text('Abrir en Google Maps'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
