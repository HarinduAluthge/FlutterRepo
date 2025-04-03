import 'package:flutter/material.dart';
import 'package:flutter_application_yes/api_service.dart';

class MCQPage extends StatefulWidget {
  final String topic;
  
  const MCQPage({super.key, required this.topic});

  @override
  State<MCQPage> createState() => _MCQPageState();
}

class _MCQPageState extends State<MCQPage> {
  late Future<List<Map<String, dynamic>>> _mcqsFuture;
  Map<int, String> _selectedAnswers = {};
  Map<int, bool> _isCorrect = {};
  bool _showResults = false;
  
  @override
  void initState() {
    super.initState();
    _mcqsFuture = ApiService.getMCQs(widget.topic);
  }
  
  void _selectAnswer(int questionIndex, String answer) {
    setState(() {
      _selectedAnswers[questionIndex] = answer;
    });
  }
  
  void _checkAnswers(List<Map<String, dynamic>> mcqs) {
    setState(() {
      _isCorrect = {};
      for (int i = 0; i < mcqs.length; i++) {
        if (_selectedAnswers.containsKey(i)) {
          String correctAnswer = mcqs[i]['correctAnswer'];
          _isCorrect[i] = _selectedAnswers[i] == correctAnswer;
        }
      }
      _showResults = true;
    });
  }
  
  void _resetQuiz() {
    setState(() {
      _selectedAnswers = {};
      _isCorrect = {};
      _showResults = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'MCQs: ${widget.topic}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _mcqsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Generating questions...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error generating questions. Please check your internet connection and try again.',
                      style: TextStyle(color: Colors.red[300]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mcqsFuture = ApiService.getMCQs(widget.topic);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3460),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No questions found. Try a different topic.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }
            
            final mcqs = snapshot.data!;
            
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: mcqs.length,
                    itemBuilder: (context, index) {
                      final mcq = mcqs[index];
                      final options = mcq['options'] as List<dynamic>;
                      final selectedAnswer = _selectedAnswers[index];
                      final isAnswered = selectedAnswer != null;
                      final isCorrect = _isCorrect[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: _showResults && isAnswered
                              ? Border.all(
                                  color: isCorrect == true ? Colors.green : Colors.red,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${index + 1}. ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    mcq['question'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...options.map((option) {
                              final isSelected = selectedAnswer == option.substring(0, 1);
                              final isCorrectOption = _showResults && 
                                  mcq['correctAnswer'] == option.substring(0, 1);
                              
                              return GestureDetector(
                                onTap: _showResults ? null : () {
                                  _selectAnswer(index, option.substring(0, 1));
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (_showResults
                                            ? (isCorrect == true
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.red.withOpacity(0.3))
                                            : Colors.blue.withOpacity(0.3))
                                        : (_showResults && isCorrectOption
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.grey[800]),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected || (_showResults && isCorrectOption)
                                        ? Border.all(
                                            color: isSelected
                                                ? (_showResults
                                                    ? (isCorrect == true
                                                        ? Colors.green
                                                        : Colors.red)
                                                    : Colors.blue)
                                                : Colors.green,
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        option,
                                        style: TextStyle(
                                          color: isSelected || (_showResults && isCorrectOption)
                                              ? Colors.white
                                              : Colors.grey[400],
                                          fontWeight: isSelected || (_showResults && isCorrectOption)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (_showResults && isCorrectOption)
                                        const Spacer(),
                                      if (_showResults && isCorrectOption)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      if (_showResults && isSelected && !isCorrectOption)
                                        const Spacer(),
                                      if (_showResults && isSelected && !isCorrectOption)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            if (_showResults)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  isAnswered
                                      ? (isCorrect == true
                                          ? 'Correct!'
                                          : 'Incorrect. The correct answer is ${mcq['correctAnswer']}.')
                                      : 'Not answered',
                                  style: TextStyle(
                                    color: isAnswered
                                        ? (isCorrect == true ? Colors.green : Colors.red)
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showResults
                        ? _resetQuiz
                        : () => _checkAnswers(mcqs),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showResults ? Colors.blue[700] : const Color(0xFF0F3460),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _showResults ? 'Try Again' : 'Check Answers',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

