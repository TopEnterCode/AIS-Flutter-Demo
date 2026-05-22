import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'services/ld_service.dart';
import 'services/ld_context_factory.dart';

// LD best practice: initialise LDClient ONCE, await before runApp()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedSdkKey = prefs.getString('ld_sdk_key');

  // LDService.create() initialises the real LDClient when an SDK key is
  // available, or falls back to mock/demo mode when it is not.
  final ldService = await LDService.create(
    sdkKey: savedSdkKey,
    initialContext: LDContextFactory.defaultContext,
  );

  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider.value: LDService was already created above;
        // we hand the existing instance to the tree without re-creating it.
        ChangeNotifierProvider.value(value: ldService),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(prefs)),
      ],
      child: const AISApp(),
    ),
  );
}
