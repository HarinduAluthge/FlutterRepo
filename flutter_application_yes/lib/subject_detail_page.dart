import 'package:flutter/material.dart';
import 'package:flutter_application_yes/topic_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SubjectDetailPage extends StatefulWidget {
  final String subjectName;
  
  const SubjectDetailPage({
    super.key,
    required this.subjectName,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late String _theoryContent;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _theoryContent = _getMockTheory(widget.subjectName);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      bool isFavorite = false;
      for (var json in favoritesJson) {
        final Map<String, dynamic> data = jsonDecode(json);
        if (data['name'] == widget.subjectName) {
          isFavorite = true;
          break;
        }
      }
      
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      List<Map<String, dynamic>> favorites = [];
      for (var json in favoritesJson) {
        favorites.add(jsonDecode(json) as Map<String, dynamic>);
      }
      
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      if (_isFavorite) {
        // Check if already exists
        if (!favorites.any((f) => f['name'] == widget.subjectName)) {
          favorites.add({
            'name': widget.subjectName,
            'imagePath': _getImagePathForSubject(),
            'rating': 4.8, // Default rating
            'category': 'General', // Default category
          });
        }
      } else {
        favorites.removeWhere((f) => f['name'] == widget.subjectName);
      }
      
      final updatedFavoritesJson = favorites
          .map((f) => jsonEncode(f))
          .toList();
      
      await prefs.setStringList('favorite_subjects', updatedFavoritesJson);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  void _navigateToTopics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicListPage(subject: widget.subjectName),
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
          widget.subjectName,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Add favorite button to app bar for easier access
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getImagePathForSubject()),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subjectName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _toggleFavorite,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _theoryContent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _navigateToTopics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3460),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Explore Topics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImagePathForSubject() {
    final lowerSubject = widget.subjectName.toLowerCase();
    
    if (lowerSubject.contains('physics') || lowerSubject.contains('quantum')) {
      return "assets/quantum_mechanics.jpg";
    } else if (lowerSubject.contains('machine') || lowerSubject.contains('computer') || 
               lowerSubject.contains('data') || lowerSubject.contains('artificial')) {
      return "assets/machine_learning.jpg";
    } else {
      return "assets/astronomy.jpg";
    }
  }
  
  String _getMockTheory(String subject) {
    final Map<String, String> mockTheories = {
      "Astronomy": "Astronomy is the study of celestial objects, space, and the physical universe as a whole. It involves observing and understanding stars, planets, galaxies, and other cosmic phenomena.",
      "Physics": "Physics is the natural science that studies matter, its motion and behavior through space and time, and the related entities of energy and force. It is one of the most fundamental scientific disciplines.",
      "Chemistry": "Chemistry is the scientific discipline involved with elements and compounds composed of atoms, molecules and ions. It covers the composition, structure, properties, behavior and the changes they undergo during a reaction.",
      "Biology": "Biology is the natural science that studies life and living organisms, including their physical structure, chemical processes, molecular interactions, physiological mechanisms, development and evolution.",
      "Computer Science": "Computer Science is the study of computers and computational systems. It involves the theoretical foundations of information and computation, along with practical techniques for their implementation and application.",
      "Mathematics": "Mathematics is the study of numbers, quantity, structure, space, and change. It is essential in many fields, including natural science, engineering, medicine, finance, and the social sciences.",
      "Psychology": "Psychology is the scientific study of the mind and behavior. It explores concepts such as perception, cognition, attention, emotion, intelligence, subjective experiences, motivation, brain functioning, and personality.",
      "History": "History is the study of past events, particularly in human affairs. It examines the continuous, systematic narrative and research of past events as relating to the human race.",
      "Literature": "Literature is the art of written works, and is not bound to published sources. It includes poetry, novels, short stories, plays, and various forms of non-fiction writing.",
      "Economics": "Economics is the social science that studies how people interact with value; in particular, the production, distribution, and consumption of goods and services.",
      "Machine Learning": "Machine Learning is a field of artificial intelligence that uses statistical techniques to give computer systems the ability to learn from data, without being explicitly programmed.",
      "Quantum Physics": "Quantum Physics is a fundamental theory in physics that provides a description of the physical properties of nature at the scale of atoms and subatomic particles.",
      "Data Science": "Data Science is an interdisciplinary field that uses scientific methods, processes, algorithms and systems to extract knowledge and insights from structured and unstructured data.",
      "Astrophysics": "Astrophysics is the branch of astronomy that employs the principles of physics and chemistry to ascertain the nature of astronomical objects and phenomena.",
      "Artificial Intelligence": "Artificial Intelligence is the simulation of human intelligence processes by machines, especially computer systems. These processes include learning, reasoning, and self-correction.",
      "Neuroscience": "Neuroscience is the scientific study of the nervous system. It is a multidisciplinary science that combines physiology, anatomy, molecular biology, developmental biology, cytology, and psychology.",
      "Blockchain": "Blockchain is a system of recording information in a way that makes it difficult or impossible to change, hack, or cheat the system. It is essentially a digital ledger of transactions.",
      "Climate Science": "Climate Science is the study of the Earth's climate and the way it changes over time. It involves understanding the complex interactions between the atmosphere, oceans, land, and ice.",
      "Quantum Computing": "Quantum Computing is a type of computation that harnesses the collective properties of quantum states, such as superposition, interference, and entanglement, to perform calculations.",
      "Robotics": "Robotics is an interdisciplinary branch of engineering and science that includes mechanical engineering, electronic engineering, information engineering, computer science, and others.",
      "Genetic Engineering": "Genetic Engineering is the direct manipulation of an organism's genes using biotechnology. It involves the modification of the genetic material of an organism to achieve desired traits.",
      "Renewable Energy": "Renewable Energy is energy that is collected from renewable resources, which are naturally replenished on a human timescale, such as sunlight, wind, rain, tides, waves, and geothermal heat.",
      "Cybersecurity": "Cybersecurity is the practice of protecting systems, networks, and programs from digital attacks. These cyberattacks are usually aimed at accessing, changing, or destroying sensitive information.",
      "Nanotechnology": "Nanotechnology is the manipulation of matter on an atomic, molecular, and supramolecular scale. It has applications in medicine, electronics, biomaterials, energy production, and consumer products.",
      "Space Exploration": "Space Exploration is the discovery and exploration of outer space by means of space technology. It involves both human spaceflight and robotic space missions.",
      "Bioinformatics": "Bioinformatics is an interdisciplinary field that develops methods and software tools for understanding biological data, particularly when the data sets are large and complex.",
      "Quantum Cryptography": "Quantum Cryptography is the science of exploiting quantum mechanical properties to perform cryptographic tasks. It uses quantum key distribution to secure communication.",
      "Sustainable Development": "Sustainable Development is development that meets the needs of the present without compromising the ability of future generations to meet their own needs."
    };
    
    return mockTheories[subject] ?? 
      "This is an overview of $subject. It covers the fundamental concepts and principles that form the foundation of this field of study.";
  }
}

