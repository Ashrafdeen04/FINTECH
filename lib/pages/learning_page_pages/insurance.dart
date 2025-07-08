import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowfin/budget_generator.dart';
import 'package:knowfin/generate.dart'; // Make sure this import is correct

class InsuranceListPage extends StatefulWidget {
  @override
  _InsuranceListPageState createState() => _InsuranceListPageState();
}

class _InsuranceListPageState extends State<InsuranceListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchInsuranceData() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Insurance').get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      return documents
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching insurance data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insurance Policies'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Main content of the page
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchInsuranceData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching data.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No insurance data found.'));
              } else {
                List<Map<String, dynamic>> insuranceList = snapshot.data!;
                return ListView.builder(
                  itemCount: insuranceList.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> insurance = insuranceList[index];
                    return _buildInsuranceCard(insurance);
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

  Widget _buildInsuranceCard(Map<String, dynamic> insurance) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insurance['title'] ?? 'No Title',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Applicable For:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 5),
            ..._buildList(insurance['applicable_for'] ?? []),
            SizedBox(height: 10),
            Text(
              'Benefits:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 5),
            ..._buildList(insurance['benefits'] ?? []),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList(List<dynamic> items) {
    return items.map((item) => Text('- $item')).toList();
  }
}
