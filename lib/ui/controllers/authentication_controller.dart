import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/random_user.dart';
import '../../domain/use_case/authentication.dart';

// the controller does not have business logic, it sends the request to the corresponding use case
class AuthenticationController extends GetxController {
  var _logged = false.obs;
  var _storeUser = false.obs;
  var _storeUserEmail = "".obs;
  var _storeUserPassword = "".obs;

  final Authentication _authentication = Get.find<Authentication>();

  AuthenticationController() {
    initializeLoggedState();
  }

  // it updated logged according to the data on sharedPrefs
  void initializeLoggedState() async {
    logged = await _authentication.init;
  }

  String get storeUserPassword => _storeUserPassword.value;
  String get storeUserEmail => _storeUserEmail.value;
  bool get storeUser => _storeUser.value;

  //bool get logged => _logged.value;
  //it returns _logged, if it is true it calls getStoredUser
  bool get logged {
    if (_logged.value) {
      getStoredUser();
    }
    return _logged.value;
  }

  // besides updating _storeUser, if false it clears stored data
  set storeUser(bool mode) {
    _storeUser.value = mode;
    if (mode == false) {
      clearStoredUser();
      _storeUserEmail.value = "";
      _storeUserPassword.value = "";
    }
  }

  // updates _logged
  set logged(bool mode) {
    _logged.value = mode;
  }

  // this method should clean the user data on sharedPrefs and controller
  Future<void> clearStoredUser() async {
    await _authentication.clearStoredUser();
    _logged.value = false;
  }

  // this method gets the stored user on sharedPrefs and updates the data on
  // the controller
  Future<void> getStoredUser() async {
    User user = await _authentication.getStoredUser();
    _storeUserEmail.value = user.email;
    _storeUserPassword.value = user.password;
    logInfo(
        'AuthenticationController getStoredUser and got <${user.email}> <${user.password}>');
  }

  // this method clears all stored data
  clearAll() async {
    await _authentication.clearAll();
    _logged.value = false;
    _storeUserEmail.value = "";
    _storeUserPassword.value = "";
    _storeUser.value = false;
  }

  // used to send login data, if user data is ok and if storeUser is true
  // it also stores the user on controller
  Future<bool> login(user, password) async {
    logInfo('AuthenticationController login $storeUser $user $password');

    bool rta = await _authentication.login(storeUser, user, password);
    if (storeUser) {
      if (rta) {
        _storeUserEmail.value = user;
        _storeUserPassword.value = password;
        _storeUser.value = true;
      }
    } else {
      _storeUserEmail.value = "";
      _storeUserPassword.value = "";
    }
    _logged.value = rta;
    return Future.value(rta);
  }

  // used to send signup data
  Future<bool> signup(user, password) async {
    await _authentication.signup(user, password);
    return Future.value(true);
  }

  // used to logout the current user
  void logout() async {
    await _authentication.logout();
    _logged.value = false;
    _storeUserEmail.value = "";
    _storeUserPassword.value = "";
  }
}
