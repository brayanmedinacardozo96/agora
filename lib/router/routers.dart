import 'package:agora/features/ballot/presentation/screens/ballot_screen.dart';
import 'package:agora/features/import/presentation/screens/import_screen.dart';
import 'package:agora/features/voting/presentation/screens/register_screen.dart';
import 'package:agora/features/result/presentation/screens/map_screen.dart';
import 'package:agora/features/result/presentation/screens/export_screen.dart';
import 'package:agora/features/user/presentation/screens/user_screen.dart';
import 'package:agora/features/voter_query/presentation/screens/voter_query_screen.dart';
import 'package:agora/features/voter_query/presentation/screens/voter_table_results_screen.dart';
import 'package:agora/features/voting/presentation/screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:agora/features/auth/presentation/screens/login_screen.dart';
import 'package:agora/features/auth/presentation/screens/register_screen.dart';
import 'package:agora/features/home/presentation/screens/home_screen.dart';
import 'package:agora/features/result/presentation/screens/dashboard_screen.dart';

class Routers {
  static Map<String, WidgetBuilder> routers(BuildContext context) {
    return <String, WidgetBuilder>{
      '/login': (BuildContext context) => const LoginScreen(),
      '/sign-up': (BuildContext context) => const RegisterScreen(),
      '/home': (BuildContext context) => const HomeScreen(),
      '/voting': (BuildContext context) =>
          CedulaScannerApp(), //const RegistroUsuarioScreen(),
      '/dashboard': (BuildContext context) => const DashboardResultadosApp(),
      '/map': (BuildContext context) => const MapaResultadosApp(),
      '/export': (BuildContext context) => const ExportarResultadosApp(),
      '/ballot': (BuildContext context) => const VotacionConfigApp(),
      '/user': (BuildContext context) => const GestionUsuariosApp(),
      '/voter-query': (BuildContext context) => const ConsultaVotantesApp(),
      '/voter-table-results': (BuildContext context) =>
          const VoterTableResultsApp(),
      '/import': (BuildContext context) => const ImportarDatosApp(),
    };
  }
}
