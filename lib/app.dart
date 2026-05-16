import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/config_provider.dart';
import 'providers/history_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'services/feedback_service.dart';
import 'services/prefs_service.dart';
import 'services/sensor_service.dart';
import 'services/session_repository.dart';

class SquatCounterApp extends StatelessWidget {
  const SquatCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorService = SensorService();
    final feedbackService = FeedbackService()..init();
    final sessionRepository = SessionRepository();
    final prefsService = PrefsService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConfigProvider(prefsService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(
            sensorService: sensorService,
            feedback: feedbackService,
            repository: sessionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(sessionRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Squat Counter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
