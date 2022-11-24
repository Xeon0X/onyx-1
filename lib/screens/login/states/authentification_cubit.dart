import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartus/tomuss.dart' as tomusslib;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oloid2/core/cache_service.dart';
import 'package:oloid2/screens/agenda/agenda_export.dart';
import 'package:oloid2/screens/login/login_export.dart';
import 'package:oloid2/screens/mails/mails_export.dart';
import 'package:oloid2/screens/settings/settings_export.dart';
import 'package:oloid2/screens/tomuss/tomuss_export.dart';

part 'authentification_state.dart';

class AuthentificationCubit extends Cubit<AuthentificationState> {
  tomusslib.Dartus? _dartus;
  late String _usename;
  late String _password;

  AuthentificationCubit()
      : super(AuthentificationState(status: AuthentificationStatus.initial));

  Future<void> login(
      {required bool keepLogedIn, String? username, String? password}) async {
    //fetch username and password
    emit(state.copyWith(status: AuthentificationStatus.authentificating));
    try {
      Authentication auth = await AuthentificationLogic.fetchCredential(
          username: username, password: password);
      _usename = auth.username;
      _password = auth.password;
    } catch (e) {
      emit(state.copyWith(
          status: AuthentificationStatus.needCredential,
          username: "",
          password: "",
          dartus: _dartus));
      return;
    }
    //login
    try {
      _dartus = await AuthentificationLogic.login(
          username: _usename, password: _password, keepLogedIn: keepLogedIn);
      emit(state.copyWith(
          status: AuthentificationStatus.authentificated,
          username: _usename,
          password: _password,
          dartus: _dartus));
    } catch (e) {
      emit(state.copyWith(status: AuthentificationStatus.error));
      return;
    }
  }

  Future<void> forget() async {
    if (kDebugMode) {
      print("forget credential");
    }
    Box<Authentication> authBox =
        await Hive.openBox<Authentication>("authentification");
    authBox.delete("credential");
  }

  Future<void> logout() async {
    if (kDebugMode) {
      print("logout");
    }
    Box<Authentication> authBox =
        await Hive.openBox<Authentication>("authentification");
    authBox.delete("credential");
    CacheService.reset<SchoolSubjectModelWrapper>();
    CacheService.reset<DayModelWrapper>();
    CacheService.reset<EmailModelWrapper>();
    SettingsLogic.reset();
    _usename = "";
    _password = "";
    // await authBox.close();
    if (_dartus != null) {
      await _dartus!.logout();
    }
    emit(state.copyWith(
        status: AuthentificationStatus.needCredential,
        username: "",
        password: "",
        dartus: _dartus));
  }
}
