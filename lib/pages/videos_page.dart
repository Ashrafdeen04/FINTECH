import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class YouTubeSearchPage extends StatefulWidget {
  @override
  _YouTubeSearchPageState createState() => _YouTubeSearchPageState();
}

class _YouTubeSearchPageState extends State<YouTubeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _videos = [];
  bool _isLoading = false;
  final String _apiKey = 'AIzaSyA6naDEsKTjx6QORRc2OkPZaC-YaWHI49Q';
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  @override
  void initState() {
    super.initState();
    _searchVideos(); // Fetch videos related to Indian financial literacy on initialization
  }

  Future<void> _searchVideos() async {
    final query = 'Indian financial literacy'; // Predefined query
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
        '$_baseUrl?part=snippet&type=video&q=$query&maxResults=10&key=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _videos = data['items'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _videos = [];
        _isLoading = false;
      });
      print('Failed to load videos: ${response.statusCode}');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video Search'),
        automaticallyImplyLeading: false, // Remove back arrow
        elevation: 0, // Optional: Remove shadow under the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Videos',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed:
                      _searchVideos, // You can still allow manual search if needed
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _videos.isEmpty
                      ? Center(child: Text('No videos found'))
                      : ListView.builder(
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            final videoTitle = video['snippet']['title'];
                            final videoId = video['id']['videoId'];
                            final videoThumbnail = video['snippet']
                                ['thumbnails']['default']['url'];
                            final videoUrl =
                                'https://www.youtube.com/watch?v=$videoId';

                            return ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: videoThumbnail,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              title: Text(videoTitle),
                              subtitle: Text(videoUrl),
                              onTap: () => _launchURL(videoUrl),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
