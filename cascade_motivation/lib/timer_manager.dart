import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TimerManager {
  static final TimerManager _instance = TimerManager._internal();
  factory TimerManager() => _instance;
  TimerManager._internal();

  Timer? _timer;
  int _remainingSeconds = 0;
  Function(int)? _onTick;
  Function()? _onComplete;
  String? _taskName;
  String? _difficulty;

  Future<void> startTimer({
    required int seconds,
    required String taskName,
    required String difficulty,
    required void Function(int) onTick,
    required void Function() onComplete,
  }) async {
    _remainingSeconds = seconds;
    _taskName = taskName;
    _difficulty = difficulty;
    _onTick = onTick;
    _onComplete = onComplete;

    await _saveState();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _remainingSeconds--;
      _onTick?.call(_remainingSeconds);
      await _saveState();

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onComplete?.call();
        await _clearState();
      }
    });
  }

  Future<void> stopTimer() async {
    _timer?.cancel();
    _timer = null;
    await _clearState();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remaining_seconds', _remainingSeconds);
    await prefs.setString('task_name', _taskName ?? '');
    await prefs.setString('difficulty', _difficulty ?? '');
  }

  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remaining_seconds');
    await prefs.remove('task_name');
    await prefs.remove('difficulty');
  }

  Future<bool> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _remainingSeconds = prefs.getInt('remaining_seconds') ?? 0;
    _taskName = prefs.getString('task_name');
    _difficulty = prefs.getString('difficulty');
    return _remainingSeconds > 0;
  }

  bool get isActive => _timer != null;
  int get remainingSeconds => _remainingSeconds;
  String? get taskName => _taskName;
  String? get difficulty => _difficulty;
}
