import 'package:crm_app_dv/features/meetings/controllers/meetings_controller.dart';
import 'package:crm_app_dv/models/meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/features/projects/data/works_remote_data_source.dart';
import 'package:crm_app_dv/models/work_model.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  final _meetingLinkCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String _meetingType = 'virtual'; // virtual | presencial

  // Clientes y Proyectos
  final _customers = <CustomerModel>[];
  final _projects = <WorkModel>[];
  String? _selectedCustomerId;
  String? _selectedProjectId;
  bool _loadingCustomers = false;
  bool _loadingProjects = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    _meetingLinkCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProjectsByUser({String? userId}) async {
    setState(() => _loadingProjects = true);
    try {
      final ds = WorkRemoteDataSource(http.Client());
      List<WorkModel> list;
      if (userId != null && userId.isNotEmpty) {
        list = await ds.getWorksByUserId(userId);
      } else {
        list = [];
      }
      setState(() {
        _projects
          ..clear()
          ..addAll(list);
        if (_selectedProjectId != null && !_projects.any((w) => w.id == _selectedProjectId)) {
          _selectedProjectId = null;
        }
      });
    } catch (_) {
      // Manejado por HttpHelper
    } finally {
      if (mounted) setState(() => _loadingProjects = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loadingCustomers = true);
    try {
      final ds = CustomerRemoteDataSource(http.Client());
      final List<CustomerModel> aggregated = [];
      int page = 1;
      int totalPages = 1;
      do {
        final resp = await ds.getAllCustomers(page);
        final pageCustomers = (resp['customers'] as List<CustomerModel>? ?? <CustomerModel>[]);
        aggregated.addAll(pageCustomers);
        totalPages = (resp['totalPages'] as int?) ?? 1;
        page++;
      } while (page <= totalPages);

      setState(() {
        _customers
          ..clear()
          ..addAll(aggregated);
      });
    } catch (_) {
      // ya hay Snackbar en HttpHelper
    } finally {
      if (mounted) setState(() => _loadingCustomers = false);
    }
  }


  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: _date ?? now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _formatDate(DateTime? d) => d == null ? 'Seleccionar fecha' : DateFormat('dd/MM/yyyy').format(d);
  String _formatTime(TimeOfDay? t) => t == null ? 'Seleccionar hora' : t.format(context);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      Get.snackbar('Campos requeridos', 'Selecciona fecha y hora');
      return;
    }
    final hh = _time!.hour.toString().padLeft(2, '0');
    final mm = _time!.minute.toString().padLeft(2, '0');

    final MeetingModel draft = MeetingModel(
      id: '',
      title: _titleCtrl.text.trim(),
      date: DateTime(_date!.year, _date!.month, _date!.day),
      time: '$hh:$mm',
      duration: _durationCtrl.text.trim(),
      meetingType: _meetingType,
      meetingLink: _meetingType == 'virtual' ? _meetingLinkCtrl.text.trim().isEmpty ? null : _meetingLinkCtrl.text.trim() : null,
      address: _meetingType == 'presencial' ? _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim() : null,
      description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      customerId: _selectedCustomerId,
      projectId: _selectedProjectId,
    );

    final MeetingsController controller = Get.find<MeetingsController>();
    final ok = await controller.create(draft);
    if (!mounted) return;
    if (ok) {
      Get.back();
      Get.snackbar('Éxito', 'Reunión creada');
    } else {
      final msg = controller.error.isNotEmpty ? controller.error.value : 'No se pudo crear la reunión';
      Get.snackbar('Error', msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Nueva reunión', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cliente
              _Labeled(
                label: 'Cliente (opcional)',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCustomerId,
                      isExpanded: true,
                      menuMaxHeight: 350,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      hint: Text(_loadingCustomers ? 'Cargando...' : 'Seleccionar cliente', style: const TextStyle(color: Colors.white54)),
                      items: _customers
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCustomerId = v;
                          _selectedProjectId = null;
                        });
                        final selected = _customers.firstWhere(
                          (c) => c.id == v,
                          orElse: () => CustomerModel(
                            id: v,
                            userId: '',
                            name: '',
                            secondName: '',
                            dni: '',
                            cuit: '',
                            cuil: '',
                            address: '',
                            workDirection: '',
                            contactNumber: '',
                            email: '',
                            password: '',
                            firstRegister: true,
                            clienteActivo: true,
                            worksActive: const [],
                            documents: const [],
                            createdAt: DateTime.now(),
                            active: true,
                          ),
                        );
                        final uid = selected.userId ?? '';
                        _loadProjectsByUser(userId: uid);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Proyecto (opcional)
              _Labeled(
                label: 'Proyecto (opcional)',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedProjectId,
                      isExpanded: true,
                      menuMaxHeight: 350,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      hint: Text(
                        _selectedCustomerId == null
                            ? 'Seleccione un cliente primero'
                            : (_loadingProjects
                                ? 'Cargando...'
                                : (_projects.isEmpty
                                    ? 'Este cliente no tiene proyectos'
                                    : 'Seleccionar proyecto del cliente')),
                        style: const TextStyle(color: Colors.white54),
                      ),
                      items: (_selectedCustomerId == null ? const <WorkModel>[] : _projects)
                          .map((w) => DropdownMenuItem(
                                value: w.id,
                                child: Text(w.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: _selectedCustomerId == null
                          ? null
                          : (v) {
                              setState(() {
                                _selectedProjectId = v;
                              });
                            },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Labeled(
                label: 'Título',
                child: TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Título de la reunión'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un título' : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Labeled(
                      label: 'Fecha',
                      child: _PickerTile(
                        text: _formatDate(_date),
                        icon: Icons.calendar_today,
                        onTap: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Labeled(
                      label: 'Hora',
                      child: _PickerTile(
                        text: _formatTime(_time),
                        icon: Icons.access_time,
                        onTap: _pickTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Labeled(
                      label: 'Duración (minutos)',
                      child: TextFormField(
                        controller: _durationCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('60'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Ingrese duración';
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) return 'Duración inválida';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Labeled(
                      label: 'Tipo',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _meetingType,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'virtual', child: Text('Virtual')),
                              DropdownMenuItem(value: 'presencial', child: Text('Presencial')),
                            ],
                            onChanged: (v) => setState(() => _meetingType = v ?? 'virtual'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_meetingType == 'virtual')
                _Labeled(
                  label: 'Link de reunión',
                  child: TextFormField(
                    controller: _meetingLinkCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('https://...'),
                    validator: (v) {
                      if (_meetingType != 'virtual') return null;
                      if (v == null || v.trim().isEmpty) return 'Ingrese el link de la reunión';
                      return null;
                    },
                  ),
                ),
              if (_meetingType == 'presencial')
                _Labeled(
                  label: 'Dirección',
                  child: TextFormField(
                    controller: _addressCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Dirección de la reunión'),
                    validator: (v) {
                      if (_meetingType != 'presencial') return null;
                      if (v == null || v.trim().isEmpty) return 'Ingrese la dirección';
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 12),
              _Labeled(
                label: 'Descripción (opcional)',
                child: TextFormField(
                  controller: _descriptionCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: _inputDecoration('Notas de la reunión'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Crear reunión'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerTile({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
