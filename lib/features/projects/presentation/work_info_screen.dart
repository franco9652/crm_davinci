import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/projects/controllers/work_info_controller.dart';

class WorkInfoScreen extends StatelessWidget {
  final String workId;
  WorkInfoScreen({required this.workId});

  @override
  Widget build(BuildContext context) {
    final WorkInfoController controller = Get.put(WorkInfoController(workRepository: Get.find()));
    controller.fetchWorkInfo(workId);

    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text("Información del Proyecto"),
        backgroundColor: Color(0xFF16213E),
      ),
      body: Obx(() {
        if (controller.isLoadingWork.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.work.value == null) {
          return Center(
              child: Text("No se encontró el trabajo.",
                  style: TextStyle(color: Colors.white)));
        }

        final work = controller.work.value!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Color(0xFF0F3460),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.white, size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(work.name,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white54),
                  SizedBox(height: 8),
                  Text("📍 Dirección: ${work.address}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("💰 Presupuesto: \$${work.budget.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("📌 Estado: ${work.statusWork}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("🏗️ Tipo de Proyecto: ${work.projectType}",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1B98E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Ver más detalles", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
