import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber[700],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _points = 0;
  final List<String> _completedTasks = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _timerManager = TimerManager();

  final List<String> _motivationalPhrases = [
    "Ты можешь больше, чем думаешь!",
    "Начни сейчас, идеального момента не будет.",
    "Маленькие шаги ведут к большим результатам!",
    "Фокусируйся на цели, а не на препятствиях.",
    "Не бойся ошибок — они часть пути к успеху.",
    "Каждый день — новый шанс стать лучше!",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMotivation() {
    final random = Random();
    String phrase =
        _motivationalPhrases[random.nextInt(_motivationalPhrases.length)];

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 60, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    "Мотивация",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    phrase,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Спасибо!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addPoints(int points) {
    setState(() => _points += points);
  }

  void _addCompletedTask(String name) {
    setState(() => _completedTasks.add(name));
  }

  Widget _buildHomePage() {
    final scrollController = ScrollController();
    final focusNode = FocusNode();

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            scrollController.animateTo(
              scrollController.offset + 100,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            scrollController.animateTo(
              scrollController.offset - 100,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        }
      },
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Баннер с активным таймером
            if (_timerManager.isActive)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[700]!, Colors.amber[400]!],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Активная задача: ${_timerManager.taskName}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_timerManager.remainingSeconds} сек',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Градиентный заголовок
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[700]!, Colors.amber[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Cascade Motivation",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Достигай большего каждый день",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Контентная часть
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Анимированная карточка совета
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 40,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Совет дня",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Разбейте большую задачу на несколько маленьких. "
                              "Выполняя их по очереди, вы достигнете цели быстрее!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Кнопка мотивации
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showMotivation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 10),
                          Text(
                            "Получить мотивацию",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Карточки фич приложения
                  _buildFeatureCard(
                    icon: Icons.timer,
                    title: "Установите таймер",
                    description: "Выберите время для выполнения задачи",
                  ),
                  _buildFeatureCard(
                    icon: Icons.star,
                    title: "Получайте баллы",
                    description: "Чем сложнее задача, тем больше баллов",
                  ),
                  _buildFeatureCard(
                    icon: Icons.insights,
                    title: "Следите за прогрессом",
                    description: "Накапливайте баллы и улучшайте результаты",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для создания карточек фич (должен быть в том же классе)
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.amber),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Ваш прогресс",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: _points / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber[400]!,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$_points",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                          const Text(
                            "баллов",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Выполненные задачи",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          _completedTasks.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Здесь будут ваши выполненные задачи",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                itemCount: _completedTasks.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.check_circle,
                                      color: Colors.amber[400],
                                    ),
                                    title: Text(
                                      _completedTasks[index],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cascade Motivation"),
        actions: [
          if (_timerManager.isActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('${_timerManager.remainingSeconds} сек'),
                ],
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          TimerScreen(onComplete: _addPoints, onFinishTask: _addCompletedTask),
          _buildProgressPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.amber[400],
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Задача'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Прогресс',
          ),
        ],
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final Function(int) onComplete;
  final Function(String) onFinishTask;

  const TimerScreen({
    super.key,
    required this.onComplete,
    required this.onFinishTask,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _timerManager = TimerManager();
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;
  TextEditingController _taskController = TextEditingController();
  String? _difficulty;
  int _timeInSeconds = 0;
  bool _showTaskField = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final hasActiveTimer = await _timerManager.loadState();
    if (hasActiveTimer && mounted) {
      setState(() {
        _taskController.text = _timerManager.taskName ?? '';
        _difficulty = _timerManager.difficulty;
        _timeInSeconds = _timerManager.remainingSeconds;
        _showTaskField = false;
      });

      _timerManager.startTimer(
        seconds: _timerManager.remainingSeconds,
        taskName: _timerManager.taskName ?? '',
        difficulty: _timerManager.difficulty ?? '',
        onTick: (remaining) => setState(() {}),
        onComplete: _completeTask,
      );
    }
  }

  void _startTimer() {
    if (!_formKey.currentState!.validate()) return;

    _timerManager.startTimer(
      seconds: _timeInSeconds,
      taskName: _taskController.text,
      difficulty: _difficulty ?? '',
      onTick: (remaining) => setState(() {}),
      onComplete: _completeTask,
    );

    setState(() => _showTaskField = false);
  }

  void _completeTask() {
    _showNotification();
    _showCompletionDialog();
    widget.onComplete(_calculatePoints());
    widget.onFinishTask(_taskController.text);
    setState(() => _showTaskField = true);
  }

  int _calculatePoints() {
    switch (_difficulty) {
      case "Легкая":
        return 5;
      case "Средняя":
        return 10;
      case "Сложная":
        return 20;
      default:
        return 0;
    }
  }

  Future<void> _showNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Задача завершена!',
      'Вы успешно выполнили задачу "${_taskController.text}"',
      platformChannelSpecifics,
    );
  }

  void _showCompletionDialog() {
    _confettiController.play();
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, size: 60, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    "🎉 Задача завершена!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Вы получили ${_calculatePoints()} баллов!",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Отлично!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_showTaskField) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _taskController,
                              decoration: const InputDecoration(
                                labelText: 'Название задачи',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Введите название'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _difficulty,
                              decoration: const InputDecoration(
                                labelText: 'Сложность',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items:
                                  ['Легкая', 'Средняя', 'Сложная']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (value) =>
                                      setState(() => _difficulty = value),
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Выберите сложность'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Время (сек)',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                final v = int.tryParse(value ?? '');
                                return v == null || v <= 0
                                    ? 'Введите число > 0'
                                    : null;
                              },
                              onChanged:
                                  (value) =>
                                      _timeInSeconds = int.tryParse(value) ?? 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Запустить таймер',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Выполняется задача',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: Colors.amber[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _taskController.text,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 4,
                                ),
                              ),
                              child: Text(
                                '${_timerManager.remainingSeconds}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Сложность: ${_difficulty}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _timerManager.stopTimer();
                                      setState(() => _showTaskField = true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[400],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Отменить'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.amber,
              Colors.white,
              Colors.orange,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _taskController.dispose();
    super.dispose();
  }
}
