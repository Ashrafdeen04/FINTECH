import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class BookScreen extends StatefulWidget {
  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  String? selectedAdhigaram;
  String? selectedKuralNumber;

  // State variable to store clicked words and their meanings
  Map<String, String> clickedWords = {};

  final Map<String, Map<String, int>> adhigaramRanges = {
    'அகர முதல': {'start': 1, 'end': 10},
    'வான் சிறப்பு': {'start': 11, 'end': 20},
    'நீத்தார் பெருமை': {'start': 21, 'end': 30},
    'அறன் வலியுறுத்தல்': {'start': 31, 'end': 40},
    'இல்வாழ்க்கை': {'start': 41, 'end': 50},
    'வாழ்க்கைத் துணைநலம்': {'start': 51, 'end': 60},
    'மகளிர் பிறப்பு': {'start': 61, 'end': 70},
    'சேவகம்': {'start': 71, 'end': 80},
    'சொல்வன்மை': {'start': 81, 'end': 90},
    'பெரியாரைத் துணைக்கோடல்': {'start': 91, 'end': 100},
  };

  Future<void> fetchWordMeaning(String word) async {
    final response = await http.post(
      Uri.parse('https://kavi22ad.pythonanywhere.com/predict'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'word': word}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String predictedMeaning = responseData['meaning'];

      setState(() {
        clickedWords[word] = predictedMeaning;
      });
    } else {
      throw Exception('Failed to load meaning');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: Text('Tirukkural'),
            backgroundColor: Colors.teal,
            elevation: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedAdhigaram,
                      hint: Text('Select Adhigaram'),
                      isExpanded: true,
                      items: adhigaramRanges.keys.map((String adhigaram) {
                        return DropdownMenuItem<String>(
                          value: adhigaram,
                          child: Text(adhigaram),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedAdhigaram = newValue;
                          selectedKuralNumber = null;
                          clickedWords.clear();
                        });
                      },
                    ),
                    if (selectedAdhigaram != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<String>(
                          value: selectedKuralNumber,
                          hint: Text('Select Kural Number'),
                          isExpanded: true,
                          items: _getKuralNumbers(selectedAdhigaram!)
                              .map((String kural) {
                            return DropdownMenuItem<String>(
                              value: kural,
                              child: Text(kural),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedKuralNumber = newValue;
                              clickedWords.clear();
                            });
                          },
                        ),
                      ),
                    if (selectedKuralNumber != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Tirukural')
                            .doc(selectedKuralNumber)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Center(child: Text('No Kural available.'));
                          }

                          var document = snapshot.data!;
                          var kuralData =
                              document.data() as Map<String, dynamic>;
                          var kuralText = kuralData.values.first;
                          var splitKuralText = kuralText.split(r'$');

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tirukkural',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildClickableText(splitKuralText[0]),
                              _buildClickableText(splitKuralText[1]),
                            ],
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Lemma')
                          .doc(selectedKuralNumber)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(child: Text('No Lemma available.'));
                        }
                        var document = snapshot.data!;
                        var lemmaData = document.data() as Map<String, dynamic>;
                        var lemmaText = lemmaData.values.first;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lemma easy to read',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildClickableText(lemmaText),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    if (clickedWords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clicked Words and Meanings:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              height: 450,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.teal.withOpacity(0.1),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Center(
                                                  child: Text('Word',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text('Meaning',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                          Expanded(
                                              child: Center(
                                                  child: Text('Delete',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: clickedWords.length,
                                        itemBuilder: (context, index) {
                                          List<String> reversedKeys =
                                              clickedWords.keys
                                                  .toList()
                                                  .reversed
                                                  .toList();
                                          String word = reversedKeys[index];
                                          String meaning = clickedWords[word]!;
                                          return ListTile(
                                            title: Row(
                                              children: [
                                                Expanded(child: Text(word)),
                                                Expanded(
                                                    child: Text(
                                                  meaning,
                                                  style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.grey),
                                                )),
                                                IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    setState(() {
                                                      clickedWords.remove(word);
                                                    });
                                                  },
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            right: 1,
            child: IconButton(
              icon: Icon(Icons.chat_bubble, size: 30, color: Colors.teal),
              onPressed: () {
                // Action for chat bubble button
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getKuralNumbers(String adhigaram) {
    int start = adhigaramRanges[adhigaram]!['start']!;
    int end = adhigaramRanges[adhigaram]!['end']!;
    return List<String>.generate(
      end - start + 1,
      (index) => (start + index).toString(),
    );
  }

  Widget _buildClickableText(String text) {
    final words = text.split(' ');

    return Wrap(
      spacing: 1,
      runSpacing: 1,
      children: words.map((word) {
        return InkWell(
          onTap: () {
            fetchWordMeaning(word);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              word,
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
                decoration:
                    TextDecoration.underline, // Underline clickable text
                fontWeight: FontWeight.bold, // Bold for emphasis
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
