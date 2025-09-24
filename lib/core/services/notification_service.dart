import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:crm_app_dv/models/meeting_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      print('🔔 Initializing NotificationService...');
      
    
      tz.initializeTimeZones();
      
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
     
      await _requestPermissions();
      
      _initialized = true;
      print('✅ NotificationService initialized successfully');
      
      
      await printPendingNotifications();
      
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
      print('⚠️ Notifications will be disabled for this session');
      
    }
  }

  /// Solicitar permisos de notificación
  static Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Manejar cuando se toca una notificación
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // Aquí puedes navegar a la pantalla correspondiente
  }

  /// Programar todas las notificaciones para meetings
  static Future<void> scheduleAllNotifications({
    List<MeetingModel>? meetings,
  }) async {
    await initialize();
    
    // Si no se pudo inicializar, salir silenciosamente
    if (!_initialized) {
      print('⚠️ NotificationService not initialized, skipping notifications');
      return;
    }
    
    try {
      print('🔔 Scheduling notifications for ${meetings?.length ?? 0} meetings...');
      
      // Cancelar todas las notificaciones anteriores
      await _notifications.cancelAll();
      print('🔔 Cancelled all previous notifications');
      
      int notificationCount = 0;
      
      // Programar notificaciones para meetings
      if (meetings != null) {
        for (var meeting in meetings) {
          final scheduled = await _scheduleMeetingNotifications(meeting);
          notificationCount += scheduled;
        }
      }
      
      print('✅ Scheduled $notificationCount notifications total');
      
      // Debug: Mostrar notificaciones pendientes después de programar
      await printPendingNotifications();
      
    } catch (e) {
      print('❌ Error scheduling notifications: $e');
    }
  }

  /// Programar notificaciones para una meeting específica
  static Future<int> _scheduleMeetingNotifications(MeetingModel meeting) async {
    try {
      
      final timeParts = meeting.time.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
      
      final meetingDateTime = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day,
        hour,
        minute,
      );
      
   
      if (meetingDateTime.isBefore(DateTime.now())) {
        print('⏭️ Skipping past meeting: ${meeting.title}');
        return 0;
      }
      
      final meetingTz = tz.TZDateTime.from(meetingDateTime, tz.local);
      int scheduledCount = 0;
      
      // 1 día antes
      final oneDayBefore = meetingTz.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _generateId(meeting.id, 'day'),
          title: '📅 Reunión mañana',
          body: 'Tienes reunión con ${meeting.customerName ?? 'cliente'} a las ${meeting.time}',
          scheduledDate: oneDayBefore,
        );
        scheduledCount++;
      }
      
      // 1 hora antes
      final oneHourBefore = meetingTz.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _generateId(meeting.id, 'hour'),
          title: '⏰ Reunión en 1 hora',
          body: '${meeting.customerName ?? 'Cliente'} - ${meeting.address ?? 'Ubicación por confirmar'}',
          scheduledDate: oneHourBefore,
        );
        scheduledCount++;
      }
      
      // 15 minutos antes
      final fifteenMinBefore = meetingTz.subtract(const Duration(minutes: 15));
      if (fifteenMinBefore.isAfter(tz.TZDateTime.now(tz.local))) {
        await _scheduleNotification(
          id: _generateId(meeting.id, 'min'),
          title: '🔔 Reunión ahora',
          body: '${meeting.title} - ${meeting.customerName ?? 'Cliente'}',
          scheduledDate: fifteenMinBefore,
        );
        scheduledCount++;
      }
      
      print('📅 Scheduled $scheduledCount notifications for meeting: ${meeting.title}');
      return scheduledCount;
      
    } catch (e) {
      print('❌ Error scheduling meeting notifications: $e');
      return 0;
    }
  }

  /// Programar una notificación individual
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'crm_reminders',
      'Recordatorios CRM',
      channelDescription: 'Recordatorios de reuniones y proyectos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    print('🔔 Scheduled notification: $title at ${scheduledDate.toString()}');
  }

  /// Generar ID único para notificaciones
  static int _generateId(String itemId, String type) {
    return '${itemId}_$type'.hashCode;
  }

  /// Obtener notificaciones pendientes (para debug)
  static Future<void> printPendingNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      print('🔔 Pending notifications: ${pending.length}');
      
      for (var notification in pending) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
    }
  }

  /// Crear notificación de prueba inmediata (para testing)
  static Future<void> sendTestNotification() async {
    await initialize();
    
    if (!_initialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      // Notificación en 10 segundos
      final testTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
      
      await _scheduleNotification(
        id: 999999,
        title: '🧪 Prueba de notificación',
        body: '¡Las notificaciones funcionan correctamente!',
        scheduledDate: testTime,
      );
      
      print('🧪 Test notification scheduled for 10 seconds from now');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }
}
