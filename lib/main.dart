/*
*     Bro thinks he can get the device token like:
*     SALIM BEN AMMAR
* */


import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/providers/firebase_provider.dart';
import 'app/providers/laravel_provider.dart';
import 'app/routes/theme1_app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/services/firebase_messaging_service.dart';
import 'app/services/global_service.dart';
import 'app/services/settings_service.dart';
import 'app/services/translation_service.dart';
import 'pharmacies/providers/pharmacies_laravel_provider.dart';

Future<void> initServices() async {
  Get.log('starting services ...');
  await GetStorage.init();


  await Get.putAsync(() => GlobalService().init());
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LfDxaMqAAAAAFugNEGu8dd6N47wwRrQoBVFuiy5'), // Site key goes here
    androidProvider: AndroidProvider.playIntegrity,  // Play Integrity for Android
  );
  await Get.putAsync(() => FireBaseMessagingService().init());
  // Register AuthService before LaravelApiClient since it depends on AuthService
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => LaravelApiClient().init());
  await Get.putAsync(() => FirebaseProvider().init());
  await Get.putAsync(() => SettingsService().init());
  await Get.putAsync(() => PharmaciesLaravelApiClient().init());
  await Get.putAsync(() => TranslationService().init());

  Get.log('All services started...');
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServices();
  final authService = Get.find<AuthService>(); // Get the AuthService instance
  final settingsService = Get.find<SettingsService>(); // Get the SettingsService instance*/

  runApp(
    GetMaterialApp(
      title: settingsService.setting.value.appName ?? '', // Access the setting from SettingsService
      initialRoute: Theme1AppPages.INITIAL,
      onReady: () async {
        await Get.putAsync(() => FireBaseMessagingService().init());
        await setDeviceToken();
      },
      getPages: Theme1AppPages.routes,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: Get.find<TranslationService>().supportedLocales(),
      translationsKeys: Get.find<TranslationService>().translations,
      locale: Get.find<TranslationService>().getLocale(),
      fallbackLocale: Get.find<TranslationService>().getLocale(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      themeMode: settingsService.getThemeMode(),
      theme: settingsService.getLightTheme(),
      darkTheme: settingsService.getDarkTheme(),
    ),
  );
}

Future<String?> setDeviceToken() async {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final fCMToken = await _firebaseMessaging.getToken();
  if (fCMToken != null) {
    print('Token: $fCMToken');
    return fCMToken;
  } else {
    print('Failed to retrieve FCM token');
  }
  return fCMToken;// Return the token
}


class PlayIntegrityService {
  static const platform = MethodChannel('com.wic_doc/play_integrity');

  Future<String?> getPlayIntegrityToken() async {
    try {
      final String result = await platform.invokeMethod('getPlayIntegrityToken');
      return result;
    } on PlatformException catch (e) {
      print("Error getting Play Integrity token: ${e.message}");
      return null;
    }
  }
}

