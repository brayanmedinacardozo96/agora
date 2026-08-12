import 'package:agora/features/ballot/presentation/screens/ballot_screen.dart';
import 'package:agora/features/import/presentation/screens/import_screen.dart';
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
import 'package:agora/features/survey_manager/presentation/screens/survey_list_screen.dart';
import 'package:agora/features/survey_manager/presentation/screens/create_survey_screen.dart';
import 'package:agora/features/survey_manager/presentation/screens/survey_detail_screen.dart';
import 'package:agora/features/survey_manager/presentation/screens/fieldwork_screen.dart';
import 'package:agora/features/survey_manager/presentation/screens/survey_responses_screen.dart';
import 'package:agora/features/voter_management/presentation/screens/voter_list_screen.dart';
import 'package:agora/features/voter_management/presentation/screens/send_message_screen.dart';
import 'package:agora/features/voter_management/presentation/screens/voting_stats_screen.dart';

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
      // Survey Manager Routes
      '/surveys': (BuildContext context) => const SurveyListScreen(),
      '/create-survey': (BuildContext context) => const CreateSurveyScreen(),
      '/survey-detail': (BuildContext context) {
        final survey =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return SurveyDetailScreen(survey: survey ?? {});
      },
      '/fieldwork': (BuildContext context) {
        final survey =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return FieldworkScreen(survey: survey ?? {});
      },
      '/survey-responses': (BuildContext context) {
        final survey =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return SurveyResponsesScreen(survey: survey ?? {});
      },
      // Voter Management Routes
      '/voter-list': (BuildContext context) => const VoterListScreen(),
      '/send-message': (BuildContext context) => const SendMessageScreen(),
      '/voting-stats': (BuildContext context) => const VotingStatsScreen(),
    };
  }
}
