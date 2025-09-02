import 'package:get/get.dart';
import 'package:crm_app_dv/features/meetings/data/meetings_remote_data_source.dart';
import 'package:crm_app_dv/models/meeting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingsController extends GetxController {
  final MeetingsRemoteDataSource remote;
  MeetingsController({MeetingsRemoteDataSource? remote}) : remote = remote ?? MeetingsRemoteDataSource();

  final isLoading = false.obs;
  final meetings = <MeetingModel>[].obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
  }

  Future<void> fetchMeetings({bool forCurrentUser = false}) async {
    isLoading.value = true;
    error.value = '';
    try {
      List<MeetingModel> data;
      if (forCurrentUser) {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('user_email');
        if (email == null || email.isEmpty) {
          data = await remote.getAllMeetings();
        } else {
          data = await remote.getMeetingsByUsername(email);
          // Fallback: si no hay resultados para el usuario, intentar obtener todas (útil para roles admin/employee)
          if (data.isEmpty) {
            data = await remote.getAllMeetings();
          }
        }
      } else {
        data = await remote.getAllMeetings();
      }
      meetings.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(MeetingModel meeting) async {
    isLoading.value = true;
    error.value = '';
    try {
      final created = await remote.createMeeting(meeting);
      if (created != null) {
        // Tras crear, refrescar desde backend para garantizar datos completos y consistentes
        await fetchMeetings(forCurrentUser: true);
        return true;
      } else {
        error.value = 'No se pudo crear la reunión';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
