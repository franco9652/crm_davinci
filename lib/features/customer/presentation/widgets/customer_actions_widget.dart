import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/features/customer/presentation/edit_customer_screen.dart';
import 'package:crm_app_dv/features/customer/presentation/widgets/delete_customer_dialog.dart';
import 'package:crm_app_dv/features/customer/presentation/customer_info_screen.dart';


class CustomerActionsWidget extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onCustomerUpdated;
  final VoidCallback? onCustomerDeleted;

  const CustomerActionsWidget({
    super.key,
    required this.customer,
    this.onCustomerUpdated,
    this.onCustomerDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CustomerAction>(
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
          CustomerAction.view,
          'Ver información',
          Icons.info_outline,
          Colors.blue.shade400,
        ),
        _buildMenuItem(
          CustomerAction.edit,
          'Editar cliente',
          Icons.edit_outlined,
          Colors.orange.shade400,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          CustomerAction.delete,
          'Eliminar cliente',
          Icons.delete_outline,
          Colors.red.shade400,
        ),
      ],
    );
  }

  
  PopupMenuItem<CustomerAction> _buildMenuItem(
    CustomerAction action,
    String title,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<CustomerAction>(
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

  
  Future<void> _handleAction(CustomerAction action) async {
    switch (action) {
      case CustomerAction.view:
        await _viewCustomer();
        break;
      case CustomerAction.edit:
        await _editCustomer();
        break;
      case CustomerAction.delete:
        await _deleteCustomer();
        break;
    }
  }

  
  Future<void> _viewCustomer() async {
    if (customer.userId?.isNotEmpty == true) {
      Get.to(() => CustomerInfoScreen(userId: customer.userId!));
    } else {
      CustomerDialogs.showCustomerInfo(customer);
    }
  }

  Future<void> _editCustomer() async {
    final result = await Get.to<bool>(
      () => EditCustomerScreen(customer: customer),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      onCustomerUpdated?.call();
    }
  }


  Future<void> _deleteCustomer() async {
    final confirmed = await CustomerDialogs.showDeleteConfirmation(customer);
    
    if (confirmed) {
      onCustomerDeleted?.call();
    }
  }
}

class CustomerQuickActions extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onCustomerUpdated;
  final VoidCallback? onCustomerDeleted;

  const CustomerQuickActions({
    super.key,
    required this.customer,
    this.onCustomerUpdated,
    this.onCustomerDeleted,
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
          onPressed: _viewCustomer,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: Colors.orange.shade400,
          tooltip: 'Editar cliente',
          onPressed: _editCustomer,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: Colors.red.shade400,
          tooltip: 'Eliminar cliente',
          onPressed: _deleteCustomer,
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

  
  Future<void> _viewCustomer() async {
    if (customer.userId?.isNotEmpty == true) {
      Get.to(() => CustomerInfoScreen(userId: customer.userId!));
    } else {
      CustomerDialogs.showCustomerInfo(customer);
    }
  }

 
  Future<void> _editCustomer() async {
    final result = await Get.to<bool>(
      () => EditCustomerScreen(customer: customer),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      onCustomerUpdated?.call();
    }
  }

 
  Future<void> _deleteCustomer() async {
    final confirmed = await CustomerDialogs.showDeleteConfirmation(customer);
    
    if (confirmed) {
      onCustomerDeleted?.call();
    }
  }
}


class CustomerFloatingActions extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onCustomerUpdated;
  final VoidCallback? onCustomerDeleted;

  const CustomerFloatingActions({
    super.key,
    required this.customer,
    this.onCustomerUpdated,
    this.onCustomerDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'edit_${customer.id}',
          onPressed: _editCustomer,
          backgroundColor: Colors.orange.shade700,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'delete_${customer.id}',
          onPressed: _deleteCustomer,
          backgroundColor: Colors.red.shade700,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
    );
  }

 
  Future<void> _editCustomer() async {
    final result = await Get.to<bool>(
      () => EditCustomerScreen(customer: customer),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      onCustomerUpdated?.call();
    }
  }

 
  Future<void> _deleteCustomer() async {
    final confirmed = await CustomerDialogs.showDeleteConfirmation(customer);
    
    if (confirmed) {
      onCustomerDeleted?.call();
    }
  }
}


enum CustomerAction {
  view,
  edit,
  delete,
}
