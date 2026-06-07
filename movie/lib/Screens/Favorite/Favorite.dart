import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/Util/ApiService.dart';
import 'package:movie_app/main.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => FavoriteState();
}

class FavoriteState extends State<Favorite>
    with SingleTickerProviderStateMixin {
  List<String> watchlistMovies = [];
  List<String> watchlistTitles = [];
  List<String> watchlistImages = [];
  List<Map<String, String>> watchedList = [];
  bool isLoading = true;
  String errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void reloadData() {
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (authToken == null || authToken!.isEmpty) {
      setState(() {
        errorMessage = 'Please log in to view your favorites.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await Future.wait([_loadWatchlist(), _loadWatched()]);
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadWatchlist() async {
    bool success = await ApiService.fetchWatchlist();
    if (success) {
      setState(() {
        watchlistMovies = preferences.getStringList('savedmoviehistory') ?? [];
        watchlistTitles = preferences.getStringList('movienames') ?? [];
        watchlistImages = preferences.getStringList('posters') ?? [];
      });
    } else {
      throw Exception('Failed to load watchlist');
    }
  }

  Future<void> _loadWatched() async {
    var data = await ApiService.fetchWatched();
    setState(() {
      watchedList = data;
    });
  }

  Future<void> _removeFromWatchlist(String movieId) async {
    bool success = await ApiService.removeFromWatchlist(movieId);
    if (success) {
      int index = watchlistMovies.indexOf(movieId);
      if (index != -1) {
        setState(() {
          watchlistMovies.removeAt(index);
          watchlistTitles.removeAt(index);
          watchlistImages.removeAt(index);
          preferences.setStringList('savedmoviehistory', watchlistMovies);
          preferences.setStringList('movienames', watchlistTitles);
          preferences.setStringList('posters', watchlistImages);
        });
      }
    }
  }

  Future<void> _removeFromWatched(String movieId) async {
    bool success = await ApiService.removeFromWatched(movieId);
    if (success) {
      await _loadWatched();
    }
  }

  Widget _buildMovieCard(
    String title,
    String imageUrl,
    String id,
    bool isWatchlist,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: HexColor("#1F1F1F"),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child:
                imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w154$imageUrl',
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            width: 80,
                            height: 120,
                            color: HexColor("#7220C9").withOpacity(0.3),
                            child: const Icon(
                              Icons.movie_outlined,
                              color: Colors.white70,
                              size: 40,
                            ),
                          ),
                    )
                    : Container(
                      width: 80,
                      height: 120,
                      color: HexColor("#7220C9").withOpacity(0.3),
                      child: const Icon(
                        Icons.movie_outlined,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isWatchlist ? 'In Watchlist' : 'Like',
                        style: TextStyle(
                          color: HexColor("#7220C9"),
                          fontSize: 14,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            isWatchlist
                                ? _removeFromWatchlist(id)
                                : _removeFromWatched(id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[300],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Remove",
                                  style: TextStyle(
                                    color: Colors.red[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 70,
            color: HexColor("#7220C9").withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to discover or home page
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor("#7220C9"),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Discover Movies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: HexColor("#7220C9")),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Favorites',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: HexColor("#7220C9"),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#7220C9"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: HexColor("#7220C9"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: HexColor("#1F1F1F"),
            child: TabBar(
              controller: _tabController,
              indicatorColor: HexColor("#7220C9"),
              indicatorWeight: 3,
              labelColor: HexColor("#7220C9"),
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              tabs: const [
                Tab(icon: Icon(Icons.bookmark), text: 'Watchlist', height: 60),
                Tab(icon: Icon(Icons.favorite), text: 'Like', height: 60),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Watchlist Tab
                Container(
                  color: Colors.black,
                  child:
                      watchlistMovies.isEmpty
                          ? _buildEmptyState(
                            'Your watchlist is empty.\nAdd movies to watch later!',
                          )
                          : RefreshIndicator(
                            onRefresh: _loadWatchlist,
                            color: HexColor("#7220C9"),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: watchlistMovies.length,
                              itemBuilder: (context, index) {
                                return _buildMovieCard(
                                  watchlistTitles[index],
                                  watchlistImages[index],
                                  watchlistMovies[index],
                                  true,
                                );
                              },
                            ),
                          ),
                ),

                // Watched Tab
                Container(
                  color: Colors.black,
                  child:
                      watchedList.isEmpty
                          ? _buildEmptyState(
                            'You haven\'t marked any movies as liked yet.',
                          )
                          : RefreshIndicator(
                            onRefresh: _loadWatched,
                            color: HexColor("#7220C9"),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: watchedList.length,
                              itemBuilder: (context, index) {
                                var movie = watchedList[index];
                                return _buildMovieCard(
                                  movie['movie_title']!,
                                  movie['poster_path']!,
                                  movie['movie_id']!,
                                  false,
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
