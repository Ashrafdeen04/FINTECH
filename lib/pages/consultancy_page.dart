import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsultantPage extends StatefulWidget {
  @override
  _ConsultantPageState createState() => _ConsultantPageState();
}

class _ConsultantPageState extends State<ConsultantPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _consultants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConsultants();
  }

  Future<void> _fetchConsultants() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Consultant').get();
      List<Map<String, dynamic>> consultants = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _consultants = consultants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching consultants: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultants'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _consultants.isEmpty
              ? Center(child: Text('No consultants available'))
              : ListView.builder(
                  itemCount: _consultants.length,
                  itemBuilder: (context, index) {
                    final consultant = _consultants[index];
                    final name = consultant['name'];
                    final description = consultant['description'];
                    final contact = consultant['contact'];
                    final photoUrl = consultant['photo'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CachedNetworkImage(
                          imageUrl: photoUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(description),
                            SizedBox(height: 8),
                            InkWell(
                              child: Text(
                                'Contact',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onTap: () {
                                // Launch the contact URL
                                _launchURL(contact);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
