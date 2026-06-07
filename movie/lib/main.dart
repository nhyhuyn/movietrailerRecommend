import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/AboutMe/AboutMe.dart';
import 'package:movie_app/AskName/AskName.dart';
import 'package:movie_app/Authentication/SignIn.dart';
import 'package:movie_app/Authentication/SignUp.dart';
import 'package:movie_app/Authentication/services/AuthService.dart'; // Thêm import AuthService mới
import 'package:movie_app/Authentication/services/AuthWrapper.dart';
import 'package:movie_app/OnboardingPage/GenereSelection/GenreSelection.dart';
import 'package:movie_app/OnboardingPage/LanguageSelection/LanguageSelection.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';
import 'package:movie_app/Screens/Favorite/Favorite.dart';
import 'package:movie_app/Screens/Introduction/IntroductionPage.dart';
import 'package:movie_app/Screens/Splash/SplashScreen.dart';
import 'package:movie_app/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

// Biến toàn cục
late SharedPreferences preferences;
List persistedGenres = [];
List persistedLanguages = [];
List<String> remembermovies = [];
List<String> recommemdedmovienames = [];
List<String> recommemdedmovieimages = [];
List<String> images = [];
List<String> title = [];
List<String> searchdata = [];
String username = "";
String? authToken; // Token xác thực từ backend

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cấu hình widget lỗi
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) return ErrorWidget(details.exception);
    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error! ${details.exception}',
        style: TextStyle(color: Colors.yellow),
        textDirection: TextDirection.ltr,
      ),
    );
  };
  runApp(
    MyApp(), // Wrap your app
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Khởi tạo ứng dụng
  Future<void> _initialize() async {
    await _initializeSharedPreferences();
    await _checkSession();

    setState(() {
      _initialized = true;
    });
  }

  // Khởi tạo SharedPreferences
  Future<void> _initializeSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();

    // Load dữ liệu từ SharedPreferences
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
    authToken = preferences.getString('auth_token');

    // Đảo ngược danh sách để hiển thị mục mới nhất đầu tiên
    recommemdedmovieimages = recommemdedmovieimages.reversed.toList();
    recommemdedmovienames = recommemdedmovienames.reversed.toList();
    remembermovies = remembermovies.reversed.toList();
    searchdata = searchdata.reversed.toList();
    images = images.reversed.toList();
    title = title.reversed.toList();
  }

  // Kiểm tra phiên đăng nhập
  Future<void> _checkSession() async {
    if (authToken != null) {
      bool isValid = await _authService.checkAndRestoreSession();

      if (!isValid) {
        // Token không hợp lệ, xóa dữ liệu người dùng
        preferences.remove('auth_token');
        authToken = null;
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          routes: {
            '/GenreSelection': (context) => GenreSelection(),
            '/LanguageSelection': (context) => LanguageSelection(),
            '/Splash': (context) => SplashScreen(),
            '/details': (context) => DetailsPageBody(),
            '/intro': (context) => IntroductionPage(),
            '/ask': (context) => AskName(),
            '/settings': (context) => Aboutme(),
            '/signin': (context) => SignIn(),
            '/signup': (context) => SignUp(),
            '/auth': (context) => const AuthWrapper(),
            '/favorites': (context) => const Favorite(),
          },
          theme: ThemeData(fontFamily: GoogleFonts.chivo().fontFamily),
          title: 'Movie App',
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      },
    );
  }
}
