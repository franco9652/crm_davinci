import 'package:get/get.dart';
import 'package:crm_app_dv/features/meetings/data/meetings_remote_data_source.dart';
import 'package:crm_app_dv/models/meeting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:crm_app_dv/core/services/notification_service.dart';

class MeetingsController extends GetxController {
  final MeetingsRemoteDataSource remote;
  MeetingsController({MeetingsRemoteDataSource? remote}) : remote = remote ?? MeetingsRemoteDataSource();

  final isLoading = false.obs;
  final meetings = <MeetingModel>[].obs;
  final filteredMeetings = <MeetingModel>[].obs;
  final error = ''.obs;
  
  
  final selectedDate = Rxn<DateTime>();
  final selectedDay = RxnString();
  final searchQuery = ''.obs;
  final selectedType = ''.obs; 
  final selectedStatus = ''.obs; 
  final isFilterActive = false.obs;
  final showArchivedMeetings = false.obs; 

  final userRole = ''.obs;
  bool get isAdmin => userRole.value == 'Admin';
  bool get isEmployee => userRole.value == 'Employee';

  
  final currentPage = 1.obs;
  final itemsPerPage = 10;
  final paginatedMeetings = <MeetingModel>[].obs;

  int get totalPages {
    final sourceList = isFilterActive.value ? filteredMeetings : meetings;
    if (sourceList.isEmpty) return 1;
    return (sourceList.length / itemsPerPage).ceil();
  }

  List<MeetingModel> get displayMeetings => paginatedMeetings;

  @override
  void onInit() {
    print('🔧 MeetingsController.onInit() called');
    fetchMeetings(forCurrentUser: true);
  }

