import 'package:flutter/material.dart';
import 'package:flutter_application_yes/api_service.dart';
import 'package:flutter_application_yes/theory_page.dart';
import 'package:flutter_application_yes/mcq_page.dart';
import 'package:flutter_application_yes/summary_page.dart';

class TopicListPage extends StatefulWidget {
  final String subject;
  
  const TopicListPage({super.key, required this.subject});

  @override
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage> {
  late Future<List<String>> _topicsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _topicsFuture = ApiService.getTopics(widget.subject);
  }

  void _navigateToTheory(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TheoryPage(topic: topic),
      ),
    );
  }

  void _navigateToSummary(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(topic: topic),
      ),
    );
  }

  void _navigateToMCQ(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MCQPage(topic: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Topics in ${widget.subject}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore ${widget.subject} Topics',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a topic to learn more',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _topicsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Generating topics...',
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
                            'Error generating topics. Please check your internet connection and try again.',
                            style: TextStyle(color: Colors.red[300]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _topicsFuture = ApiService.getTopics(widget.subject);
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
                        'No topics found. Try a different subject.',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  
                  final topics = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                topic,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                onPressed: () => _navigateToTheory(topic),
                              ),
                              onTap: () => _navigateToTheory(topic),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _navigateToSummary(topic),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[800],
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Summary'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _navigateToMCQ(topic),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[800],
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('MCQs'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

