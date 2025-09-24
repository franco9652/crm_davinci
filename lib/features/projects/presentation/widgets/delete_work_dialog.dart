import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';

/// Diálogo de confirmación para eliminar obra (Senior approach)
class DeleteWorkDialog extends StatefulWidget {
  final WorkModel work;
  
  const DeleteWorkDialog({
    super.key,
    required this.work,
  });

  @override
  State<DeleteWorkDialog> createState() => _DeleteWorkDialogState();
}

class _DeleteWorkDialogState extends State<DeleteWorkDialog> {
  final _controller = Get.find<WorkController>();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildTitle(),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  /// Título del diálogo (Senior approach)
  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade700.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Eliminar Obra',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Contenido del diálogo (Senior approach)
  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '¿Estás seguro de que deseas eliminar esta obra?',
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildWorkInfo(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade700.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.shade700.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.red.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esta acción no se puede deshacer. Todos los datos de la obra serán eliminados permanentemente.',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Información de la obra a eliminar (Senior approach)
  Widget _buildWorkInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade700,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.work.statusWork),
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
                  widget.work.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliente: ${widget.work.customerName}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Presupuesto: \$${widget.work.budget.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.work.statusWork),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.work.statusWork,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botones de acción (Senior approach)
  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: _isDeleting ? null : () => Get.back(result: false),
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        onPressed: _isDeleting ? null : _deleteWork,
        icon: _isDeleting 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.delete_forever, size: 18),
        label: Text(_isDeleting ? 'Eliminando...' : 'Eliminar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    ];
  }

  /// Eliminar obra (Senior approach)
  Future<void> _deleteWork() async {
    setState(() => _isDeleting = true);

    try {
      print('🗑️ Iniciando eliminación de obra: ${widget.work.name}');
      print('📋 Datos de la obra:');
      print('   - ID MongoDB: ${widget.work.id}');
      print('   - Number: ${widget.work.number}');
      print('   - Name: ${widget.work.name}');
      
      // Obtener el ID auto-increment para la eliminación
      final autoIncrementId = _controller.getWorkAutoIncrementId(widget.work);
      
      if (autoIncrementId == null || autoIncrementId.isEmpty) {
        print('❌ No se pudo obtener ID válido para eliminación');
        _showMessage('Error: No se pudo obtener el ID de la obra para eliminar.\nVerifica que la obra tenga un número válido.', isError: true);
        setState(() => _isDeleting = false);
        return;
      }

      print('🆔 ID para eliminación: $autoIncrementId');
      
      final success = await _controller.deleteWork(
        workAutoIncrementId: autoIncrementId,
        workMongoId: widget.work.id!,
      );
      
      if (success) {
        print('✅ Obra eliminada exitosamente');
        _showMessage('Obra eliminada exitosamente', isError: false);
        Get.back(result: true); // Indicar que se eliminó
      } else {
        print('❌ Error al eliminar obra - success = false');
        _showMessage('Error al eliminar obra', isError: true);
        if (mounted) setState(() => _isDeleting = false);
      }
    } catch (e) {
      print('❌ Excepción al eliminar obra: $e');
      _showMessage('Error inesperado: ${e.toString()}', isError: true);
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  /// Obtener color según el estado (Senior approach)
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

  /// Mostrar mensaje al usuario (Senior approach)
  void _showMessage(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}

/// Función helper para mostrar el diálogo (Senior approach)
class WorkDialogs {
  /// Mostrar diálogo de confirmación para eliminar obra
  static Future<bool> showDeleteConfirmation(WorkModel work) async {
    final result = await Get.dialog<bool>(
      DeleteWorkDialog(work: work),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Mostrar diálogo de información de la obra
  static void showWorkInfo(WorkModel work) {
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
              child: Text(
                work.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Cliente', work.customerName, Icons.person_outlined),
            _buildInfoRow('Dirección', work.address, Icons.location_on_outlined),
            _buildInfoRow('Presupuesto', '\$${work.budget.toStringAsFixed(2)}', Icons.attach_money_outlined),
            _buildInfoRow('Fecha Inicio', work.startDate, Icons.calendar_today_outlined),
            if (work.endDate?.isNotEmpty == true)
              _buildInfoRow('Fecha Fin', work.endDate!, Icons.event_outlined),
            _buildInfoRow('Tipo', work.projectType, Icons.category_outlined),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(work.statusWork),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                work.statusWork,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper para construir filas de información
  static Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener color según el estado
  static Color _getStatusColor(String status) {
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
