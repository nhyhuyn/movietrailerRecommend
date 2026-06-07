// ignore_for_file: unused_import

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String apiBaseUrl = "http://10.103.101.235:5000/api";

  // Đồng bộ thể loại phim yêu thích
  static Future<bool> syncPreferencesToServer() async {
    if (authToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/preferences/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'genres': persistedGenres,
          'languages': persistedLanguages, // Thêm ngôn ngữ để đồng bộ
        }),
      );

      if (response.statusCode == 200) {
        print('Preferences synced successfully');
        return true;
      } else {
        print('Failed to sync preferences: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error syncing preferences: $e');
      return false;
    }
  }

  // Thêm phim vào danh sách xem sau
  static Future<bool> addToWatchlist(
    String movieId,
    String movieTitle,
    String posterPath,
  ) async {
    if (authToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/watchlist/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'movie_id': movieId,
          'movie_title': movieTitle,
          'poster_path': posterPath,
        }),
      );

      if (response.statusCode == 200) {
        // Cập nhật SharedPreferences
        if (!remembermovies.contains(movieId)) {
          remembermovies.add(movieId);
          title.add(movieTitle);
          images.add(posterPath);

          await preferences.setStringList('savedmoviehistory', remembermovies);
          await preferences.setStringList('movienames', title);
          await preferences.setStringList('posters', images);
        }
        return true;
      } else {
        print('Failed to add to watchlist: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding to watchlist: $e');
      return false;
    }
  }

  static Future<bool> syncWatchedMovie(
    String movieId,
    String movieTitle,
    String posterPath,
  ) async {
    if (authToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/like/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'movie_id': movieId,
          'movie_title': movieTitle,
          'poster_path': posterPath,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to add to watched list: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding to watched list: $e');
      return false;
    }
  }

  static Future<List<Map<String, String>>> fetchWatched() async {
    if (authToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/like'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Map<String, String>> watchedList = [];

        for (var movie in data) {
          watchedList.add({
            'movie_id': movie['movie_id']?.toString() ?? '',
            'movie_title': movie['movie_title'] ?? '',
            'poster_path': movie['poster_path'] ?? '',
          });
        }

        return watchedList;
      } else {
        print('Failed to fetch watched list: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching watched list: $e');
      return [];
    }
  }

  // Xóa phim khỏi danh sách watched (Không cập nhật SharedPreferences)
  static Future<bool> removeFromWatched(String movieId) async {
    if (authToken == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/user/like/remove/$movieId'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove from watched: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing from watched: $e');
      return false;
    }
  }

  static Future<bool> removeFromWatchlist(String movieId) async {
    if (authToken == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/user/watchlist/remove/$movieId'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove from watched: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error removing from watched: $e');
      return false;
    }
  }

  // Lấy phim đề xuất từ server
  static Future<List> getRecommendations() async {
    if (authToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/recommendations/based-on-watched'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Lưu vào SharedPreferences
        List<String> movieNames = [];
        List<String> movieImages = [];

        for (var movie in data) {
          if (movie['title'] != null) movieNames.add(movie['title']);
          if (movie['poster_path'] != null)
            movieImages.add(movie['poster_path']);
        }

        await preferences.setStringList('recommemdedmovietitles', movieNames);
        await preferences.setStringList('recommemdedmovieimages', movieImages);

        // Cập nhật biến toàn cục
        recommemdedmovienames = movieNames;
        recommemdedmovieimages = movieImages;

        return data;
      } else {
        print('Failed to get recommendations: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  // Lấy thông tin watchlist từ server
  static Future<bool> fetchWatchlist() async {
    if (authToken == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/watchlist'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> movieIds = [];
        List<String> movieTitles = [];
        List<String> posterPaths = [];

        for (var movie in data) {
          if (movie['movie_id'] != null) movieIds.add(movie['movie_id']);
          if (movie['movie_title'] != null)
            movieTitles.add(movie['movie_title']);
          if (movie['poster_path'] != null)
            posterPaths.add(movie['poster_path']);
        }

        // Cập nhật SharedPreferences
        await preferences.setStringList('savedmoviehistory', movieIds);
        await preferences.setStringList('movienames', movieTitles);
        await preferences.setStringList('posters', posterPaths);

        // Cập nhật biến toàn cục
        remembermovies = movieIds;
        title = movieTitles;
        images = posterPaths;

        return true;
      } else {
        print('Failed to fetch watchlist: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
      return false;
    }
  }

  // Lấy thông tin preferences từ server
  static Future<bool> fetchPreferences() async {
    if (authToken == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/preferences'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> genres = List<String>.from(data['genres'] ?? []);
        List<String> languages = List<String>.from(data['languages'] ?? []);

        // Cập nhật SharedPreferences
        await preferences.setStringList('_keygenres', genres);
        await preferences.setStringList('_language', languages);

        // Cập nhật biến toàn cục
        persistedGenres = genres;
        persistedLanguages = languages;

        return true;
      } else {
        print('Failed to fetch preferences: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching preferences: $e');
      return false;
    }
  }

  // Tạo lịch chiếu mới
  static Future<Map<String, dynamic>?> createShowtime({
    required String movieId,
    required String showDate,
    required String showTime,
    required String theaterName,
  }) async {
    if (authToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/showtimes/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'movie_id': movieId,
          'show_date': showDate,
          'show_time': showTime,
          'theater_name': theaterName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create showtime: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating showtime: $e');
      return null;
    }
  }

  // Lấy danh sách lịch chiếu
  static Future<List<Map<String, dynamic>>> getShowtimes(
    int movieId,
    String date,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/movies/$movieId/showtimes?date=$date'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['showtimes']);
      } else {
        print('Failed to get showtimes: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting showtimes: $e');
      return [];
    }
  }

  // Lấy thông tin ghế đã đặt
  static Future<List<int>> getSeatAvailability(int showtimeId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/showtimes/$showtimeId/seats'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return List<int>.from(data['booked_seats']);
      } else {
        print('Failed to get seat availability: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting seat availability: $e');
      return [];
    }
  }

  // Tạo đặt vé
  static Future<Map<String, dynamic>?> createBooking({
    required int showtimeId,
    required List<int> seatIds,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    if (authToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'showtime_id': showtimeId,
          'seat_ids': seatIds,
          'total_price': totalPrice,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create booking: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Lấy danh sách vé đã đặt của người dùng
  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    if (authToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/bookings'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print('Failed to get bookings: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }
}
