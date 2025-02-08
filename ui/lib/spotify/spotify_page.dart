import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Song {
  final String name;
  final String spotifyUri;

  Song({
    required this.name,
    required this.spotifyUri,
  });
}

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  List<Song> songs = [];
  int currentSongIndex = 0;
  final String defaultCover = '../assets/cover.png';

  @override
  void initState() {
    super.initState();
    analyzeAndFetchSongs();
  }

  Future<void> analyzeAndFetchSongs() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'video_path': 'C:/Users/jurae/Desktop/EmoDrive/backend/data/video.webm'
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> recommendations = jsonResponse['recommendations'];

      setState(() {
        songs = recommendations.map((song) {
          return Song(
            name: song['track_name'] ?? 'Unknown Song',
            spotifyUri: song['track_id'] ?? '',
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load songs');
    }
  }

  void playSong(int index) {
    setState(() {
      currentSongIndex = index;
    });
  }

  void showPlaylistBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Makes the corners rounded.
      isScrollControlled: true, // Full height for a larger playlist window.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          height:
              MediaQuery.of(context).size.height * 0.6, // 60% of screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: const Text(
                  'Playlist',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              defaultCover,
                              width: 50,
                              height: 70,
                            ),
                          ),
                          title: Text(
                            song.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Artist Name", // Replace with song.artist if available
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.white),
                            onPressed: () {
                              // Favorite song logic
                            },
                          ),
                          onTap: () {
                            playSong(index);
                            Navigator.of(context).pop();
                          },
                        ),
                        if (index <
                            songs.length -
                                1) // Add divider except for the last item
                          Divider(
                            color: Colors.grey[800],
                            height: 1,
                            thickness: 1,
                            indent: 70,
                            endIndent: 10,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color(0xFF2E2B5F),
              Color(0xFF1C1C1C),
            ])),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spotify PLayer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
            // Album art display
            SizedBox(
              height: 400,
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(defaultCover),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Song title and artist name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    songs.isNotEmpty
                        ? songs[currentSongIndex].name
                        : 'No song selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // MiniPlayer at the bottom
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Color(0xFF2E2B5F),
                    Color(0xFF1C1C1C),
                  ])),
              child: MiniPlayer(
                song: songs.isNotEmpty ? songs[currentSongIndex] : null,
                onShowPlaylist: showPlaylistBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniPlayer extends StatefulWidget {
  final Song? song;
  final VoidCallback onShowPlaylist;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.onShowPlaylist,
  });

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  double _currentProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF2E2B5F), 
            Color(0xFF1C1C1C),
          ])
        ),
      padding: const EdgeInsets.all(16.0),
      // color: Colors.grey[900],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar with time indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '00:00',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              Expanded(
                child: Slider(
                  value: _currentProgress,
                  onChanged: (value) {
                    setState(() {
                      _currentProgress = value;
                    });
                  },
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.white.withOpacity(0.3),
                ),
              ),
              Text(
                '03:46',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
          // Main player controls
          Row(
            children: [
              // Album art
              Image.asset(
                '../assets/cover.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 10),
              // Song title and artist name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song?.name ?? 'No song selected',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Heart button
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // Logic for liking the song
                },
              ),
              // Playback controls
              IconButton(
                icon:
                    const Icon(Icons.skip_previous, color: Colors.greenAccent),
                onPressed: () {
                  // Logic for previous song
                },
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.greenAccent),
                onPressed: () {
                  // Logic for play/pause
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.greenAccent),
                onPressed: () {
                  // Logic for next song
                },
              ),
              IconButton(
                icon: const Icon(Icons.list, color: Colors.greenAccent),
                onPressed: widget.onShowPlaylist,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
