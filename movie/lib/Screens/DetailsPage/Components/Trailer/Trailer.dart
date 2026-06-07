import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerPage extends StatefulWidget {
  final String videoId;
  final String movieName;

  const TrailerPage({Key? key, required this.videoId, required this.movieName})
    : super(key: key);

  @override
  _TrailerPageState createState() => _TrailerPageState();
}

class _TrailerPageState extends State<TrailerPage> {
  late YoutubePlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        loop: false,
        forceHD: false,
      ),
    )..addListener(() {
      if (_controller.value.errorCode != null &&
          _controller.value.errorCode != 0) {
        setState(() {
          _isError = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "${widget.movieName} Trailer",
          style: TextStyle(
            color: HexColor("#7220C9"),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _isError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Failed to load trailer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Go Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: HexColor("#7220C9"),
                  progressColors: ProgressBarColors(
                    playedColor: HexColor("#7220C9"),
                    handleColor: HexColor("#7220C9"),
                  ),
                  onReady: () {
                    _controller.play();
                  },
                  onEnded: (metaData) {
                    Navigator.of(context).pop();
                  },
                ),
                builder: (context, player) {
                  return Center(child: player);
                },
              ),
    );
  }
}
