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
  String _meetingType = 'virtual'; 


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
      body: CustomScrollView(
        slivers: [
         
          SliverAppBar(
            expandedHeight: 120,
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
                                Icons.event_available,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nueva Reunión',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Programa una nueva reunión',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernSection(
                      title: 'Participantes',
                      icon: Icons.people_outline,
                      color: const Color(0xFF10B981),
                      children: [
                        _buildModernDropdown(
                          label: 'Cliente (opcional)',
                          icon: Icons.person,
                          value: _selectedCustomerId,
                          hint: _loadingCustomers ? 'Cargando...' : 'Seleccionar cliente',
                          items: _customers.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name, overflow: TextOverflow.ellipsis),
                          )).toList(),
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
                        const SizedBox(height: 16),
                        _buildModernDropdown(
                          label: 'Proyecto (opcional)',
                          icon: Icons.work_outline,
                          value: _selectedProjectId,
                          hint: _selectedCustomerId == null
                              ? 'Seleccione un cliente primero'
                              : (_loadingProjects
                                  ? 'Cargando...'
                                  : (_projects.isEmpty
                                      ? 'Este cliente no tiene proyectos'
                                      : 'Seleccionar proyecto del cliente')),
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
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    
                    _buildModernSection(
                      title: 'Información Básica',
                      icon: Icons.info_outline,
                      color: const Color(0xFF6366F1),
                      children: [
                        _buildModernTextField(
                          label: 'Título',
                          icon: Icons.title,
                          controller: _titleCtrl,
                          hint: 'Título de la reunión',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un título' : null,
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _buildModernDateTimePicker(
                              label: 'Fecha',
                              icon: Icons.calendar_today,
                              value: _formatDate(_date),
                              onTap: _pickDate,
                              color: const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(height: 16),
                            _buildModernDateTimePicker(
                              label: 'Hora',
                              icon: Icons.access_time,
                              value: _formatTime(_time),
                              onTap: _pickTime,
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _buildModernTextField(
                              label: 'Duración (minutos)',
                              icon: Icons.timer,
                              controller: _durationCtrl,
                              hint: '60',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Ingrese duración';
                                final n = int.tryParse(v);
                                if (n == null || n <= 0) return 'Duración inválida';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildModernDropdown(
                              label: 'Tipo',
                              icon: _meetingType == 'virtual' ? Icons.videocam : Icons.location_on,
                              value: _meetingType,
                              hint: 'Tipo de reunión',
                              items: const [
                                DropdownMenuItem(value: 'virtual', child: Text('Virtual')),
                                DropdownMenuItem(value: 'presencial', child: Text('Presencial')),
                              ],
                              onChanged: (v) => setState(() => _meetingType = v ?? 'virtual'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                  
                    _buildModernSection(
                      title: _meetingType == 'virtual' ? 'Link de Reunión' : 'Ubicación',
                      icon: _meetingType == 'virtual' ? Icons.link : Icons.location_on,
                      color: _meetingType == 'virtual' ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                      children: [
                        if (_meetingType == 'virtual')
                          _buildModernTextField(
                            label: 'Link de reunión',
                            icon: Icons.videocam,
                            controller: _meetingLinkCtrl,
                            hint: 'https://...',
                            validator: (v) {
                              if (_meetingType != 'virtual') return null;
                              if (v == null || v.trim().isEmpty) return 'Ingrese el link de la reunión';
                              return null;
                            },
                          ),
                        if (_meetingType == 'presencial')
                          _buildModernTextField(
                            label: 'Dirección',
                            icon: Icons.location_on,
                            controller: _addressCtrl,
                            hint: 'Dirección de la reunión',
                            validator: (v) {
                              if (_meetingType != 'presencial') return null;
                              if (v == null || v.trim().isEmpty) return 'Ingrese la dirección';
                              return null;
                            },
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
               
                    _buildModernSection(
                      title: 'Descripción',
                      icon: Icons.description_outlined,
                      color: const Color(0xFFF59E0B),
                      children: [
                        _buildModernTextField(
                          label: 'Descripción (opcional)',
                          icon: Icons.notes,
                          controller: _descriptionCtrl,
                          hint: 'Notas de la reunión',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
              
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _submit,
                          borderRadius: BorderRadius.circular(16),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_available, color: Colors.white, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Crear Reunión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 16),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildModernDateTimePicker({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: const Color(0xFF10B981), size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    hint: Text(
                      hint,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                    items: items,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
