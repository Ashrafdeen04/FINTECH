import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowfin/budget_generator.dart';
import 'package:knowfin/generate.dart'; // Ensure this import is correct

class SchemesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Government Schemes'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Main content of the page
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Schemes').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No data available'));
              } else {
                final schemes = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: schemes.length,
                  itemBuilder: (context, index) {
                    final scheme =
                        schemes[index].data() as Map<String, dynamic>;

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scheme['name'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Description: ${scheme['description'] ?? 'No Description'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Eligibility: ${scheme['eligibility'] ?? 'No Eligibility Information'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Benefits: ${scheme['benefits'] ?? 'No Benefits Information'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Application Process: ${scheme['application_process'] ?? 'No Application Process Information'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          // Static chatbot icon at the bottom right
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.chat_bubble, size: 30, color: Colors.teal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
