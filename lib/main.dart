import 'package:flutter/material.dart';
import 'api/api_client.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'widgets/admin_home.dart';
import 'widgets/agent_home.dart';
import 'widgets/feed_page.dart';
import 'widgets/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().updateBaseUrl();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citi Aid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF136AF6)),
        fontFamily: 'Inter',
      ),
      home: const _AppEntryPoint(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint();

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
  final AuthService _authService = AuthService();
  late final Future<UserModel?> _storedUserFuture;

  @override
  void initState() {
    super.initState();
    _storedUserFuture = _authService.getStoredUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _storedUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF136AF6),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        if (user.isAdmin) {
          return const AdminHomePage();
        }
        if (user.isAgent) {
          return const AgentHomePage();
        }
        return const FeedPage();
      },
    );
  }
}