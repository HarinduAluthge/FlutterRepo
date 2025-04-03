import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subject_detail_page.dart';
import 'dart:convert';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _favoriteSubjects = [];
  bool _isLoading = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFavorites();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavorites();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _debugInfo = '';
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      setState(() {
        _debugInfo = 'Found ${favoritesJson.length} favorites in SharedPreferences';
      });
      
      if (favoritesJson.isEmpty) {
        setState(() {
          _favoriteSubjects = [];
          _isLoading = false;
        });
        return;
      }
      
      List<Map<String, dynamic>> favorites = [];
      for (var json in favoritesJson) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          favorites.add(data);
        } catch (e) {
          setState(() {
            _debugInfo += '\nError parsing JSON: $e';
          });
        }
      }
      
      if (mounted) {
        setState(() {
          _favoriteSubjects = favorites;
          _isLoading = false;
          _debugInfo += '\nParsed ${favorites.length} favorites successfully';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _debugInfo += '\nError loading favorites: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(String subjectName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      List<Map<String, dynamic>> favorites = [];
      for (var json in favoritesJson) {
        favorites.add(jsonDecode(json) as Map<String, dynamic>);
      }
      
      favorites.removeWhere((f) => f['name'] == subjectName);
      
      final updatedFavoritesJson = favorites
          .map((f) => jsonEncode(f))
          .toList();
      
      await prefs.setStringList('favorite_subjects', updatedFavoritesJson);
      
      setState(() {
        _favoriteSubjects = favorites;
      });
    } catch (e) {
      setState(() {
        _debugInfo += '\nError removing favorite: $e';
      });
    }
  }

  // Add this method to manually add a test favorite
  Future<void> _addTestFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_subjects') ?? [];
      
      List<Map<String, dynamic>> favorites = [];
      for (var json in favoritesJson) {
        favorites.add(jsonDecode(json) as Map<String, dynamic>);
      }
      
      // Add a test favorite
      favorites.add({
        'name': 'Test Subject',
        'imagePath': 'assets/astronomy.jpg',
        'rating': 4.5,
        'category': 'Test',
      });
      
      final updatedFavoritesJson = favorites
          .map((f) => jsonEncode(f))
          .toList();
      
      await prefs.setStringList('favorite_subjects', updatedFavoritesJson);
      
      _loadFavorites();
    } catch (e) {
      setState(() {
        _debugInfo += '\nError adding test favorite: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Add debug button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFavorites,
          ),
          // Add test favorite button
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addTestFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug info
          if (_debugInfo.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Debug Info: $_debugInfo',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _favoriteSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              color: Colors.grey,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No favorites added yet',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add subjects to your favorites to see them here',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _favoriteSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = _favoriteSubjects[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubjectDetailPage(
                                    subjectName: subject['name'],
                                  ),
                                ),
                              ).then((_) => _loadFavorites()); // Refresh favorites when returning
                            },
                            child: Container(
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
                                          subject['imagePath'] ?? 'assets/astronomy.jpg',
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
                                          onTap: () => _removeFavorite(subject['name']),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
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
                                            subject['name'],
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
                                          subject['category'] ?? 'General',
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
                                          (subject['rating'] ?? 4.5).toString(),
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

