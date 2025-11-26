import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/projects/presentation/work_info_screen.dart';
import 'package:crm_app_dv/features/projects/presentation/works_create_page.dart';
import 'package:crm_app_dv/features/projects/presentation/widgets/work_actions_widget.dart';
import 'package:crm_app_dv/shared/widgets/modern_pagination_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkListPage extends StatelessWidget {
  final WorkController controller = Get.find<WorkController>();

  WorkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1926),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1926),
        title: const Text(
          "Proyectos",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: Colors.white),
            tooltip: 'Nuevo proyecto',
            onPressed: () => Get.to(() => const CreateWorkPage()),
          ),
        ],
      ),
      body: Column(
        children: [
         
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
               
                Expanded(
                  flex: 2,
                  child: Container(
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
                        hintText: 'Buscar proyecto...',
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
                ),
                
                const SizedBox(width: 12),
                
                
                Expanded(
                  flex: 2, 
                  child: Container(
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
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.filter_list, color: Color(0xFF10B981), size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
                              hint: Text(
                                'Estado',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
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
                                  value: '',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF6B7280),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Todos',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ...controller.workStatuses.map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            status,
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              ],
                              onChanged: controller.updateSelectedStatus,
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayedWorks = controller.filteredWorks;

              if (displayedWorks.isEmpty) {
                return Center(
                  child: Text(
                    controller.noWorkMessage.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: displayedWorks.length,
                itemBuilder: (context, index) {
                  final work = displayedWorks[index];
                  return _buildWorkCard(context, work);
                },
              );
            }),
          ),
          Obx(() {
            final hasSearch = controller.searchQuery.value.isNotEmpty;
            final hasStatus = controller.selectedStatus.value.isNotEmpty;
            if (hasSearch || hasStatus) {
              return const SizedBox.shrink();
            }
            return _buildPagination();
          }),
        ],
      ),
    );
  }


  Widget _buildWorkCard(BuildContext context, WorkModel work) {
    return Card(
      color: const Color(0xFF242038),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xFF4380FF)),
      ),
      child: InkWell(
        onTap: () {
          if (work.id != null && work.id!.isNotEmpty) {
            Get.to(() => WorkInfoScreen(workId: work.id!));
          } else {
            Get.snackbar("Error", "El ID del trabajo no es válido");
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
                  
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(work.statusWork),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.construction,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          work.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          work.customerName,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  WorkActionsWidget(
                    work: work,
                    onWorkUpdated: () => controller.refreshWorks(),
                    onWorkDeleted: () => controller.refreshWorks(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              
              Row(
                children: [
                  Icon(Icons.location_on_outlined, 
                    color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      work.address,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.attach_money_outlined, 
                    color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Presupuesto: \$${work.budget.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.category_outlined, 
                    color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 1,
                    child: Text(
                      work.projectType,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              
              Row(
                children: [
                  Flexible(
                    child: WorkStatusChip(
                      work: work,
                      onWorkUpdated: () => controller.refreshWorks(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (work.startDate.isNotEmpty) ...[
                    Icon(Icons.calendar_today_outlined, 
                      color: Colors.grey.shade400, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        work.startDate,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (work.id != null && work.id!.isNotEmpty) {
                          Get.to(() => WorkInfoScreen(workId: work.id!));
                        } else {
                          Get.snackbar("Error", "El ID del trabajo no es válido");
                        }
                      },
                      icon: const Icon(Icons.info_outline, size: 14),
                      label: const Text(
                        "Detalles",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade400,
                        side: BorderSide(color: Colors.blue.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendEmail(context, work.emailCustomer),
                      icon: const Icon(Icons.email_outlined, size: 14),
                      label: const Text(
                        "Email",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade400,
                        side: BorderSide(color: Colors.orange.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFF59E0B); 
      case 'activo':
      case 'en progreso':
      case 'en_progreso':
        return const Color(0xFF06B6D4); 
      case 'completado':
        return const Color(0xFF10B981); 
      case 'cancelado':
      case 'inactivo':
        return const Color(0xFFEF4444); 
      case 'pausado':
        return const Color(0xFF8B5CF6); 
      default:
        return const Color(0xFF6B7280); 
    }
  }

  Widget _buildPagination() {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(bottom: 20), 
      child: ModernPaginationWidget(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages.value,
        onPageChanged: (page) => controller.goToPage(page),
        isLoading: controller.isLoading.value,
      ),
    ));
  }
}

extension on WorkListPage {
  void _sendEmail(BuildContext context, String? email) async {
    final value = (email ?? '').trim();
    if (value.isEmpty || value.toLowerCase() == 'sin email') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir el correo'),
          content: const Text('Este proyecto no tiene un email válido.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
      return;
    }

    final gmailUri = Uri.parse('googlegmail://co?to=${Uri.encodeComponent(value)}');
    final mailtoUri = Uri(scheme: 'mailto', path: value);
    final gmailWebUri = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=${Uri.encodeComponent(value)}');

    try {
      if (await canLaunchUrl(gmailUri)) {
        final ok = await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        if (ok) return;
      }

      final okMail = await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      if (okMail) return;

      final okWeb = await launchUrl(gmailWebUri, mode: LaunchMode.externalApplication);
      if (okWeb) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir el correo'),
          content: Text('Dirección: $value'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir el correo'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    }
  }
}
