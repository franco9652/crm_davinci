import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/projects/presentation/edit_work_screen.dart';
import 'package:crm_app_dv/features/projects/presentation/widgets/delete_work_dialog.dart';

class WorkActionsWidget extends StatelessWidget {
  final WorkModel work;
  final VoidCallback? onWorkUpdated;
  final VoidCallback? onWorkDeleted;

  const WorkActionsWidget({
    super.key,
    required this.work,
    this.onWorkUpdated,
    this.onWorkDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<WorkAction>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (action) => _handleAction(action),
      itemBuilder: (context) => [
        _buildMenuItem(
          WorkAction.view,
          'Ver información',
          Icons.info_outline,
          Colors.blue.shade400,
        ),
        _buildMenuItem(
          WorkAction.edit,
          'Editar obra',
          Icons.edit_outlined,
          Colors.orange.shade400,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          WorkAction.delete,
          'Eliminar obra',
          Icons.delete_outline,
          Colors.red.shade400,
        ),
      ],
    );
  }

  PopupMenuItem<WorkAction> _buildMenuItem(
    WorkAction action,
    String title,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<WorkAction>(
      value: action,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(WorkAction action) async {
    switch (action) {
      case WorkAction.view:
        await _viewWork();
        break;
      case WorkAction.edit:
        await _editWork();
        break;
      case WorkAction.delete:
        await _deleteWork();
        break;
    }
  }

  Future<void> _viewWork() async {
    WorkDialogs.showWorkInfo(work);
  }

  Future<void> _editWork() async {
    final result = await Get.to<bool>(
      () => EditWorkScreen(work: work),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      onWorkUpdated?.call();
    }
  }

  Future<void> _deleteWork() async {
    final confirmed = await WorkDialogs.showDeleteConfirmation(work);
    
    if (confirmed) {
      onWorkDeleted?.call();
    }
  }
}

class WorkQuickActions extends StatelessWidget {
  final WorkModel work;
  final VoidCallback? onWorkUpdated;
  final VoidCallback? onWorkDeleted;

  const WorkQuickActions({
    super.key,
    required this.work,
    this.onWorkUpdated,
    this.onWorkDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.info_outline,
          color: Colors.blue.shade400,
          tooltip: 'Ver información',
          onPressed: _viewWork,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: Colors.orange.shade400,
          tooltip: 'Editar obra',
          onPressed: _editWork,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: Colors.red.shade400,
          tooltip: 'Eliminar obra',
          onPressed: _deleteWork,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _viewWork() async {
    WorkDialogs.showWorkInfo(work);
  }

  Future<void> _editWork() async {
    final result = await Get.to<bool>(
      () => EditWorkScreen(work: work),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      onWorkUpdated?.call();
    }
  }

  Future<void> _deleteWork() async {
    final confirmed = await WorkDialogs.showDeleteConfirmation(work);
    
    if (confirmed) {
      onWorkDeleted?.call();
    }
  }
}

class WorkFloatingActions extends StatelessWidget {
  final WorkModel work;
  final VoidCallback? onWorkUpdated;
  final VoidCallback? onWorkDeleted;

  const WorkFloatingActions({
    super.key,
    required this.work,
    this.onWorkUpdated,
    this.onWorkDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'edit_work_${work.id}',
          onPressed: _editWork,
          backgroundColor: Colors.orange.shade700,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'delete_work_${work.id}',
          onPressed: _deleteWork,
          backgroundColor: Colors.red.shade700,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
    );
  }

  Future<void> _editWork() async {
    final result = await Get.to<bool>(
      () => EditWorkScreen(work: work),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      onWorkUpdated?.call();
    }
  }

  Future<void> _deleteWork() async {
    final confirmed = await WorkDialogs.showDeleteConfirmation(work);
    
    if (confirmed) {
      onWorkDeleted?.call();
    }
  }
}

class WorkStatusChip extends StatelessWidget {
  final WorkModel work;
  final VoidCallback? onWorkUpdated;

  const WorkStatusChip({
    super.key,
    required this.work,
    this.onWorkUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStatusMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(work.statusWork),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(work.statusWork).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              work.statusWork,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    final statusOptions = ['activo', 'pausado', 'inactivo', 'En progreso'];
    
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: statusOptions.map((status) {
        return PopupMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: work.statusWork == status ? Colors.blue.shade400 : Colors.white,
                  fontWeight: work.statusWork == status ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedStatus) {
      if (selectedStatus != null && selectedStatus != work.statusWork) {
        _updateWorkStatus(selectedStatus);
      }
    });
  }

  Future<void> _updateWorkStatus(String newStatus) async {
    // Aquí implementarías la lógica para actualizar solo el estado
    // Por ahora, usaremos el método general de actualización
    final controller = Get.find<WorkController>();
    
    final success = await controller.updateWork(
      workId: work.id!,
      updateData: {'statusWork': newStatus},
    );

    if (success) {
      onWorkUpdated?.call();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
      case 'en progreso':
        return Colors.green.shade700;
      case 'pausado':
        return Colors.orange.shade700;
      case 'inactivo':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}

enum WorkAction {
  view,
  edit,
  delete,
}
