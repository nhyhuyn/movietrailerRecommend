// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names, missing_required_param

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/component/LanguageChips.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/Component/GenreChips.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:movie_app/Screens/Home/ExtendedComponents/FetchHorizontalMovieList.dart';
import 'package:movie_app/Screens/MoreMoviesPage/MoreMoviesPage.dart';
import 'package:movie_app/Screens/Search/Component/SearchQuerys.dart';
import 'package:movie_app/Screens/Splash/SplashScreen.dart';
import 'package:movie_app/Util/ApiService.dart';
import 'package:movie_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class CollaborativeHomePage extends StatefulWidget {
  const CollaborativeHomePage({super.key});

  @override
  State<CollaborativeHomePage> createState() => _CollaborativeHomePageState();
}

class _CollaborativeHomePageState extends State<CollaborativeHomePage> {
  late Timer timer;
  List<Map<String, dynamic>> recommendedMovies = []; // Store recommended movies

  String primary_url =
      "https://api.themoviedb.org/3/discover/movie?api_key=dbda4bb34573ea2b68379f1e476c3933&with_genres=";
  String secondary_url =
      "https://api.themoviedb.org/3/movie/popular?api_key=dbda4bb34573ea2b68379f1e476c3933&with_original_language=";

  @override
  void initState() {
    super.initState();

    // Load user data and fetch recommendations
    _loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init();
      await _fetchRecommendations(); // Fetch recommendations on init
    });

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {}); // Periodic UI refresh
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _loadUserData() {
    if (authToken != null) {
      if (persistedGenres.isEmpty || persistedLanguages.isEmpty) {
        ApiService.fetchPreferences().then((success) {
          if (success && mounted) {
            setState(() {});
          }
        });
      }
      _fetchRecommendations(); // Fetch recommendations when user data changes
    }
  }

  // Fetch recommendations based on watched movies
  Future<void> _fetchRecommendations() async {
    if (authToken == null) {
      print('No auth token available');
      return;
    }

    try {
      final data = await ApiService.getRecommendations();
      if (mounted) {
        setState(() {
          recommendedMovies = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error loading recommendations: $e');
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  static Future init() async {
    preferences = await SharedPreferences.getInstance();
    persistedGenres = preferences.getStringList('_keygenres') ?? [];
    persistedLanguages = preferences.getStringList('_language') ?? [];
    remembermovies = preferences.getStringList('savedmoviehistory') ?? [];
    recommemdedmovieimages =
        preferences.getStringList('recommemdedmovieimages') ?? [];
    recommemdedmovienames =
        preferences.getStringList('recommemdedmovietitles') ?? [];
    searchdata = preferences.getStringList('searchdatas') ?? [];
    images = preferences.getStringList('posters') ?? [];
    title = preferences.getStringList('movienames') ?? [];
    username = preferences.getString('keyusername') ?? "";

    recommemdedmovieimages = recommemdedmovieimages.reversed.toList();
    recommemdedmovienames = recommemdedmovienames.reversed.toList();
    remembermovies = remembermovies.reversed.toList();
    searchdata = searchdata.reversed.toList();
    images = images.reversed.toList();
    title = title.reversed.toList();
  }

  Map<String, int> genres_ids = {
    'Adventure': 12,
    'Fantasy': 14,
    'Animation': 16,
    'Drama': 18,
    'Horror': 27,
    'Action': 28,
    'Comedy': 35,
    'History': 36,
    'Western': 37,
    'Thriller': 53,
    'Crime': 80,
    'Documentary': 99,
    'Science Fiction': 878,
    'Mystery': 9648,
    'Music': 10402,
    'Romance': 10749,
    'Family': 10751,
    'War': 10752,
    'TV Movie': 10770,
  };

  Map<String, String> language_codes = {
    'English': "en",
    'Mandarin Chinese': "zh",
    'Spanish': "es",
    'Hindi': "hi",
    'Arabic': "ar",
    'French': "fr",
    'Bengali': "bn",
    'Russian': "ru",
    'Portuguese': "pt",
    'Japanese': "ja",
    'German': "de",
    'Korean': "ko",
    'Vietnamese': "vi",
  };

  Widget buildRecommend() {
    if (recommendedMovies.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 168.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return Shimmer.fromColors(
              period: const Duration(milliseconds: 2000),
              baseColor: HexColor("#8970A4"),
              direction: ShimmerDirection.ltr,
              highlightColor: HexColor("#463567"),
              child: Container(
                width: 118,
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.purple[200]!,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 168.0,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recommendedMovies.length,
          itemBuilder: (BuildContext context, int index) {
            final movie = recommendedMovies[index];
            final posterPath =
                movie['poster_path'] != null
                    ? "https://image.tmdb.org/t/p/w780${movie['poster_path']}"
                    : '';
            final title =
                movie['title'] ?? movie['original_title'] ?? 'Unknown';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPageBody(moviename: title),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 10,
                  width: 100, // Adjusted width for better display
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        posterPath.isEmpty
                            ? Image.asset(
                              "assets/images/loading.png",
                              fit: BoxFit.cover,
                            )
                            : FadeInImage.assetNetwork(
                              image: posterPath,
                              placeholder: "assets/images/loading.png",
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                print("Image load failed: $error");
                                return Image.asset(
                                  "assets/images/loading.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget watchlist() {
    if (images.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 168.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return Shimmer.fromColors(
              period: const Duration(milliseconds: 2000),
              baseColor: HexColor("#8970A4"),
              direction: ShimmerDirection.ltr,
              highlightColor: HexColor("#463567"),
              child: Container(
                width: 118,
                margin: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.purple[200]!,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: 168.0,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (BuildContext context, int index) {
            String imageUrl = images[index].toString();
            bool isValidUrl =
                imageUrl.startsWith('http') &&
                (imageUrl.contains('.jpg') ||
                    imageUrl.contains('.jpeg') ||
                    imageUrl.contains('.png') ||
                    imageUrl.contains('image'));

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            DetailsPageBody(moviename: title[index].toString()),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 10,
                  width: 100, // Adjusted width
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        imageUrl.isEmpty || !isValidUrl
                            ? Image.asset(
                              "assets/images/loading.png",
                              fit: BoxFit.cover,
                            )
                            : FadeInImage.assetNetwork(
                              image: imageUrl,
                              placeholder: "assets/images/loading.png",
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                print("Image load failed: $error");
                                return Image.asset(
                                  "assets/images/loading.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 4),
          gethead(),
          getlatest(
            "Top Movies of 2025",
            "https://api.themoviedb.org/3/discover/movie?api_key=dbda4bb34573ea2b68379f1e476c3933&primary_release_date.gte=2020-01-01&primary_release_year=2025",
            "",
          ),
          SizedBox(height: 4),
          recommendedMovies.isEmpty
              ? SizedBox()
              : TopShimmerWithoutURL("Recommended Movies for You"),
          recommendedMovies.isEmpty ? SizedBox() : buildRecommend(),
          images.isEmpty ? SizedBox() : TopShimmerWithoutURL("Watchlist"),
          images.isEmpty ? SizedBox() : watchlist(),
          getlatest(
            "Top Rated",
            "https://api.themoviedb.org/3/movie/top_rated?api_key=dbda4bb34573ea2b68379f1e476c3933&language=en-US&page=2",
            "",
          ),
          persistedGenres.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                      bottom: 5.0,
                    ),
                    child: Text(
                      "Favorite Genres",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: persistedGenres.length,
                    itemBuilder: (BuildContext context, int index) {
                      return getlatest(
                        persistedGenres[index].toString(),
                        primary_url +
                            fetch_genreid(persistedGenres[index]).toString(),
                        "",
                      );
                    },
                  ),
                ],
              )
              : FilterChipDisplay.filters.isNotEmpty
              ? ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: FilterChipDisplay.filters.length,
                itemBuilder: (BuildContext context, int index) {
                  return getlatest(
                    FilterChipDisplay.filters[index].toString(),
                    primary_url +
                        fetch_genreid(
                          FilterChipDisplay.filters[index],
                        ).toString(),
                    "",
                  );
                },
              )
              : Container(),
          persistedLanguages.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                      bottom: 5.0,
                    ),
                    child: Text(
                      "Preferred Languages",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: persistedLanguages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return getlatest(
                        persistedLanguages[index].toString(),
                        secondary_url +
                            fetchlanguage_code(
                              persistedLanguages[index],
                            ).toString(),
                        "",
                      );
                    },
                  ),
                ],
              )
              : LanguageChips.languages.isNotEmpty
              ? ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: LanguageChips.languages.length,
                itemBuilder: (BuildContext context, int index) {
                  return getlatest(
                    LanguageChips.languages[index].toString(),
                    secondary_url +
                        fetchlanguage_code(
                          LanguageChips.languages[index],
                        ).toString(),
                    "",
                  );
                },
              )
              : Container(),
        ],
      ),
    );
  }

  String fetchlanguage_code(String language) {
    return language_codes[language] ?? "";
  }

  String fetch_genreid(String m) {
    return genres_ids[m]?.toString() ?? "";
  }

  Widget getlatest(name, url, recentname) {
    return Container(
      child: Column(
        children: [
          TopShimmer(name, url),
          FetchHorizontalMovieList(url: url, recentname: recentname),
        ],
      ),
    );
  }

  Widget TopShimmer(name, url) {
    return Container(
      margin: EdgeInsets.only(top: 15, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 25,
                width: 5,
                margin: EdgeInsets.only(right: 8, left: 2),
                decoration: BoxDecoration(color: HexColor("#7220C9")),
              ),
              Shimmer.fromColors(
                period: Duration(milliseconds: 2000),
                baseColor: Colors.grey[100]!,
                direction: ShimmerDirection.ltr,
                highlightColor: Colors.grey[800]!,
                child: Container(
                  width: 250,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: InkWell(
              highlightColor: Colors.grey,
              hoverColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MoreMoviesPage(url: url, originalmoviename: name),
                  ),
                );
              },
              child: Text(
                "See More",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget TopShimmerWithoutURL(name) {
    return Container(
      margin: EdgeInsets.only(top: 15, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 25,
                width: 5,
                margin: EdgeInsets.only(right: 8, left: 2),
                decoration: BoxDecoration(color: HexColor("#7220C9")),
              ),
              Shimmer.fromColors(
                period: Duration(milliseconds: 2000),
                baseColor: Colors.grey[100]!,
                direction: ShimmerDirection.ltr,
                highlightColor: Colors.grey[800]!,
                child: Container(
                  width: 250,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget gethead() {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 43,
                width: 43,
                child: Image(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/logo.png"),
                ),
              ),
              SizedBox(width: 3),
              Shimmer.fromColors(
                period: Duration(milliseconds: 2000),
                baseColor: Colors.grey[100]!,
                direction: ShimmerDirection.ltr,
                highlightColor: Colors.grey[800]!,
                child: Container(
                  margin: EdgeInsets.only(top: 3),
                  child: const Text(
                    "Movie App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            highlightColor: Colors.grey,
            hoverColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchQuery()),
              );
            },
            child: const Icon(Icons.search, color: Colors.white, size: 28.0),
          ),
        ],
      ),
    );
  }
}
