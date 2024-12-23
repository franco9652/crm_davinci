import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';
class MainNavigationController extends GetxController {
  var currentIndex = 0.obs; // Índice del BottomNavigationBar

  void changePage(int index) {
    currentIndex.value = index;
  }
}