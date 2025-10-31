import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';


class DeleteCustomerDialog extends StatefulWidget {
  final CustomerModel customer;
  
  const DeleteCustomerDialog({
    super.key,
    required this.customer,
  });

  @override
  State<DeleteCustomerDialog> createState() => _DeleteCustomerDialogState();
}

class _DeleteCustomerDialogState extends State<DeleteCustomerDialog> {
  final _controller = Get.find<HomeController>();
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
            'Eliminar Cliente',
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

  
  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '¿Estás seguro de que deseas eliminar este cliente?',
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomerInfo(),
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
                  'Esta acción no se puede deshacer. Todos los datos del cliente serán eliminados permanentemente.',
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

  
  Widget _buildCustomerInfo() {
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
          CircleAvatar(
            backgroundColor: Colors.blue.shade700,
            radius: 20,
            child: Text(
              widget.customer.name.isNotEmpty 
                ? widget.customer.name[0].toUpperCase()
                : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.customer.email,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.customer.contactNumber,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
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
        onPressed: _isDeleting ? null : _deleteCustomer,
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

 
  Future<void> _deleteCustomer() async {
    setState(() => _isDeleting = true);

    try {
      print('🗑️ Iniciando eliminación de cliente: ${widget.customer.name}');
      print('📋 ID del cliente: ${widget.customer.id}');
      
      final success = await _controller.deleteCustomer(widget.customer.id!);
      
      print('🎯 Resultado de eliminación: $success');
      
    
      
      if (success) {
        print('✅ Cliente eliminado exitosamente, cerrando diálogo FORZADAMENTE');
      } else {
        print('⚠️ Success = false, pero cerrando diálogo de todas formas');
      }
      
      
      if (mounted) {
        Navigator.of(context).pop(true); 
        print('🚪 Diálogo cerrado con Navigator.pop()');
      }
      
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (success) {
          _showMessage('Cliente eliminado exitosamente', isError: false);
        } else {
          _showMessage('Cliente eliminado pero con advertencias', isError: false);
        }
      });
    } catch (e) {
      print('❌ Excepción al eliminar cliente: $e');
      _showMessage('Error inesperado: ${e.toString()}', isError: true);
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  
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


class CustomerDialogs {
  
  static Future<bool> showDeleteConfirmation(CustomerModel customer) async {
    final result = await Get.dialog<bool>(
      DeleteCustomerDialog(customer: customer),
      barrierDismissible: false,
    );
    return result ?? false;
  }

 
  static void showCustomerInfo(CustomerModel customer) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 20,
              child: Text(
                customer.name.isNotEmpty 
                  ? customer.name[0].toUpperCase()
                  : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customer.name,
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
            _buildInfoRow('Email', customer.email, Icons.email_outlined),
            _buildInfoRow('Teléfono', customer.contactNumber, Icons.phone_outlined),
            if (customer.address?.isNotEmpty == true)
              _buildInfoRow('Dirección', customer.address!, Icons.home_outlined),
            if (customer.dni?.isNotEmpty == true)
              _buildInfoRow('DNI', customer.dni!, Icons.badge_outlined),
            if (customer.cuit?.isNotEmpty == true)
              _buildInfoRow('CUIT', customer.cuit!, Icons.business_outlined),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (customer.active ?? true) ? Colors.green.shade700 : Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (customer.active ?? true) ? 'Activo' : 'Inactivo',
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
}
