import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_map_screen.dart';
import 'screens/route_detail_screen.dart';

class MovyPueblaApp extends StatelessWidget {
  const MovyPueblaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovyPuebla',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeMapScreen.routeName: (_) => const HomeMapScreen(),
        RouteDetailScreen.routeName: (_) => const RouteDetailScreen(),
      },
    );
  }
}
