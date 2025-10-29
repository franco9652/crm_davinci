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
    print('🔎 Headers being sent: $headers');
    final resp = await HttpHelper.get(url, headers: headers, suppressErrors: true);
    print('🔎 Response received: ${resp}');
    if (resp['success'] == true) {
      final data = resp['data'];
      print('🔎 Response data: $data');
      final list = (data is Map && data['meetings'] is List) ? data['meetings'] as List : (data as List? ?? []);
      print('🔎 Meetings list extracted: $list');
      print('🔎 Fetch all meetings -> ${list.length} items');
      if (list.isNotEmpty) {
        print('🔎 First meeting example: ${list.first}');
      }
      return list.map((e) => MeetingModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    print('🔎 Request failed or no success flag');
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
        
        
        if (meetingData['customer'] is Map) {
          final customer = meetingData['customer'] as Map;
          final customerId = customer['_id']?.toString();
          if (customerId != null && customerId.isNotEmpty) {
            print('🔍 Customer embebido encontrado: $customerId');
           
          }
        }
        
        return MeetingModel.fromJson(meetingData);
      }).toList();
      
     
      for (final meeting in meetings) {
        print('📱 Meeting ${meeting.id}: customerId=${meeting.customerId}, customerPhone=${meeting.customerPhone}');
      }
      
      return meetings;
    }
    return [];
  }

  Future<MeetingModel?> createMeeting(MeetingModel meeting) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_email');
    final token = prefs.getString('auth_token');
    final body = meeting.toCreateJson();
    
    print('🔧 createMeeting() - Original body: $body');
    
    
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
    
    
    if (token != null && token.split('.').length == 3) {
      try {
        final payloadPart = token.split('.')[1];
        final normalized = base64Url.normalize(payloadPart);
        final payload = json.decode(utf8.decode(base64Url.decode(normalized)));
        final uid = payload['userId']?.toString();
        if (uid != null && uid.isNotEmpty) {
          body['userId'] = uid;
          print('🔧 Setting userId: $uid (backend will handle auto-assignment)');
        }
      } catch (_) {}
    }
    
    print('🔧 createMeeting() - Final body: $body');
    
   
    final headers = await _authHeaders();
    final resp = await HttpHelper.post(AppConstants.meetingCreateEndpoint, body, headers: headers);
    
    print('🔧 createMeeting() - Response success: ${resp['success']}');
    print('🔧 createMeeting() - Response data: ${resp['data']}');
    
    if (resp['success'] == true) {
      final data = resp['data'];
      
      
      Map<String, dynamic> meetingData;
      if (data is Map) {
        
        if (data.containsKey('meeting')) {
          meetingData = Map<String, dynamic>.from(data['meeting']);
        } else if (data.containsKey('newMeeting')) {
          meetingData = Map<String, dynamic>.from(data['newMeeting']);
        } else {
        
          meetingData = Map<String, dynamic>.from(data);
        }
      } else {
        print('❌ Unexpected response format: data is not a Map');
        return null;
      }
      
      print('🔧 createMeeting() - Parsed meeting data: $meetingData');
      
      
      if (!meetingData.containsKey('_id') && !meetingData.containsKey('id')) {
        print('❌ No ID found in response, generating temporary one');
        meetingData['_id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      final createdMeeting = MeetingModel.fromJson(meetingData);
      print('🔧 createMeeting() - Created MeetingModel: id=${createdMeeting.id}, title=${createdMeeting.title}');
      
      return createdMeeting;
    }
    
    print('❌ createMeeting() - Failed with response: $resp');
    return null;
  }

  Future<MeetingModel?> updateMeeting(String id, Map<String, dynamic> patch) async {
    final headers = await _authHeaders();
    final url = '${AppConstants.meetingsEndpoint}/$id';
    final resp = await HttpHelper.post(url, patch, headers: headers); 
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
    final resp = await HttpHelper.get(url, headers: {...headers, 'X-HTTP-Method-Override': 'DELETE'}); 
    return resp['success'] == true;
  }
}
