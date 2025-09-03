import 'dart:convert';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/core/utils/http_helper.dart';
import 'package:crm_app_dv/models/meeting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingsRemoteDataSource {
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<MeetingModel>> getAllMeetings() async {
    final headers = await _authHeaders();
    final url = AppConstants.meetingsEndpoint;
    print('🔎 Fetch all meetings -> GET $url');
    final resp = await HttpHelper.get(url, headers: headers, suppressErrors: true);
    if (resp['success'] == true) {
      final data = resp['data'];
      final list = (data is Map && data['meetings'] is List) ? data['meetings'] as List : (data as List? ?? []);
      print('🔎 Fetch all meetings -> ${list.length} items');
      return list.map((e) => MeetingModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<List<MeetingModel>> getMeetingsByUsername(String email) async {
    final headers = await _authHeaders();
    final encoded = Uri.encodeComponent(email);
    final url = '${AppConstants.meetingsByUsernameEndpoint}/$encoded';
    print('🔎 Fetch meetings by username -> email="$email" encoded="$encoded"');
    print('🔎 GET $url');
    final resp = await HttpHelper.get(url, headers: headers, suppressErrors: true);
    if (resp['success'] == true) {
      final data = resp['data'];
      final list = (data is Map && data['meetings'] is List) ? data['meetings'] as List : (data as List? ?? []);
      print('🔎 Fetch meetings by username -> ${list.length} items');
      final meetings = list.map((e) {
        final meetingData = Map<String, dynamic>.from(e);
        print('🔍 Meeting data: ${meetingData.toString()}');
        
        // Enriquecer customer embebido con contactNumber desde endpoint customers
        if (meetingData['customer'] is Map) {
          final customer = meetingData['customer'] as Map;
          final customerId = customer['_id']?.toString();
          if (customerId != null && customerId.isNotEmpty) {
            print('🔍 Customer embebido encontrado: $customerId');
            // Por ahora usar datos embebidos tal como vienen
          }
        }
        
        return MeetingModel.fromJson(meetingData);
      }).toList();
      
      // Log customer phone info for debugging
      for (final meeting in meetings) {
        print('📱 Meeting ${meeting.id}: customerId=${meeting.customerId}, customerPhone=${meeting.customerPhone}');
      }
      
      return meetings;
    }
    return [];
  }

  Future<MeetingModel?> createMeeting(MeetingModel meeting) async {
    final headers = await _authHeaders();
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_email');
    final token = prefs.getString('auth_token');
    final body = meeting.toCreateJson();
    // Normalize keys to match backend expectations
    if (body.containsKey('customerId') && !body.containsKey('customer')) {
      body['customer'] = body['customerId'];
      body.remove('customerId');
    }
    if (body.containsKey('projectId') && !body.containsKey('project')) {
      body['project'] = body['projectId'];
      body.remove('projectId');
    }
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }
    // Try to decode JWT to get userId
    if (token != null && token.split('.').length == 3) {
      try {
        final payloadPart = token.split('.')[1];
        final normalized = base64Url.normalize(payloadPart);
        final payload = json.decode(utf8.decode(base64Url.decode(normalized)));
        final uid = payload['userId']?.toString();
        if (uid != null && uid.isNotEmpty) {
          body['userId'] = uid;
        }
      } catch (_) {}
    }
    final resp = await HttpHelper.post(AppConstants.meetingCreateEndpoint, body, headers: headers);
    if (resp['success'] == true) {
      final data = resp['data'];
      // Backend returns { message, newMeeting: { ... } }
      Map<String, dynamic> m;
      if (data is Map && data['newMeeting'] is Map) {
        m = Map<String, dynamic>.from(data['newMeeting']);
      } else if (data is Map && data['meeting'] is Map) {
        m = Map<String, dynamic>.from(data['meeting']);
      } else {
        m = Map<String, dynamic>.from(data);
      }
      return MeetingModel.fromJson(m);
    }
    return null;
  }

  Future<MeetingModel?> updateMeeting(String id, Map<String, dynamic> patch) async {
    final headers = await _authHeaders();
    final url = '${AppConstants.meetingsEndpoint}/$id';
    final resp = await HttpHelper.post(url, patch, headers: headers); // If API expects PUT, we should implement HttpHelper.put; using post as fallback
    if (resp['success'] == true) {
      final data = resp['data'];
      final m = (data is Map && data['meeting'] is Map) ? Map<String, dynamic>.from(data['meeting']) : Map<String, dynamic>.from(data);
      return MeetingModel.fromJson(m);
    }
    return null;
  }

  Future<bool> deleteMeeting(String id) async {
    final headers = await _authHeaders();
    final url = '${AppConstants.meetingsEndpoint}/$id';
    final resp = await HttpHelper.get(url, headers: {...headers, 'X-HTTP-Method-Override': 'DELETE'}); // Fallback: implement HttpHelper.delete later
    return resp['success'] == true;
  }
}
