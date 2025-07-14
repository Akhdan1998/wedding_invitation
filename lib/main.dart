import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';
import 'package:universal_html/html.dart' as html;

List<QueryDocumentSnapshot> globalUcapanList = [];

class Star {
  double x, y, speed;
  final double screenWidth;
  final double screenHeight;
  Random random = Random();

  Star(this.screenWidth, this.screenHeight)
      : x = Random().nextDouble() * screenWidth,
        y = Random().nextDouble() * screenHeight,
        speed = Random().nextDouble() * 4 + 2;

  void updatePosition(double screenHeight) {
    y += speed;
    if (y > screenHeight) {
      y = 0;
      x = random.nextDouble() * screenWidth;
    }
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;

  StarPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amberAccent.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    for (var star in stars) {
      canvas.drawCircle(Offset(star.x, star.y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => true;
}

Future<void> fetchUcapanData() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('ucapan_kehadiran')
      .orderBy('timestamp', descending: true)
      .get();

  globalUcapanList = snapshot.docs;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully.");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
  await fetchUcapanData();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

List<String> list = <String>[
  'Count me in, gue dateng',
  'Big sorry, tapi I can\'t make it'
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double screenWidth = 0.0, screenHeight = 0.0;
  List<Star> _stars = [];
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  String? dropdownValue;
  String guestName = "Agus Buntung & Partner";
  bool isPlaying = false;
  bool isLoading = false;
  final PageController _pageController = PageController();
  late AnimationController _controller;
  static final eventDate = DateTime(2025, 11, 8, 9, 0);
  final String accountNumberA = '0710314349';
  final String accountNumberF = '5910115342';
  final String accountNumberFB = '003621889298';
  final String phoneNumber = '081290763984';
  final String phoneNumberWA = "6281290763984";
  final String message =
      "Cuy, ada something on the way ke rumah lo. Kalau udah landed, hit me up ya!\n-[nama]";
  final String schedule = "Saturday, November 8, 2025";
  final String alamat =
      'Jalan Curug Agung, Gang Mushola, Rt.02/10, Tanah Baru, Beji, Depok, Jawa Barat\n(Gerbang Warna Biru)';
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController nama = TextEditingController();
  final TextEditingController ucapan = TextEditingController();

  final List<Color> colors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
    Colors.black,
    Colors.indigoAccent,
    Colors.amberAccent,
    Colors.blueGrey,
    Colors.brown,
    Colors.limeAccent,
    Colors.cyan,
  ];

  Color getColorFromName(String name) {
    if (name.isEmpty) return Colors.grey;
    int index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Future<void> launchInstagramProfile(String username) async {
    final Uri instagramAppUrl =
        Uri.parse("instagram://user?username=$username");
    final Uri instagramWebUrl =
        Uri.parse("https://www.instagram.com/$username/");

    if (await canLaunchUrl(instagramAppUrl)) {
      await launchUrl(instagramAppUrl);
    } else {
      await launchUrl(instagramWebUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveToGoogleCalendar() async {
    final Uri googleCalendarUrl = Uri.parse(
        "https://www.google.com/calendar/render?action=TEMPLATE"
        "&text=${Uri.encodeComponent("Akhdan & Fitri Wedding")}"
        "&details=${Uri.encodeComponent("It won’t be the same tanpa kamu, so please make sure you come to our wedding!")}"
        "&location=${Uri.encodeComponent("Jakarta, Indonesia")}"
        "&dates=${_formatDateTime(eventDate)}/${_formatDateTime(
      eventDate.add(
        const Duration(hours: 3),
      ),
    )}");

    if (await canLaunchUrl(googleCalendarUrl)) {
      await launchUrl(googleCalendarUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka Google Kalender';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.toUtc().toIso8601String().replaceAll("-", "").replaceAll(":", "").split(".")[0]}Z";
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return '-';
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _getGuestNameFromUrl() {
    Uri uri = Uri.parse(html.window.location.href);
    String? name = uri.queryParameters['name'];

    if (name != null && name.isNotEmpty) {
      setState(() {
        guestName = name;
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final difference = eventDate.difference(DateTime.now());
      if (difference.isNegative) {
        timer.cancel();
      } else {
        setState(() => _remainingTime = difference);
      }
    });
  }

  void openWhatsApp() async {
    String whatsappAppUrl =
        "whatsapp://send?phone=$phoneNumberWA&text=${Uri.encodeComponent(message)}";
    String whatsappWebUrl =
        "https://wa.me/$phoneNumberWA?text=${Uri.encodeComponent(message)}";

    if (await canLaunch(whatsappAppUrl)) {
      await launch(whatsappAppUrl);
    } else {
      await launch(whatsappWebUrl);
    }
  }

  void _initializeStars() {
    if (screenWidth > 0 && screenHeight > 0) {
      _stars = List.generate(100, (_) => Star(screenWidth, screenHeight));
    }
  }

  void _playMusic() async {
    String audioPath = 'assets/audio/music.mp3';

    if (kIsWeb) {
      final ByteData data = await rootBundle.load(audioPath);
      final List<int> bytes = data.buffer.asUint8List();
      final String base64String =
          "data:audio/mp3;base64,${base64Encode(bytes)}";

      await _audioPlayer.play(UrlSource(base64String));
    } else {
      await _audioPlayer.play(AssetSource(audioPath));
    }

    setState(() {
      isPlaying = true;
    });
  }

  void _stopMusic() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  void _handleSend() async {
    debugPrint("Mengirim data ke Firestore...");

    if (nama.text.isEmpty || ucapan.text.isEmpty || dropdownValue!.isEmpty) {
      debugPrint("Data tidak lengkap!");
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        animationDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          leading: const Icon(
            Icons.warning,
            size: 28,
          ),
          title: _buildTextNoto(
            "Let’s complete all the fields dulu, baru kita jalanin.",
            fontSize: 14,
            textAlign: TextAlign.start,
          ),
        ),
      ).show(context);
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('ucapan_kehadiran').add({
        'nama': nama.text,
        'ucapan': ucapan.text,
        'kehadiran': dropdownValue,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint("Data berhasil dikirim!");

      if (!mounted) return;
      setState(() {
        nama.clear();
        ucapan.clear();
        dropdownValue = null;
      });
    } catch (e) {
      debugPrint('ERROR: $e');
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _copyToClipboard(BuildContext context, String text) {
    FlutterClipboard.copy(text).then((_) {
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        animationDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          leading: const Icon(
            Icons.copy,
            size: 28,
          ),
          title: _buildTextNoto(
            "Copied to clipboard!",
            fontSize: 14,
            textAlign: TextAlign.start,
          ),
        ),
      ).show(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _getGuestNameFromUrl();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;
        _initializeStars();
      });
    });

    _controller.addListener(() {
      setState(() {
        for (var star in _stars) {
          star.updatePosition(screenHeight);
        }
      });
    });

    _startCountdown();

    final guestName = Uri.base.queryParameters["name"] ?? "";
    if (guestName.isNotEmpty) {
      nama.text = guestName;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (screenSize.width == 0.0 || screenSize.height == 0.0) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          final content = PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: isMobile
                ? [
                    _buildHomePage(isMobile),
                    _buildUIPage(isMobile),
                  ]
                : [
                    _buildUIPage(isMobile),
                  ],
          );

          if (isMobile) {
            return _buildBackground(content);
          }

          return Row(
            children: [
              SizedBox(
                width: constraints.maxWidth >= 1000
                    ? 1000
                    : constraints.maxWidth * 0.5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: StarPainter(_stars),
                      ),
                    ),
                    _buildHomePage(isMobile),
                  ],
                ),
              ),
              Expanded(
                child: _buildBackground(content),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomePage(bool isMobile) {
    final String guestName = Uri.base.queryParameters["name"] ?? "";
    return Stack(
      children: [
        _buildTopImage(),
        Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextNoto(
                  "Our wedding invitation",
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                _buildGradientText(
                  'Akhdan\n&\nFitri',
                  fontSize: 50,
                ),
                const SizedBox(height: 30),
                _buildTextBonaNova(
                  'To Mr./Mrs./Dear Family and Friends,',
                  fontSize: 12,
                ),
                const SizedBox(height: 30),
                _buildTextBonaNova(
                  guestName.isNotEmpty
                      ? '$guestName & Partner'
                      : 'Agus Buntung & Partner',
                  fontSize: 20,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.only(left: 35, right: 35),
                  child: _buildTextBonaNova(
                    'With all due respect, we would like to invite you to celebrate our wedding day.',
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: isMobile ? 30 : 0),
                isMobile
                    ? _buildButton('Open the invitation', Icons.drafts, () {
                        _playMusic();
                        _pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      })
                    : Container(),
              ],
            ),
          ),
        ),
        _buildBottomImage(),
        isMobile ? Container() : _buildMusic(),
      ],
    );
  }

  Widget _buildUIPage(bool isMobile) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              //_buildCountdownPage
              Container(
                padding: EdgeInsets.only(top: isMobile ? 50 : 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 2, color: const Color(0xFFEBB23E)),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          topLeft: Radius.circular(100),
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Container(
                        width: isMobile ? 200 : 150,
                        height: isMobile ? 300 : 250,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100),
                            topLeft: Radius.circular(100),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/IMG_3379.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextNoto(
                      'The Wedding Of',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    _buildGradientText(
                      'Akhdan & Fitri',
                      fontSize: 40,
                    ),
                    const SizedBox(height: 30),
                    _buildTextNoto(
                      schedule,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBox(_remainingTime.inDays, 'Day',
                            isMobile: isMobile),
                        _buildTimeBox(_remainingTime.inHours % 24, 'Hour',
                            isMobile: isMobile),
                        _buildTimeBox(_remainingTime.inMinutes % 60, 'Minute',
                            isMobile: isMobile),
                        _buildTimeBox(_remainingTime.inSeconds % 60, 'Second',
                            isMobile: isMobile),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildButton('Save the Date', Icons.calendar_month,
                        _saveToGoogleCalendar),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: _buildTextMerriweather(
                        '"And among His signs is that He created for you pasangan from your own kind, so you may find peace in them – and He placed between you love and mercy."\n{Q.S : Ar-Rum (30) : 21}',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //_buildIdentityPage
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextMerriweather(
                      'With gratitude and by seeking rahmat and ridho from Allah Subhanahu Wa Ta’ala, we humbly plan to hold our wedding ceremony.',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    _buildIdentityItem(
                      name: 'Akhdan Habibie, S.Kom',
                      imagePath: 'assets/FGM_7172.jpg',
                      instagramUsername: 'akhddan',
                      parents:
                          'The second child of\nMr. Drs. Muhammad Syakur & Mrs. Dra. Hasanah.',
                    ),
                    const SizedBox(height: 30),
                    _buildTextGreatVibes('&',
                        fontSize: 30, color: const Color(0xFFBD7D1C)),
                    const SizedBox(height: 30),
                    _buildIdentityItem(
                      name: 'Fitri Yulianingsih, S.Ak',
                      // imagePath: 'assets/FGM_7354.jpg',
                      imagePath: 'assets/FGM_7143.jpg',
                      instagramUsername: 'yliafithri',
                      parents:
                          'The second child of\nMr. Sudiarjo & Mrs. Nuraeni S',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //_buildDateTimePage
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextMerriweather(
                      'It is with humble hearts that we invite you, Bapak/Ibu/Saudara/i, to be part of our wedding day – happening on :',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/datetime.png',
                      color: Colors.white,
                      width: 115,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 30),
                    _buildGradientText(
                      'The Solemnization of Marriage',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 20),
                    _buildScheduleItem(
                      date: schedule,
                      time: 'At 09.00 – 10.00 WIB ',
                    ),
                    const SizedBox(height: 30),
                    _buildGradientText(
                      'Reception',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 20),
                    _buildScheduleItem(
                      date: schedule,
                      time: 'At 11:00 - 17:00 WIB',
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTextMerriweather(
                          'Venue,',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 5),
                        _buildTextMerriweather(
                          'Villa 3A Ciganjur\nJl. Moh. Kahfi 1 No.3A 8, RT.8/RW.1, Ciganjur, Kec. Jagakarsa, Kota Jakarta Selatan, Daerah Khusus Ibukota Jakarta 12630',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildButton('Open Maps', Icons.location_pin, () async {
                      final Uri googleMapsAppUrl =
                          Uri.parse("geo:0,0?q=ermaVWha4hcJXcpY7");
                      final Uri googleMapsWebUrl = Uri.parse(
                          "https://maps.app.goo.gl/ermaVWha4hcJXcpY7?g_st=com.google.maps.preview.copy");

                      if (await canLaunchUrl(googleMapsAppUrl)) {
                        await launchUrl(googleMapsAppUrl);
                      } else {
                        await launchUrl(googleMapsWebUrl,
                            mode: LaunchMode.externalApplication);
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //_buildGalleryPage
              Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 20, top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildGradientText(
                      'Our Gallery',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImageCarousel(
                          imagePaths: const [
                            'assets/FGM_7354.jpg',
                            'assets/IMG_3381.jpg',
                            'assets/FGM_7247.jpg',
                          ],
                          widthFactor: isMobile ? 0.47 : 0.14,
                          heightFactor: 0.5,
                          scrollDirection: Axis.horizontal,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageCarousel(
                              imagePaths: const [
                                'assets/FGM_7383.jpg',
                                'assets/FGM_7211.jpg',
                                'assets/IMG_3352.jpg',
                              ],
                              widthFactor: isMobile ? 0.38 : 0.14,
                              heightFactor: 0.24,
                              scrollDirection: Axis.vertical,
                            ),
                            const SizedBox(height: 12),
                            ImageCarousel(
                              imagePaths: const [
                                'assets/IMG_3378.jpg',
                                'assets/FGM_7271.jpg',
                                'assets/IMG_3353.jpg',
                              ],
                              widthFactor: isMobile ? 0.38 : 0.14,
                              heightFactor: 0.24,
                              scrollDirection: Axis.horizontal,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 20 : 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            ImageCarousel(
                              imagePaths: const [
                                'assets/IMG_3345.jpg',
                                'assets/IMG_3347.jpg',
                                'assets/IMG_3355.jpg',
                              ],
                              widthFactor: isMobile ? 0.38 : 0.14,
                              heightFactor: 0.24,
                              scrollDirection: Axis.horizontal,
                            ),
                            const SizedBox(height: 12),
                            ImageCarousel(
                              imagePaths: const [
                                'assets/IMG_3348.jpg',
                                'assets/IMG_3350.jpg',
                                'assets/thumbnail.jpg',
                              ],
                              widthFactor: isMobile ? 0.38 : 0.14,
                              heightFactor: 0.24,
                              scrollDirection: Axis.vertical,
                            ),
                          ],
                        ),
                        ImageCarousel(
                          imagePaths: const [
                            'assets/FGM_7352.jpg',
                            'assets/FGM_7379.jpg',
                            'assets/FGM_7178.jpg',
                          ],
                          widthFactor: isMobile ? 0.47 : 0.14,
                          heightFactor: 0.5,
                          scrollDirection: Axis.horizontal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //_buildGiftPage
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildGradientText(
                      'Wedding Gift',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 15),
                    _buildTextMerriweather(
                      "Your presence and prayers are truly a blessing for us. But if giving is your love language, we also provide a cashless gift option.",
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    _buildGiftContainer(context),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //_buildSayingPage
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildGradientText(
                      'Words & Prayers',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 20),
                    _buildTextMerriweather(
                      "Drop your wishes and prayers for the happy couple",
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 20),
                    TextFieldCustom(
                      readOnly: true,
                      controller: nama,
                      obscureText: false,
                      height: MediaQuery.of(context).size.height * 0.1,
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                      hintText: 'Name',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    TextFieldCustom(
                      controller: ucapan,
                      obscureText: false,
                      height: MediaQuery.of(context).size.height * 0.1,
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                      hintText: 'Wishes & prayers ',
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : _buildSendButton(),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    //
                    _buildUcapanList(isMobile: isMobile),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _buildTextMerriweather(
                      'It would truly be an honor and joy for us to have Bapak/Ibu/Saudara/i/friends present on our special day to give your blessings.Warmly,\nKami yang berbahagia.',
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 20),
                    _buildGradientText(
                      'Akhdan & Fitri',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //_build
              _buildTextMerriweather(
                'Crafted by Pendekar Gendut',
                fontSize: 8,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        isMobile ? _buildMusic() : Container(),
      ],
    );
  }

  Widget _buildMusic() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: isPlaying ? _stopMusic : _playMusic,
        mini: true,
        child: Icon(isPlaying ? Icons.volume_off : Icons.volume_up_sharp),
      ),
    );
  }

  Widget _buildUcapanList({required bool isMobile}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ucapan_kehadiran')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firestore error: ${snapshot.error}");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint('Tidak ada ucapan ditemukan');
          return Container();
        }

        var docs = snapshot.data!.docs;
        return SizedBox(
          height: 300,
          child: ListView.builder(
            shrinkWrap: false,
            physics: const ClampingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) => _buildUcapanItem(
              docs[index],
              isMobile: isMobile,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUcapanItem(QueryDocumentSnapshot doc, {required bool isMobile}) {
    var data = doc.data() as Map<String, dynamic>;
    String date = data['timestamp'] != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(
                    data['timestamp'].seconds * 1000)
                .toLocal())
        : '-';

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _buildAvatar(data['nama'] ?? ''),
          const SizedBox(width: 15),
          _buildUcapanDetails(
            data,
            date,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: getColorFromName(name)),
      child: _buildTextMerriweather(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          color: Colors.white),
    );
  }

  Widget _buildUcapanDetails(Map<String, dynamic> data, String date,
      {required bool isMobile}) {
    return Container(
      width: isMobile
          ? MediaQuery.sizeOf(context).width - 105
          : MediaQuery.sizeOf(context).width - 1105,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextMerriweather(
            toTitleCase(data['nama'] ?? '-'),
            fontSize: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 5),
          _buildTextMerriweather(
            data['ucapan'] ?? '',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.bottomRight,
            child: _buildTextMerriweather(
              date,
              fontSize: 9,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Bounce(
      onPressed: _handleSend,
      duration: const Duration(milliseconds: 100),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
            border: Border.all(width: 1, color: Colors.white)),
        child: _buildTextMerriweather('Send', color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: DropdownButton(
        // value: dropdownValue.isEmpty ? null : dropdownValue,
        value: dropdownValue,
        icon: const Icon(Icons.keyboard_arrow_down_sharp),
        hint: _buildTextMerriweather("Confirmation of attendance",
            color: Colors.grey),
        isExpanded: true,
        elevation: 0,
        underline: Container(),
        onChanged: (String? value) => setState(() => dropdownValue = value!),
        items: list
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: _buildTextMerriweather(value),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGiftContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildAccountInfo("Akhdan Habibie", accountNumberA, 'assets/bca.png',
              6, context, 'Copy Account Number'),
          _buildAccountInfo("Akhdan Habibie", phoneNumber, 'assets/dana.png',
              40, context, 'Copy Phone Number'),
          _buildAccountInfo("Fitri Yulianingsih", accountNumberF,
              'assets/bca.png', 6, context, 'Copy Account Number'),
          _buildAccountInfo("Fitri Yulianingsih", accountNumberFB,
              'assets/blu_logo.png', 10, context, 'Copy Account Number'),
          const SizedBox(height: 20),
          _buildGiftAddressSection(context),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(String name, String detail, String asset,
      double scale, BuildContext context, String copyLabel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextNoto(name,
                    fontWeight: FontWeight.bold, color: Colors.black),
                const SizedBox(height: 5),
                _buildTextNoto(detail, color: Colors.black),
              ],
            ),
            Image.asset(asset, scale: scale),
          ],
        ),
        const SizedBox(height: 5),
        _buildCopy(copyLabel, () => _copyToClipboard(context, detail)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGiftAddressSection(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.card_giftcard, color: Colors.black, size: 40),
        const SizedBox(height: 20),
        _buildTextNoto(
            "If you'd like to send a physical gift, feel free to drop it at the address below :",
            fontSize: 13),
        const SizedBox(height: 10),
        _buildTextNoto(alamat, fontSize: 13),
        const SizedBox(height: 20),
        _buildCopy('Copy Address', () => _copyToClipboard(context, alamat)),
        const SizedBox(height: 10),
        _buildWhatsAppButton(context),
      ],
    );
  }

  Widget _buildWhatsAppButton(BuildContext context) {
    return Bounce(
      onPressed: openWhatsApp,
      duration: const Duration(milliseconds: 100),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/wa.png', scale: 85, color: Colors.black),
            const SizedBox(width: 10),
            _buildTextMerriweather("Confirm via WhatsApp", fontSize: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({required String date, required String time}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, color: Colors.white),
            const SizedBox(width: 10),
            _buildTextMerriweather(
              date,
              fontSize: 13,
              color: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, color: Colors.white),
            const SizedBox(width: 10),
            _buildTextMerriweather(
              time,
              fontSize: 13,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextBonaNova(
    String text, {
    double fontSize = 15,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.bonaNova(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget _buildTextGreatVibes(
    String text, {
    double fontSize = 15,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.greatVibes(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget _buildTextNoto(
    String text, {
    double fontSize = 15,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.notoSerif(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget _buildTextMerriweather(
    String text, {
    double fontSize = 15,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.merriweather(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget _buildIdentityItem({
    required String name,
    required String imagePath,
    required String instagramUsername,
    required String parents,
  }) {
    return Column(
      children: [
        Container(
          height: 150,
          width: 105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
            border: Border.all(width: 1, color: Colors.white),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildGradientText(name, fontSize: 25),
        const SizedBox(height: 10),
        _buildButtonSosMed(
            instagramUsername, () => launchInstagramProfile(instagramUsername)),
        const SizedBox(height: 10),
        _buildTextMerriweather(
          parents,
          fontSize: 13,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGradientText(
    String text, {
    double fontSize = 15,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFBD7D1C), Color(0xFFEBB23E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      child: Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.greatVibes(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _buildBottomImage() {
    return Positioned(
      bottom: 10,
      left: 10,
      // right: 0,
      child: Image.asset(
        'assets/bot.png',
        scale: 5,
      ),
    );
  }

  Widget _buildTopImage() {
    return Positioned(
      top: 10,
      right: 10,
      child: Image.asset(
        'assets/tot.png',
        scale: 6,
      ),
    );
  }

  Widget _buildBackground(Widget child) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            '000000'.toColor().withOpacity(0.5),
            BlendMode.xor,
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/paper.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: StarPainter(_stars),
          ),
        ),
        Center(child: child),
      ],
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onTap) {
    return Bounce(
      duration: const Duration(milliseconds: 100),
      onPressed: onTap,
      child: Container(
        width: 174,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(width: 5),
            _buildTextMerriweather(text, fontSize: 13),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSosMed(String text, VoidCallback onTap) {
    return Bounce(
      duration: const Duration(milliseconds: 10),
      onPressed: onTap,
      child: Container(
        width: 78,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/instagram.jpg', scale: 50),
            const SizedBox(width: 5),
            _buildTextMerriweather(text, fontSize: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCopy(String text, VoidCallback onTap) {
    return Bounce(
      onPressed: onTap,
      duration: const Duration(milliseconds: 100),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildTextMerriweather(text, fontSize: 10),
      ),
    );
  }

  Widget _buildTimeBox(int value, String label, {required bool isMobile}) {
    double boxSize = isMobile ? 85 : 90;
    double fontSizeValue = isMobile ? 24 : 24;
    double fontSizeLabel = isMobile ? 15 : 14;
    double padding = isMobile ? 10 : 16;

    return Container(
      width: boxSize,
      height: boxSize,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: 'BD7D1C'.toColor(),
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            'BD7D1C'.toColor(),
            'EBB23E'.toColor(),
            'BD7D1C'.toColor(),
          ],
          begin: Alignment.topLeft,
          end: const Alignment(0.8, 1),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 1,
            color: Colors.grey,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextMerriweather(
            '$value',
            fontSize: fontSizeValue,
            fontWeight: FontWeight.bold,
          ),
          _buildTextMerriweather(
            label,
            fontSize: fontSizeLabel,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

TextStyle Desk({
  double fontSize = 15,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.black,
  TextAlign textAlign = TextAlign.center,
}) {
  return GoogleFonts.merriweather(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

class TextFieldCustom extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final bool icon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double height;
  final double borderRadius;
  final Color fillColor;
  final BorderSide borderSide;
  final bool filled;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final BorderSide? focusedBorderSide;
  final BorderSide? enabledBorderSide;
  final BorderSide? errorBorderSide;

  const TextFieldCustom({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.icon = false,
    this.controller,
    this.focusNode,
    required this.height,
    this.borderRadius = 10.0,
    this.fillColor = Colors.white,
    this.borderSide = BorderSide.none,
    this.filled = true,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.focusedBorderSide,
    this.enabledBorderSide,
    this.errorBorderSide,
  });

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: TextFormField(
        readOnly: widget.readOnly,
        style: Desk(),
        textCapitalization: widget.textCapitalization,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.emailAddress,
        obscureText: _obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          filled: widget.filled,
          fillColor: widget.fillColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: widget.focusedBorderSide ??
                const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: widget.enabledBorderSide ??
                const BorderSide(color: Colors.transparent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                widget.errorBorderSide ?? const BorderSide(color: Colors.red),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: widget.borderSide,
          ),
          hintText: widget.hintText,
          hintStyle: Desk(color: Colors.black38),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    size: 20,
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.imagePaths.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.imagePaths.length,
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(widget.imagePaths[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.imagePaths[index]),
              );
            },
            loadingBuilder: (context, _) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),

          // Tombol Close
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Tombol Prev
          if (_currentIndex > 0)
            Positioned(
              left: 20,
              top: MediaQuery.of(context).size.height / 2 - 30,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 30),
                onPressed: _goToPrevious,
              ),
            ),

          // Tombol Next
          if (_currentIndex < widget.imagePaths.length - 1)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height / 2 - 30,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 30),
                onPressed: _goToNext,
              ),
            ),
        ],
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final double widthFactor;
  final double heightFactor;
  final Axis scrollDirection;

  const ImageCarousel({
    super.key,
    required this.imagePaths,
    required this.widthFactor,
    required this.heightFactor,
    required this.scrollDirection,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        SizedBox(
          width: screenWidth * widget.widthFactor,
          height: screenHeight * widget.heightFactor,
          child: CarouselSlider.builder(
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index, realIndex) {
              final imagePath = widget.imagePaths[index];
              return Bounce(
                duration: const Duration(milliseconds: 100),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        imagePaths: widget.imagePaths,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: imagePath,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      width: screenWidth * widget.widthFactor,
                      height: screenHeight * widget.heightFactor,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Gagal load gambar: $imagePath');
                        debugPrint('Error load gambar: $error');
                        return Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey[500]),
                        );
                      },
                      frameBuilder: (BuildContext context, Widget child,
                          int? frame, bool wasSynchronouslyLoaded) {
                        if (frame != null || wasSynchronouslyLoaded) {
                          debugPrint('✅ Berhasil load gambar: $imagePath');
                        }
                        return child;
                      },
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: screenHeight * widget.heightFactor,
              autoPlay: false,
              viewportFraction: 1.0,
              scrollDirection: widget.scrollDirection,
              onPageChanged: (index, reason) {
                setState(() => currentIndex = index);
              },
            ),
          ),
        ),
        Positioned(
          left: widget.scrollDirection == Axis.vertical ? 8 : null,
          right: widget.scrollDirection == Axis.horizontal ? 8 : null,
          bottom: widget.scrollDirection == Axis.horizontal ? 8 : null,
          top: widget.scrollDirection == Axis.vertical ? 8 : null,
          child: widget.scrollDirection == Axis.horizontal
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imagePaths.length, (index) {
                    bool isActive = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 9 : 6,
                      height: isActive ? 9 : 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(widget.imagePaths.length, (index) {
                    bool isActive = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      width: isActive ? 9 : 6,
                      height: isActive ? 9 : 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
        ),
      ],
    );
  }
}