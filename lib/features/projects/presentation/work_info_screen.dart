import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:crm_app_dv/features/projects/controllers/work_info_controller.dart';

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
}
