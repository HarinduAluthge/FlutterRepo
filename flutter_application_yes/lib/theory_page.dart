import 'package:flutter/material.dart';
import 'api_service.dart';

class TheoryPage extends StatefulWidget {
  final String topic;
  const TheoryPage({super.key, required this.topic});

  @override
  TheoryPageState createState() => TheoryPageState();
}

class TheoryPageState extends State<TheoryPage> {
  late Future<String> _theory;

  @override
  void initState() {
    super.initState();
    _theory = ApiService.getTheory(widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Theory: ${widget.topic}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _theory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Generating theory...',
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
                      'Error generating theory. Please check your internet connection and try again.',
                      style: TextStyle(color: Colors.red[300]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _theory = ApiService.getTheory(widget.topic);
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
            }
            return SingleChildScrollView(
              child: Text(
                snapshot.data ?? 'No theory available',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}

