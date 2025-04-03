import 'package:flutter/material.dart';
import 'package:flutter_application_yes/auth.dart';
import 'package:flutter_application_yes/widget_tree.dart';
import 'package:flutter_application_yes/main_navigation.dart';

class ProfilePage extends StatefulWidget {
final bool showBackButton;

const ProfilePage({super.key, this.showBackButton = true});

@override
State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
final user = Auth().currentUser;

Future<void> _signOut() async {
  try {
    await Auth().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WidgetTree()),
        (route) => false,
      );
    }
  } catch (e) {
    debugPrint('Error signing out: $e');
  }
}

String _getUsername() {
  if (user?.email == null) return 'User';
  
  final emailParts = user!.email!.split('@');
  if (emailParts.isEmpty) return 'User';
  
  String username = emailParts[0];
  if (username.isEmpty) return 'User';
  
  return username[0].toUpperCase() + username.substring(1);
}

@override
Widget build(BuildContext context) {
  final username = _getUsername();
  
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.white),
      ),
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                );
              },
            )
          : null,
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileAvatar(),
            const SizedBox(height: 24),
            _buildProfileName(username),
            const SizedBox(height: 8),
            _buildEmailDisplay(),
            const SizedBox(height: 40),
            _buildDivider(),
            const SizedBox(height: 40),
            _buildSignOutButton(),
          ],
        ),
      ),
    ),
  );
}

Widget _buildProfileAvatar() {
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    ),
    child: const Center(
      child: Icon(
        Icons.person,
        size: 70,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildProfileName(String username) {
  return Text(
    username,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _buildEmailDisplay() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.email_outlined,
          color: Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          user?.email ?? 'No email',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDivider() {
  return Row(
    children: [
      Expanded(
        child: Container(
          height: 1,
          color: Colors.grey[800],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Account',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 1,
          color: Colors.grey[800],
        ),
      ),
    ],
  );
}

Widget _buildSignOutButton() {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.red.shade800,
          Colors.red.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _signOut,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

