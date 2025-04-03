import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_yes/subject_detail_page.dart';
import 'package:flutter_application_yes/topic_list_page.dart';
import 'package:flutter_application_yes/profile_page.dart';
import 'package:flutter_application_yes/recent_searches_page.dart';
import 'package:flutter_application_yes/favorites_page.dart';
import 'package:flutter_application_yes/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth.dart';

class HomePage extends StatefulWidget {
const HomePage({super.key});

@override
State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? _user = Auth().currentUser;
  final TextEditingController _subjectController = TextEditingController();
  int _selectedTabIndex = 0;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  List<Subject> _mostViewedSubjects = [
    Subject(
      name: "Astronomy", 
      imagePath: "assets/astronomy.jpg",
      rating: 4.8,
      category: "Cosmic Phenomena",
    ),
    Subject(
      name: "Physics", 
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.6,
      category: "Science",
    ),
    Subject(
      name: "Chemistry", 
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.5,
      category: "Science",
    ),
    Subject(
      name: "Biology", 
      imagePath: "assets/astronomy.jpg",
      rating: 4.7,
      category: "Life Science",
    ),
    Subject(
      name: "Computer Science", 
      imagePath: "assets/machine_learning.jpg",
      rating: 4.9,
      category: "Technology",
    ),
    Subject(
      name: "Mathematics", 
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.7,
      category: "Fundamental Science",
    ),
    Subject(
      name: "Psychology", 
      imagePath: "assets/astronomy.jpg",
      rating: 4.4,
      category: "Social Science",
    ),
    Subject(
      name: "History", 
      imagePath: "assets/machine_learning.jpg",
      rating: 4.3,
      category: "Humanities",
    ),
    Subject(
      name: "Literature", 
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.2,
      category: "Arts",
    ),
    Subject(
      name: "Economics", 
      imagePath: "assets/astronomy.jpg",
      rating: 4.5,
      category: "Social Science",
    ),
  ];

  List<Subject> _trendingSubjects = [
    Subject(
      name: "Machine Learning",
      imagePath: "assets/machine_learning.jpg",
      rating: 4.9,
      category: "Technology",
    ),
    Subject(
      name: "Quantum Physics",
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.7,
      category: "Physics",
    ),
    Subject(
      name: "Data Science",
      imagePath: "assets/astronomy.jpg",
      rating: 4.8,
      category: "Technology",
    ),
    Subject(
      name: "Astrophysics",
      imagePath: "assets/astronomy.jpg",
      rating: 4.6,
      category: "Astronomy",
    ),
    Subject(
      name: "Artificial Intelligence",
      imagePath: "assets/machine_learning.jpg",
      rating: 4.9,
      category: "Computer Science",
    ),
    Subject(
      name: "Neuroscience",
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.5,
      category: "Biology",
    ),
    Subject(
      name: "Blockchain",
      imagePath: "assets/astronomy.jpg",
      rating: 4.4,
      category: "Technology",
    ),
    Subject(
      name: "Climate Science",
      imagePath: "assets/machine_learning.jpg",
      rating: 4.7,
      category: "Environmental Science",
    ),
    Subject(
      name: "Quantum Computing",
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.8,
      category: "Computer Science",
    ),
    Subject(
      name: "Robotics",
      imagePath: "assets/astronomy.jpg",
      rating: 4.6,
      category: "Engineering",
    ),
  ];

  List<Subject> _latestSubjects = [
    Subject(
      name: "Blockchain",
      imagePath: "assets/machine_learning.jpg",
      rating: 4.5,
      category: "Technology",
    ),
    Subject(
      name: "Genetic Engineering",
      imagePath: "assets/astronomy.jpg",
      rating: 4.6,
      category: "Biology",
    ),
    Subject(
      name: "Artificial Intelligence",
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.9,
      category: "Computer Science",
    ),
    Subject(
      name: "Renewable Energy",
      imagePath: "assets/astronomy.jpg",
      rating: 4.7,
      category: "Environmental Science",
    ),
    Subject(
      name: "Cybersecurity",
      imagePath: "assets/machine_learning.jpg",
      rating: 4.8,
      category: "Computer Science",
    ),
    Subject(
      name: "Nanotechnology",
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.6,
      category: "Engineering",
    ),
    Subject(
      name: "Space Exploration",
      imagePath: "assets/astronomy.jpg",
      rating: 4.9,
      category: "Astronomy",
    ),
    Subject(
      name: "Bioinformatics",
      imagePath: "assets/machine_learning.jpg",
      rating: 4.5,
      category: "Biology",
    ),
    Subject(
      name: "Quantum Cryptography",
      imagePath: "assets/quantum_mechanics.jpg",
      rating: 4.7,
      category: "Computer Science",
    ),
    Subject(
      name: "Sustainable Development",
      imagePath: "assets/astronomy.jpg",
      rating: 4.4,
      category: "Environmental Science",
    ),
  ];

  Map<String, bool> _favoriteStatus = {};

