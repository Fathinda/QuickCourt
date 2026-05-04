import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import 'providers/venue_provider.dart';
// import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'route/route_constants.dart';
import 'route/router.dart' as router;
import 'theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  
  await initializeDateFormatting('id_ID', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(   
      providers: [
        ChangeNotifierProvider(create: (_) => VenueProvider()), 
      ],
      
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Booking App',
        theme: AppTheme.lightTheme(context),
        darkTheme: AppTheme.darkTheme(context),
        themeMode: ThemeMode.system,
        onGenerateRoute: router.generateRoute,
        initialRoute: splashScreenRoute,
      ),
    );
  }
}