  Future<void> fetchMeetings({bool forCurrentUser = false}) async {
    isLoading.value = true;
    error.value = '';
    print('🔧 fetchMeetings() called with forCurrentUser=$forCurrentUser');
    print('🔧 Current meetings in memory before fetch: ${meetings.length}');
    if (meetings.isNotEmpty) {
      print('🔧 Existing meetings: ${meetings.map((m) => "${m.id}: ${m.title}").join(", ")}');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = (prefs.getString('user_role') ?? '').trim();
      userRole.value = role;
      final email = prefs.getString('user_email');
      final userId = prefs.getString('user_id');
      print('🔧 Current role: "$role", email: "$email", userId: "$userId"');
      print('🔧 isAdmin=${isAdmin}, isEmployee=${isEmployee}');

      List<MeetingModel> data = [];

      if (isAdmin || isEmployee) {
        
        print('🔧 ${isAdmin ? "Admin" : "Employee"}: calling getAllMeetings()');
        data = await remote.getAllMeetings();
      } else {
        
        print('🔧 Customer: calling getMeetingsByUsername()');
        if (email != null && email.isNotEmpty) {
          data = await remote.getMeetingsByUsername(email);
        } else {
          
          data = await remote.getAllMeetings();
        }
      }
      
      print('🔧 Backend returned ${data.length} meetings');
      if (data.isNotEmpty) {
        print('🔧 Backend meetings details:');
        for (var meeting in data) {
          print('  - ID: ${meeting.id}, Title: ${meeting.title}, Customer: ${meeting.customerName}, Date: ${meeting.date}');
        }
      }
      
      
      final previousCount = meetings.length;
      meetings.assignAll(data);
      print('🔧 Meetings updated: $previousCount → ${meetings.length}');
      
      if (meetings.isNotEmpty) {
        print('🔧 Sample meetings: ${meetings.take(3).map((m) => "${m.id}: ${m.title}").join(", ")}');
      } else {
        print('❌ Backend returned EMPTY meetings list!');
      }
      
      
      currentPage.value = 1;
      _applyFilters();
      
      
      _scheduleNotificationsForMeetings().catchError((e) {
        print('⚠️ Error scheduling notifications (non-blocking): $e');
      });
      
      
      autoArchivePastMeetings().catchError((e) {
        print('⚠️ Error auto-archiving past meetings (non-blocking): $e');
      });
    } catch (e) {
      print('❌ Error in fetchMeetings: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      print('🔧 fetchMeetings() completed. Final meetings: ${meetings.length}');
    }
  }


 
  void _applyFilters() {
    List<MeetingModel> filtered = List.from(meetings);

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      print('Filtrando con query: "$query"');
      print('Total reuniones antes de filtrar: ${filtered.length}');
      
      
      for (var m in meetings) {
        final match = m.title.toLowerCase().contains(query);
        print('  - "${m.title}" contiene "$query"? $match');
      }
      
      filtered = filtered.where((meeting) {
        return meeting.title.toLowerCase().contains(query) ||
               (meeting.description?.toLowerCase().contains(query) ?? false) ||
               (meeting.customerName?.toLowerCase().contains(query) ?? false);
      }).toList();
      
      print('🔎 Reuniones después de filtrar: ${filtered.length}');
    }
    
    
    if (selectedDate.value != null) {
      filtered = filtered.where((meeting) {
        return meeting.date.year == selectedDate.value!.year &&
               meeting.date.month == selectedDate.value!.month &&
               meeting.date.day == selectedDate.value!.day;
      }).toList();
    }
    
    
    if (selectedDay.value != null && selectedDay.value!.isNotEmpty) {
      filtered = filtered.where((meeting) {
        final weekday = _getWeekdayName(meeting.date.weekday);
        return weekday.toLowerCase() == selectedDay.value!.toLowerCase();
      }).toList();
    }
    
    
    if (selectedType.value.isNotEmpty) {
      filtered = filtered.where((meeting) {
        return meeting.meetingType.toLowerCase() == selectedType.value.toLowerCase();
      }).toList();
    }
    
    
    if (selectedStatus.value.isNotEmpty) {
      final now = DateTime.now();
      filtered = filtered.where((meeting) {
        try {
          
          final timeParts = meeting.time.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          
          final meetingDateTime = DateTime(
            meeting.date.year,
            meeting.date.month,
            meeting.date.day,
            hour,
            minute,
          );
          
          
          final durationMinutes = int.tryParse(meeting.duration) ?? 60;
          
          switch (selectedStatus.value.toLowerCase()) {
            case 'próxima':
              return meetingDateTime.isAfter(now);
            case 'en curso':
              final endTime = meetingDateTime.add(Duration(minutes: durationMinutes));
              return meetingDateTime.isBefore(now) && endTime.isAfter(now);
            case 'finalizada':
              final endTime = meetingDateTime.add(Duration(minutes: durationMinutes));
              return endTime.isBefore(now);
            default:
              return true;
          }
        } catch (e) {
          print('❌ Error parsing meeting time/duration: $e');
          return true; 
        }
      }).toList();
    }
    
    filteredMeetings.assignAll(filtered);
    
    
    isFilterActive.value = searchQuery.value.isNotEmpty ||
                          selectedDate.value != null || 
                          (selectedDay.value != null && selectedDay.value!.isNotEmpty) ||
                          selectedType.value.isNotEmpty ||
                          selectedStatus.value.isNotEmpty;
    
    
    _applyPagination();
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


  void updateSearchQuery(String query) {
    print('Reuniones filtradas: "$query"');
    searchQuery.value = query;
    currentPage.value = 1; 
    _applyFilters();
    print('Reuniones filtradas: ${filteredMeetings.length} de ${meetings.length}');
  }

  void filterByType(String? type) {
    selectedType.value = type ?? '';
    currentPage.value = 1; 
    _applyFilters();
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status ?? '';
    currentPage.value = 1; 
    _applyFilters();
  }

  void clearFilters() {
    selectedDate.value = null;
    selectedDay.value = null;
    searchQuery.value = '';
    selectedType.value = '';
    selectedStatus.value = '';
    currentPage.value = 1; 
    _applyFilters();
  }

 
  List<String> get meetingTypes => ['virtual', 'presencial'];
  List<String> get meetingStatuses => ['próxima', 'en curso', 'finalizada'];

  void _applyPagination() {
    final sourceList = isFilterActive.value ? filteredMeetings : meetings;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, sourceList.length);
    
    if (startIndex < sourceList.length) {
      paginatedMeetings.assignAll(sourceList.sublist(startIndex, endIndex));
    } else {
      paginatedMeetings.clear();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
      _applyPagination();
    }
  }
 
