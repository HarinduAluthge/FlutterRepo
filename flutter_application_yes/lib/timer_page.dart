import 'package:flutter/material.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Timer & Stopwatch',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'Stopwatch'),
            Tab(text: 'Timer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StopwatchTab(),
          TimerTab(),
        ],
      ),
    );
  }
}

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = '00:00:00';
  List<String> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _updateElapsedTime();
      });
    }
  }

  void _stopStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      setState(() {});
    }
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _laps.clear();
    _updateElapsedTime();
  }

  void _addLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _elapsedTime);
      });
    }
  }

  void _updateElapsedTime() {
    final milliseconds = _stopwatch.elapsedMilliseconds;
    final hours = (milliseconds / (1000 * 60 * 60)).floor();
    final minutes = ((milliseconds / (1000 * 60)) % 60).floor();
    final seconds = ((milliseconds / 1000) % 60).floor();
    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = seconds.toString().padLeft(2, '0');
    
    setState(() {
      _elapsedTime = '$formattedHours:$formattedMinutes:$formattedSeconds';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Text(
              _elapsedTime,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                onPressed: _resetStopwatch,
                icon: Icons.refresh,
                label: 'Reset',
                color: Colors.grey,
              ),
              _buildButton(
                onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                label: _stopwatch.isRunning ? 'Pause' : 'Start',
                color: _stopwatch.isRunning ? Colors.red : Colors.green,
              ),
              _buildButton(
                onPressed: _addLap,
                icon: Icons.flag,
                label: 'Lap',
                color: Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: 4,
          child: _laps.isEmpty
              ? Center(
                  child: Text(
                    'No laps recorded',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: _laps.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child: Text(
                          '${_laps.length - index}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        _laps[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: color,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  bool _showNotification = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) {
      _remainingSeconds = _hours * 3600 + _minutes * 60 + _seconds;
      if (_remainingSeconds <= 0) return;
    }

    setState(() {
      _isRunning = true;
      _showNotification = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showNotification = true;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      _showNotification = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final hours = (totalSeconds / 3600).floor();
    final minutes = ((totalSeconds / 60) % 60).floor();
    final seconds = totalSeconds % 60;
    
    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = seconds.toString().padLeft(2, '0');
    
    return '$formattedHours:$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: _isRunning || _remainingSeconds > 0
                    ? Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      )
                    : _buildTimePicker(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    onPressed: _resetTimer,
                    icon: Icons.refresh,
                    label: 'Reset',
                    color: Colors.grey,
                  ),
                  _buildButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    label: _isRunning ? 'Pause' : 'Start',
                    color: _isRunning ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
        if (_showNotification)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Time is up!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showNotification = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimePickerColumn(
          value: _hours,
          maxValue: 23,
          label: 'Hours',
          onChanged: (value) {
            setState(() {
              _hours = value;
            });
          },
        ),
        const Text(
          ':',
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildTimePickerColumn(
          value: _minutes,
          maxValue: 59,
          label: 'Minutes',
          onChanged: (value) {
            setState(() {
              _minutes = value;
            });
          },
        ),
        const Text(
          ':',
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildTimePickerColumn(
          value: _seconds,
          maxValue: 59,
          label: 'Seconds',
          onChanged: (value) {
            setState(() {
              _seconds = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimePickerColumn({
    required int value,
    required int maxValue,
    required String label,
    required Function(int) onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 40),
          onPressed: () {
            onChanged((value < maxValue) ? value + 1 : 0);
          },
        ),
        Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 40),
          onPressed: () {
            onChanged((value > 0) ? value - 1 : maxValue);
          },
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: color,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