  final List<String> _tabs = ["Most Viewed", "Trending", "Latest"];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _subjectController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload favorites when the page is focused
    _loadFavorites();
  }

  void _onSearchChanged() {
    if (_subjectController.text.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    
    _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    final query = _subjectController.text;
    if (query.isEmpty) return;
    
    try {
      final suggestions = await ApiService.getSubjectSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      Map<String, bool> favorites = {};
      for (var json in favoritesJson) {
        final Map<String, dynamic> data = jsonDecode(json);
        favorites[data['name']] = true;
      }
      
      setState(() {
        _favoriteStatus = favorites;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Toggle favorite status
  void _toggleFavorite(Subject subject) async {
    final isFavorite = _favoriteStatus[subject.name] ?? false;
    
    setState(() {
      if (isFavorite) {
        _favoriteStatus.remove(subject.name);
      } else {
        _favoriteStatus[subject.name] = true;
      }
    });
    
    await _saveFavorites(subject, !isFavorite);
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites(Subject subject, bool add) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      List<Map<String, dynamic>> favorites = [];
      for (var json in favoritesJson) {
        favorites.add(jsonDecode(json) as Map<String, dynamic>);
      }
      
      if (add) {
        // Check if already exists
        if (!favorites.any((f) => f['name'] == subject.name)) {
          favorites.add({
            'name': subject.name,
            'imagePath': subject.imagePath,
            'rating': subject.rating,
            'category': subject.category,
          });
        }
      } else {
        favorites.removeWhere((f) => f['name'] == subject.name);
      }
      
      final updatedFavoritesJson = favorites
          .map((f) => jsonEncode(f))
          .toList();
      
      await prefs.setStringList('favorite_subjects', updatedFavoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  void _searchTopics(String subject) async {
    if (subject.isEmpty) return;
    
    await _saveRecentSearch(subject);
    
    setState(() {
      _showSuggestions = false;
    });
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicListPage(subject: subject),
      ),
    );
  }

  Future<void> _saveRecentSearch(String searchTerm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      List<String> searchesJson = prefs.getStringList('recent_searches') ?? [];
      List<Map<String, dynamic>> searches = searchesJson
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
      
      final newSearch = {
        'term': searchTerm,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      searches.removeWhere((s) => s['term'] == searchTerm);
      
      searches.insert(0, newSearch);
      
      final updatedSearchesJson = searches
          .map((s) => jsonEncode(s))
          .toList();
      
      await prefs.setStringList('recent_searches', updatedSearchesJson);
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showSuggestions = false;
          });
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildGreeting(),
                const SizedBox(height: 4),
                _buildTagline(),
                const SizedBox(height: 24),
                _buildSearchField(),
                if (_showSuggestions) _buildSuggestionsList(),
                const SizedBox(height: 32),
                _buildRecentSearchesHeader(),
                const SizedBox(height: 16),
                _buildTabs(),
                const SizedBox(height: 20),
                _buildSubjectGrid(),
                const SizedBox(height: 80), // Add extra bottom padding for the navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    String firstName = _user?.email?.split('@').first ?? 'User';
    firstName = firstName.isNotEmpty 
        ? firstName[0].toUpperCase() + firstName.substring(1) 
        : 'User';
    
    return Row(
      children: [
        Text(
          "Hi, $firstName ",
          style: const TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          "👋",
          style: TextStyle(fontSize: 28),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      "Read, Revise, Recall",
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a subject',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 20),
              ),
              onSubmitted: (value) => _searchTopics(value),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              onPressed: () => _searchTopics(_subjectController.text),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _suggestions.map((suggestion) => ListTile(
          title: Text(
            suggestion,
            style: const TextStyle(color: Colors.white),
          ),
          leading: const Icon(Icons.search, color: Colors.grey),
          onTap: () {
            _subjectController.text = suggestion;
            _searchTopics(suggestion);
          },
        )).toList(),
      ),
    );
  }

  Widget _buildRecentSearchesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Searches",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecentSearchesPage()),
            );
          },
          child: Text(
            "View all",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedTabIndex == index 
                    ? Colors.grey[900] 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedTabIndex == index 
                      ? Colors.transparent 
                      : Colors.grey[800]!,
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: _selectedTabIndex == index 
                      ? Colors.white 
                      : Colors.grey[500],
                  fontWeight: _selectedTabIndex == index 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectGrid() {
    List<Subject> currentSubjects;
    
    switch (_selectedTabIndex) {
      case 1:
        currentSubjects = _trendingSubjects;
        break;
      case 2:
        currentSubjects = _latestSubjects;
        break;
      default:
        currentSubjects = _mostViewedSubjects;
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentSubjects.length,
      itemBuilder: (context, index) {
        final subject = currentSubjects[index];
        final isFavorite = _favoriteStatus[subject.name] ?? false;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailPage(
                  subjectName: subject.name,
                ),
              ),
            ).then((_) => _loadFavorites()); // Refresh favorites when returning
          },
          child: SubjectCard(
            subject: subject,
            isFavorite: isFavorite,
            onToggleFavorite: _toggleFavorite,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }
}

class Subject {
  final String name;
  final String imagePath;
  final double rating;
  final String category;

  const Subject({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.category,
  });
  
  // Add these methods for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'rating': rating,
      'category': category,
    };
  }

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      imagePath: json['imagePath'] ?? "assets/astronomy.jpg",
      rating: json['rating'] ?? 4.5,
      category: json['category'] ?? "General",
    );
  }
}

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final bool isFavorite;
  final Function(Subject) onToggleFavorite;

  const SubjectCard({
    required this.subject,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  subject.imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Add favorite button overlay
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => onToggleFavorite(subject),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    subject.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  subject.category,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  subject.rating.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

