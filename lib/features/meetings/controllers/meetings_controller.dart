import 'dart:convert';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/meetings/data/meetings_remote_data_source.dart';
import 'package:crm_app_dv/models/meeting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class MeetingsController extends GetxController {
  final MeetingsRemoteDataSource remote;
  MeetingsController({MeetingsRemoteDataSource? remote}) : remote = remote ?? MeetingsRemoteDataSource();

  final isLoading = false.obs;
  final meetings = <MeetingModel>[].obs;
  final filteredMeetings = <MeetingModel>[].obs;
  final error = ''.obs;
  
  // Filtros
  final selectedDate = Rxn<DateTime>();
  final selectedDay = RxnString();
  final isFilterActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔧 MeetingsController.onInit() called');
    fetchMeetings(forCurrentUser: true);
  }

  Future<void> fetchMeetings({bool forCurrentUser = false}) async {
    print('🔧 fetchMeetings() called with forCurrentUser=$forCurrentUser');
    isLoading.value = true;
    error.value = '';
    try {
      List<MeetingModel> data;
      final prefs = await SharedPreferences.getInstance();
      final role = (prefs.getString('user_role') ?? '').trim();
      final email = prefs.getString('user_email');
      print('🔧 Current role: "$role", email: "$email"');

      final isAdmin = role == 'Admin';
      final isEmployee = role == 'Employee';
      print('🔧 isAdmin=$isAdmin, isEmployee=$isEmployee');

      if (isAdmin) {
        // Admin ve todo
        print('🔧 Admin: calling getAllMeetings()');
        data = await remote.getAllMeetings();
      } else if (isEmployee) {
        // Employee: solo GET /meetings (según pedido)
        print('🔧 Employee: calling getAllMeetings()');
        data = await remote.getAllMeetings();
      } else {
        // Para Customer: usar por username si lo tenemos
        print('🔧 Customer: calling getMeetingsByUsername()');
        if (email != null && email.isNotEmpty) {
          data = await remote.getMeetingsByUsername(email);
        } else {
          // Si no hay email en prefs, último recurso: pedir todas
          data = await remote.getAllMeetings();
        }
      }
      print('🔧 Backend returned ${data.length} meetings');
      // Si Employee y el backend devuelve vacío, intentar cargar desde caché local
      final prev = List<MeetingModel>.from(meetings);
      print('🔧 Previous meetings in memory: ${prev.length}');
      if (isEmployee && data.isEmpty) {
        // Intentar cargar cache para este usuario
        if (email != null && email.isNotEmpty) {
          final cached = await _loadCachedMeetings(email);
          if (cached.isNotEmpty) {
            print('💾 Cargando ${cached.length} meetings desde caché local para $email');
            meetings.assignAll(cached);
          } else if (prev.isNotEmpty) {
            print('ℹ️ Backend vacío y sin cache. Conservando ${prev.length} meetings locales en memoria.');
            // mantener prev en memoria
          } else {
            print('🔧 No cache, no prev meetings. Setting empty list.');
            meetings.assignAll([]);
          }
        } else if (prev.isNotEmpty) {
          print('ℹ️ Backend vacío y sin email. Conservando ${prev.length} meetings locales en memoria.');
        } else {
          print('🔧 No email, no prev meetings. Setting empty list.');
          meetings.assignAll([]);
        }
      } else {
        print('🔧 Assigning ${data.length} meetings from backend');
        meetings.assignAll(data);
        // Guardar cache si es employee y hay datos
        if (isEmployee && email != null && email.isNotEmpty && data.isNotEmpty) {
          await _saveCachedMeetings(email, data);
        }
      }
      print('🔧 Final meetings count: ${meetings.length}');
      _applyFilters(); // Aplicar filtros después de cargar
    } catch (e) {
      print('❌ Error in fetchMeetings: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      print('🔧 fetchMeetings() completed. Final meetings: ${meetings.length}');
    }
  }

  Future<void> _saveCachedMeetings(String email, List<MeetingModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'meetings_cache_employee_' + email;
      final jsonList = items.map((m) => m.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
      print('💾 Cache guardado (${items.length}) para $email');
    } catch (e) {
      print('❌ Error guardando cache: $e');
    }
  }

  Future<List<MeetingModel>> _loadCachedMeetings(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'meetings_cache_employee_' + email;
      final str = prefs.getString(key);
      if (str == null || str.isEmpty) return [];
      final List list = jsonDecode(str) as List;
      return list.map((e) => MeetingModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      print('❌ Error cargando cache: $e');
      return [];
    }
  }

  void _applyFilters() {
    List<MeetingModel> filtered = List.from(meetings);
    
    // Filtro por fecha específica
    if (selectedDate.value != null) {
      filtered = filtered.where((meeting) {
        return meeting.date.year == selectedDate.value!.year &&
               meeting.date.month == selectedDate.value!.month &&
               meeting.date.day == selectedDate.value!.day;
      }).toList();
    }
    
    // Filtro por día de la semana
    if (selectedDay.value != null && selectedDay.value!.isNotEmpty) {
      filtered = filtered.where((meeting) {
        final weekday = _getWeekdayName(meeting.date.weekday);
        return weekday.toLowerCase() == selectedDay.value!.toLowerCase();
      }).toList();
    }
    
    filteredMeetings.assignAll(filtered);
    isFilterActive.value = selectedDate.value != null || 
                          (selectedDay.value != null && selectedDay.value!.isNotEmpty);
  }

  String _getWeekdayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  void filterByDate(DateTime? date) {
    selectedDate.value = date;
    _applyFilters();
  }

  void filterByDay(String? day) {
    selectedDay.value = day;
    _applyFilters();
  }

  void clearFilters() {
    selectedDate.value = null;
    selectedDay.value = null;
    _applyFilters();
  }

  List<MeetingModel> get displayMeetings => 
      isFilterActive.value ? filteredMeetings : meetings;

  Future<bool> create(MeetingModel meeting) async {
    print('🔧 create() called with meeting: title="${meeting.title}", date=${meeting.date}');
    isLoading.value = true;
    error.value = '';
    try {
      final created = await remote.createMeeting(meeting);
      print('🔧 Backend createMeeting returned: ${created != null ? "SUCCESS" : "NULL"}');
      if (created != null) {
        print('🔧 Created meeting details: id="${created.id}", title="${created.title}", date=${created.date}');
        // Optimistic update: insertar/actualizar en memoria para que aparezca de inmediato
        final idx = meetings.indexWhere((m) => m.id == created.id);
        print('🔧 Looking for existing meeting with id="${created.id}": found at index $idx');
        if (idx >= 0) {
          print('🔧 Updating existing meeting at index $idx');
          meetings[idx] = created;
        } else {
          print('🔧 Inserting new meeting at position 0');
          meetings.insert(0, created);
        }
        print('🔧 Meetings list now has ${meetings.length} items');
        // Enfocar filtro por fecha en la reunión creada, para asegurar visibilidad
        try {
          print('✅ Reunión creada localmente: id=${created.id}, title=${created.title}, date=${created.date}');
          print('🔧 Setting selectedDate filter to ${created.date}');
          selectedDate.value = created.date;
        } catch (_) {}
        _applyFilters();
        print('🔧 After _applyFilters(), displayMeetings count: ${displayMeetings.length}');
        // Persistir en caché si es Employee
        try {
          final prefs = await SharedPreferences.getInstance();
          final role = (prefs.getString('user_role') ?? '').trim();
          final email = prefs.getString('user_email');
          print('🔧 Checking cache save: role="$role", email="$email"');
          if (role == 'Employee' && email != null && email.isNotEmpty) {
            print('🔧 Saving to cache for Employee');
            await _saveCachedMeetings(email, meetings);
          }
        } catch (_) {}
        return true;
      } else {
        print('❌ Backend returned null for createMeeting');
        error.value = 'No se pudo crear la reunión';
        return false;
      }
    } catch (e) {
      print('❌ Error in create(): $e');
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
      print('🔧 create() completed');
    }
  }

  String _formatPhoneForWhatsApp(String rawPhone) {
    // Remover todos los caracteres no numéricos
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    
    // Si tiene código de país +1, removerlo
    if (digits.startsWith('1') && digits.length == 11) {
      digits = digits.substring(1); // Remover el 1 inicial
    }
    
    // Para números argentinos de celular (11XXXXXXXX)
    if (digits.length == 10 && digits.startsWith('11')) {
      // Para WhatsApp argentino: 549 + 11 + número sin 15
      // Ejemplo: 1158800708 -> 5491158800708
      return '549$digits';
    }
    
    // Para números que ya empiezan con 549 (formato WhatsApp argentino)
    if (digits.startsWith('549')) {
      return digits;
    }
    
    // Para números que empiezan con 54 pero sin el 9
    if (digits.startsWith('54') && !digits.startsWith('549')) {
      return '549${digits.substring(2)}';
    }
    
    // Para cualquier otro número argentino, agregar 549
    return '549$digits';
  }

  String _buildSummary(MeetingModel meeting) {
    final b = StringBuffer();
    b.writeln('📅 Resumen de Reunión');
    b.writeln('- Título: ${meeting.title}');
    b.writeln('- Fecha: ${meeting.date.day.toString().padLeft(2, '0')}/${meeting.date.month.toString().padLeft(2, '0')}/${meeting.date.year}');
    b.writeln('- Hora: ${meeting.time}');
    b.writeln('- Duración: ${meeting.duration} min');
    if (meeting.meetingType == 'virtual' && (meeting.meetingLink ?? '').isNotEmpty) {
      b.writeln('- Link: ${meeting.meetingLink}');
    }
    if (meeting.meetingType == 'presencial' && (meeting.address ?? '').isNotEmpty) {
      b.writeln('- Dirección: ${meeting.address}');
    }
    if ((meeting.projectTitle ?? '').isNotEmpty) {
      b.writeln('- Proyecto: ${meeting.projectTitle}');
    }
    return b.toString();
  }

  Future<bool> sendSummaryToCustomer(MeetingModel meeting) async {
    try {
      print('📨 INICIO - Enviar resumen: customerId=${meeting.customerId}, customerPhone=${meeting.customerPhone}');
      
      // 1) Usar teléfono embebido si viene en la meeting
      if ((meeting.customerPhone ?? '').isNotEmpty) {
        print('📨 Usando teléfono embebido: ${meeting.customerPhone}');
        return await _launchWhatsAppOrSMS(meeting.customerPhone!, _buildSummary(meeting));
      }

      // 2) Si no hay customerId, no se puede enviar
      if ((meeting.customerId ?? '').isEmpty) {
        print('❌ No hay customerId en la meeting');
        Get.snackbar('Cliente requerido', 'La reunión no tiene un cliente asociado.');
        return false;
      }

      // 3) Los endpoints de customers no funcionan, usar datos embebidos
      print('📨 Endpoints de customers no disponibles, usando datos embebidos');
      
      // Buscar todos los customers disponibles para encontrar el teléfono
      print('📨 Buscando en lista completa de customers...');
      final ds = CustomerRemoteDataSource(http.Client());
      
      try {
        // Usar getAllCustomers que SÍ funciona - buscar en todas las páginas si es necesario
        CustomerModel? targetCustomer;
        int page = 1;

        while (targetCustomer == null) {
          final allCustomersResp = await ds.getAllCustomers(page);
          final List<CustomerModel> customersList =
              ((allCustomersResp['customers'] as List?)?.cast<CustomerModel>()) ?? <CustomerModel>[];
          final int totalPages = (allCustomersResp['totalPages'] as int?) ?? 1;

          print('📨 Página $page: ${customersList.length} customers disponibles');

          // 3a) Buscar por el customerId de la meeting (match exacto por id)
          for (final c in customersList) {
            final id = (c.id ?? '').toString();
            final name = c.name;
            print('📨 Checking customer by id: name=$name, id=$id');
            if (id.isNotEmpty && id == (meeting.customerId ?? '')) {
              targetCustomer = c;
              break;
            }
          }

          // 3b) Si no se encontró por id, intentar por nombre (case-insensitive, trimmed)
          if (targetCustomer == null && (meeting.customerName ?? '').trim().isNotEmpty) {
            final meetingName = (meeting.customerName ?? '').trim().toLowerCase();
            for (final c in customersList) {
              final cName = (c.name).trim().toLowerCase();
              if (cName == meetingName) {
                print('📨 Match por nombre: ${c.name}');
                targetCustomer = c;
                break;
              }
            }
          }

          if (targetCustomer != null || page >= totalPages) break;
          page++;
        }

        if (targetCustomer != null) {
          final rawPhone = (targetCustomer.contactNumber).toString();
          print('📨 ✅ Customer encontrado: ${targetCustomer.name}, teléfono: $rawPhone');

          if (rawPhone.isNotEmpty) {
            return await _launchWhatsAppOrSMS(rawPhone, _buildSummary(meeting));
          } else {
            print('❌ Customer sin contactNumber');
            // Mostrar diálogo para ingresar número manualmente
            return await _showManualPhoneDialog(meeting);
          }
        } else {
          print('❌ Customer no encontrado en lista completa');
          // En lugar de fallar, mostrar diálogo para ingresar número manualmente
          return await _showManualPhoneDialog(meeting);
        }
      } catch (e) {
        print('❌ Error obteniendo lista de customers: $e');
        Get.snackbar('Error', 'No se pudo acceder a la lista de clientes.');
        return false;
      }
    } catch (e) {
      print('❌ Error general al enviar resumen: $e');
      Get.snackbar('Error', 'No se pudo enviar el resumen: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _launchWhatsAppOrSMS(String rawPhone, String message) async {
    final phone = _formatPhoneForWhatsApp(rawPhone);
    final text = Uri.encodeComponent(message);
    
    print('🔗 Teléfono original: $rawPhone');
    print('🔗 Teléfono formateado: $phone');
    print('📝 Mensaje: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
    
    // Intentar WhatsApp primero
    final waUri = Uri.parse('https://wa.me/$phone?text=$text');
    print('🔗 URL WhatsApp: $waUri');
    
    try {
      if (await canLaunchUrl(waUri)) {
        print('✅ WhatsApp disponible, lanzando...');
        final ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        print('✅ WhatsApp launch resultado: $ok');
        if (ok) {
          Get.snackbar('Enviado', 'Resumen enviado por WhatsApp', backgroundColor: Colors.green);
          return true;
        }
      } else {
        print('❌ WhatsApp no disponible');
      }
    } catch (e) {
      print('❌ Error lanzando WhatsApp: $e');
    }
    
    // Fallback a SMS
    try {
      final smsUri = Uri.parse('sms:$phone?body=$text');
      print('🔗 Intentando SMS: $smsUri');
      final smsOk = await launchUrl(smsUri);
      print('📱 SMS launch resultado: $smsOk');
      
      if (smsOk) {
        Get.snackbar('Enviado', 'Resumen enviado por SMS', backgroundColor: Colors.green);
        return true;
      } else {
        print('❌ SMS falló');
        Get.snackbar('Error', 'No se pudo abrir mensajería para: $rawPhone');
        return false;
      }
    } catch (e) {
      print('❌ Error lanzando SMS: $e');
      Get.snackbar('Error', 'No se pudo abrir mensajería');
      return false;
    }
  }

  Future<bool> _showManualPhoneDialog(MeetingModel meeting) async {
    final phoneController = TextEditingController();
    bool? result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Número de WhatsApp', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se encontró el número del cliente.\nIngresa el número para enviar el resumen:',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: 1158800708',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                Get.back(result: true);
                _launchWhatsAppOrSMS(phone, _buildSummary(meeting));
              } else {
                Get.snackbar('Error', 'Ingresa un número válido');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
