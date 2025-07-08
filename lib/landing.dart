import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/learning_page.dart';
import 'pages/quiz_page.dart';
import 'pages/videos_page.dart';
import 'pages/consultancy_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  String _username = '';

  final List<Widget> _pages = [
    LearningPage(),
    QuizPage(),
    YouTubeSearchPage(),
    ConsultantPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      setState(() {
        _username = email.split('@')[0]; // Extract the part before '@'
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context)
          .pushReplacementNamed('/signin'); // Adjust the route if needed
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 20, 10, 163),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/user_avatar.png'),
            ),
            SizedBox(width: 10),
            Text(_username.isNotEmpty ? _username : 'User',
                style: TextStyle(
                  color: Color.fromARGB(255, 228, 228, 239),
                )),
            Spacer(),
            // Row(
            //   children: [
            //     Icon(Icons.star, color: Colors.yellow),
            //     Text("0", style: TextStyle(fontSize: 18)),
            //   ],
            // ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Learning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Consultancy',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