  Future<bool> create(MeetingModel meeting) async {
    print('🔧 create() called');
    isLoading.value = true;
    error.value = '';
    try {
      final created = await remote.createMeeting(meeting);
      print('🔧 Backend createMeeting returned: ${created != null ? "SUCCESS" : "NULL"}');
      if (created != null) {
        print('🔧 Created meeting details: id="${created.id}", title="${created.title}", date=${created.date}');

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

        try {
          print('✅ Reunión creada localmente: id=${created.id}, title=${created.title}, date=${created.date}');
          selectedDate.value = created.date;
        } catch (_) {}
        _applyFilters();
        print('🔧 After _applyFilters(), displayMeetings count: ${displayMeetings.length}');

        _scheduleNotificationsForMeetings().catchError((e) {
          print('⚠️ Error scheduling notifications after create (non-blocking): $e');
        });

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

  Future<MeetingModel?> updateMeeting(MeetingModel updatedMeeting) async {
    print('🔧 updateMeeting() called for id="${updatedMeeting.id}"');
    isLoading.value = true;
    error.value = '';
    try {
      final patch = updatedMeeting.toCreateJson();
      final result = await remote.updateMeeting(updatedMeeting.id, patch);
      if (result != null) {
        final index = meetings.indexWhere((m) => m.id == result.id);
        if (index >= 0) {
          meetings[index] = result;
        } else {
          meetings.insert(0, result);
        }
        _applyFilters();
        _scheduleNotificationsForMeetings().catchError((e) {
          print('⚠️ Error scheduling notifications after update (non-blocking): $e');
        });
        return result;
      } else {
        error.value = 'No se pudo actualizar la reunión';
        return null;
      }
    } catch (e) {
      print('❌ Error in updateMeeting(): $e');
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
      print('🔧 updateMeeting() completed');
    }
  }

  Future<bool> deleteMeeting(String meetingId) async {
    print('🗑 deleteMeeting() called for id="$meetingId"');
    isLoading.value = true;
    error.value = '';
    try {
      final ok = await remote.deleteMeeting(meetingId);
      if (ok) {
        final beforeCount = meetings.length;
        meetings.removeWhere((m) => m.id == meetingId);
        print('🗑 deleteMeeting() removed ${beforeCount - meetings.length} items from local list');
        _applyFilters();
        _scheduleNotificationsForMeetings().catchError((e) {
          print('⚠️ Error scheduling notifications after delete (non-blocking): $e');
        });
        return true;
      } else {
        error.value = 'No se pudo eliminar la reunión';
        return false;
      }
    } catch (e) {
      print('❌ Error in deleteMeeting(): $e');
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
      print('🗑 deleteMeeting() completed');
    }
  }

  
  Future<void> _scheduleNotificationsForMeetings() async {
    try {
      print('🔔 Scheduling notifications for ${meetings.length} meetings...');
      if (meetings.isNotEmpty) {
        await NotificationService.scheduleAllNotifications(meetings: meetings.toList());
        print('✅ Notifications scheduled successfully');
      } else {
        print('⚠️ No meetings to schedule notifications for');
      }
    } catch (e) {
      print('❌ Error scheduling notifications: $e');
      
    }
  }

  String _formatPhoneForWhatsApp(String rawPhone) {
    
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    
    
    if (digits.startsWith('1') && digits.length == 11) {
      digits = digits.substring(1); 
    }
    
    
    if (digits.length == 10 && digits.startsWith('11')) {
      return '549$digits';
    }
    

    if (digits.startsWith('549')) {
      return digits;
    }
    
    
    if (digits.startsWith('54') && !digits.startsWith('549')) {
      return '549${digits.substring(2)}';
    }
    
   
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
      
      
      if ((meeting.customerPhone ?? '').isNotEmpty) {
        print('📨 Usando teléfono embebido: ${meeting.customerPhone}');
        return await _launchWhatsAppOrSMS(meeting.customerPhone!, _buildSummary(meeting));
      }

      
      if ((meeting.customerId ?? '').isEmpty) {
        print('❌ No hay customerId en la meeting');
        Get.snackbar('Cliente requerido', 'La reunión no tiene un cliente asociado.');
        return false;
      }

      
      print('📨 Endpoints de customers no disponibles, usando datos embebidos');
      
      
      print('📨 Buscando en lista completa de customers...');
      final ds = CustomerRemoteDataSource(http.Client());
      
      try {
       
        CustomerModel? targetCustomer;
        int page = 1;

        while (targetCustomer == null) {
          final allCustomersResp = await ds.getAllCustomers(page);
          final List<CustomerModel> customersList =
              ((allCustomersResp['customers'] as List?)?.cast<CustomerModel>()) ?? <CustomerModel>[];
          final int totalPages = (allCustomersResp['totalPages'] as int?) ?? 1;

          print('📨 Página $page: ${customersList.length} customers disponibles');

         
          for (final c in customersList) {
            final id = (c.id ?? '').toString();
            final name = c.name;
            print('📨 Checking customer by id: name=$name, id=$id');
            if (id.isNotEmpty && id == (meeting.customerId ?? '')) {
              targetCustomer = c;
              break;
            }
          }

          
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
            
            return await _showManualPhoneDialog(meeting);
          }
        } else {
          print('❌ Customer no encontrado en lista completa');
          
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

 
  Future<void> autoArchivePastMeetings() async {
    try {
      print('🔍 Iniciando auto-archivo de reuniones pasadas...');
      print('📊 Total de reuniones: ${meetings.length}');
      
      int archivedCount = 0;
      final List<MeetingModel> updatedMeetings = [];
      
      for (var meeting in meetings) {
        final isPastMeeting = meeting.isPast();
        print('📅 Reunión: ${meeting.title} - Fecha: ${meeting.date} ${meeting.time} - ¿Pasó?: $isPastMeeting - ¿Archivada?: ${meeting.archived}');
        
        if (isPastMeeting && !meeting.archived) {
          updatedMeetings.add(meeting.copyWith(archived: true));
          archivedCount++;
          print('  ✅ Archivando: ${meeting.title}');
        } else {
          updatedMeetings.add(meeting);
        }
      }
      
      if (archivedCount > 0) {
        meetings.assignAll(updatedMeetings);
        print('📦 Auto-archivadas $archivedCount reuniones pasadas');
        _applyFilters(); 
      } else {
        print('ℹ️ No hay reuniones pasadas para archivar');
      }
    } catch (e) {
      print('❌ Error al auto-archivar reuniones: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  
  void toggleShowArchived() {
    showArchivedMeetings.value = !showArchivedMeetings.value;
    _applyFilters();
  }


  Future<void> toggleArchiveMeeting(String meetingId) async {
    try {
      final index = meetings.indexWhere((m) => m.id == meetingId);
      if (index != -1) {
        final meeting = meetings[index];
        meetings[index] = meeting.copyWith(archived: !meeting.archived);
        _applyFilters();
        
        Get.snackbar(
          'Éxito',
          meeting.archived ? 'Reunión restaurada' : 'Reunión archivada',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ Error al archivar/desarchivar reunión: $e');
      Get.snackbar(
        'Error',
        'No se pudo modificar el estado de la reunión',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }


  int get archivedMeetingsCount => meetings.where((m) => m.archived).length;
  

  int get activeMeetingsCount => meetings.where((m) => !m.archived).length;
}
