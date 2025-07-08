import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowfin/budget_generator.dart';

class TaxationPage extends StatefulWidget {
  @override
  _TaxationPageState createState() => _TaxationPageState();
}

class _TaxationPageState extends State<TaxationPage> {
  late Future<Map<String, dynamic>> _taxationData;

  @override
  void initState() {
    super.initState();
    _taxationData = _fetchTaxationData();
  }

  Future<Map<String, dynamic>> _fetchTaxationData() async {
    try {
      // Fetch data from Firebase
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('TaxationIndia')
          .doc('Taxation Rules')
          .get();

      // Check if the document exists
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxation Rules'),
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _taxationData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data available'));
              } else {
                final data = snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final title = data.keys.elementAt(index);
                    final description = data[title] as String;

                    return ListTile(
                      title: Text(title),
                      subtitle: Text(description),
                    );
                  },
                );
              }
            },
          ),
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
