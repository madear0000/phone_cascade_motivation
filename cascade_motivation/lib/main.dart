import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
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
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.amber[400],
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
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
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
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

  List<Widget> _pages() {
    return [
      _buildHomePage(),
      TimerScreen(onComplete: _addPoints, onFinishTask: _addCompletedTask),
      _buildProgressPage(),
    ];
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      // <-- Добавляем возможность прокрутки
      child: Column(
        children: [
          Container(
            height: 200,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Card(
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
                const Row(
                  children: [
                    Text(
                      "Как это работает?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 40), // Добавляем отступ внизу
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.amber),
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
                    ),
                  ),
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
                  const SizedBox(height: 10),
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
                        color: Colors.white,
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
                                      style: TextStyle(color: Colors.white),
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
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: "Cascade Motivation",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(
                  Icons.rocket_launch,
                  color: Colors.amber,
                ),
                children: [
                  const Text("Приложение для повышения продуктивности"),
                  Text(
                    "Ваши баллы: $_points",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Задача'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Прогресс',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;

  TextEditingController _taskController = TextEditingController();
  int _timeInSeconds = 0;
  String? _difficulty;
  Timer? _timer;
  int _remaining = 0;
  bool _taskActive = false;
  bool _showTaskField = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    var initSettings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    _notificationsPlugin.initialize(initSettings);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _taskActive = true;
      _remaining = _timeInSeconds;
      _showTaskField = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        _showNotification();
        _showCompletionDialog();
        widget.onComplete(_calculatePoints());
        widget.onFinishTask(_taskController.text);
        timer.cancel();
        setState(() {
          _taskActive = false;
          _showTaskField = true;
        });
      }
      setState(() => _remaining--);
    });
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
    var details = const AndroidNotificationDetails(
      "task_complete",
      "Task Completion",
      importance: Importance.high,
      color: Colors.amber,
      enableLights: true,
      playSound: true,
    );
    await _notificationsPlugin.show(
      0,
      "Задача завершена!",
      "Вы большой молодец, можете отдохнуть!",
      NotificationDetails(android: details),
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
                  const Text(
                    "Отличная работа! Продолжай в том же духе.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
                      "Ок",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _cancelTimer() {
    _timer?.cancel();
    setState(() {
      _taskActive = false;
      _showTaskField = true;
    });
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showTaskField) ...[
                    const Text(
                      "Название задачи",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: "Например: Сделать домашку",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? "Введите название задачи"
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Сложность задачи",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _difficulty,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      items:
                          ["Легкая", "Средняя", "Сложная"]
                              .map(
                                (d) =>
                                    DropdownMenuItem(value: d, child: Text(d)),
                              )
                              .toList(),
                      validator:
                          (value) =>
                              value == null
                                  ? "Выберите уровень сложности"
                                  : null,
                      onChanged: (val) => setState(() => _difficulty = val),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Время на выполнение (в секундах)",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Например: 120",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return "Введите корректное число > 0";
                        }
                        return null;
                      },
                      onChanged:
                          (val) => _timeInSeconds = int.tryParse(val) ?? 0,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_taskActive) ...[
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: _remaining / _timeInSeconds,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.amber[400]!,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(_remaining),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[400],
                                    ),
                                  ),
                                  Text(
                                    _taskController.text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Сложность: $_difficulty",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.amber[400],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _cancelTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Отменить"),
                          ),
                        ],
                      ),
                    ),
                  ] else if (!_showTaskField) ...[
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 60,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Готово!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Вы получили ${_calculatePoints()} баллов",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                () => setState(() => _showTaskField = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Новая задача"),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Запустить задачу",
                          style: TextStyle(fontSize: 18),
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

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
