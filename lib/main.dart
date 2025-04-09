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
  final String phoneNumber = '081290763984';
  final String phoneNumberWA = "6281290763984";
  final String message =
      "Cuy, ada something on the way ke rumah lo. Kalau udah landed, hit me up ya!\n-[nama]";
  final String schedule = "Sabtu, 8 November 2025";
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
        "&details=${Uri.encodeComponent("Jangan lupa hadir di acara pernikahan kami!")}"
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
            title:
                _buildTextMerriweather("Harap isi semua kolom!", fontSize: 14)),
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
            "Disalin ke clipboard!",
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

  // @override
  // Widget build(BuildContext context) {
  //   if (screenWidth == 0.0 || screenHeight == 0.0) {
  //     return const Scaffold(
  //       backgroundColor: Colors.black,
  //       body: Center(
  //         child: CircularProgressIndicator(
  //           color: Colors.white,
  //         ),
  //       ),
  //     );
  //   }
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: Stack(
  //       children: [
  //         _buildBackground(
  //           PageView(
  //             scrollDirection: Axis.vertical,
  //             controller: _pageController,
  //             physics: const NeverScrollableScrollPhysics(),
  //             children: [
  //               _buildHomePage(),
  //               _buildUIPage(),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                  "Undangan Pernikahan Kami",
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                _buildGradientText(
                  'Akhdan\n&\nFitri',
                  fontSize: 50,
                ),
                const SizedBox(height: 30),
                _buildTextBonaNova(
                  'Kepada Bpk/Ibu/Saudara/i',
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
                    'Tanpa Mengurangi Rasa Hormat, Kami Mengundang Anda Untuk Berhadir Di Acara Pernikahan Kami.',
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: isMobile ? 30 : 0),
                isMobile ? _buildButton('Buka Undangan', Icons.drafts, () {
                  _playMusic();
                  _pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }) : Container(),
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
                      width: isMobile ? 200 : 150,
                      height: isMobile ? 300 : 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/wkwkwk.jpeg'),
                          fit: BoxFit.cover,
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
                        _buildTimeBox(_remainingTime.inDays, 'Hari',
                            isMobile: isMobile),
                        _buildTimeBox(_remainingTime.inHours % 24, 'Jam',
                            isMobile: isMobile),
                        _buildTimeBox(_remainingTime.inMinutes % 60, 'Menit',
                            isMobile: isMobile),
                        _buildTimeBox(_remainingTime.inSeconds % 60, 'Detik',
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
                        '"Dan di antara tanda-tanda (kebesaran)-Nya ialah Dia menciptakan pasangan-pasangan untukmu dari jenismu sendiri, agar kamu cenderung merasa tenteram kepadanya. Dan Dia menjadikan di antaramu rasa kasih dan sayang."\n{Q.S : Ar-Rum (30) : 21}',
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
                      'Dengan memohon rahmat dan ridho Allah Subhanahu Wa Ta’ala, dengan penuh syukur kami bermaksud menyelenggarakan pernikahan kami',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    _buildIdentityItem(
                      name: 'Akhdan Habibie, S.Kom',
                      imagePath: 'assets/man.png',
                      instagramUsername: 'akhddan',
                      parents:
                          'Anak kedua dari\nBapak Drs. Muhammad Syakur & Ibu Dra. Hasanah',
                    ),
                    const SizedBox(height: 30),
                    _buildTextGreatVibes('&',
                        fontSize: 30, color: const Color(0xFFBD7D1C)),
                    const SizedBox(height: 30),
                    _buildIdentityItem(
                      name: 'Fitri Yulianingsih, S.Ak',
                      imagePath: 'assets/girl.jpg',
                      instagramUsername: 'yliafithri',
                      parents:
                          'Anak kedua dari\nBapak Sudiarjo & Ibu Nuraeni S',
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
                      'Dengan segala kerendahan hati kami berharap kehadiran Bapak/Ibu/Saudara/i dalam acara pernikahan kami yang akan diselenggarakan pada :',
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
                      'Akad Nikah',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 20),
                    _buildScheduleItem(
                      date: schedule,
                      time: 'Pukul : 09:00 WIB - 10:00 WIB',
                    ),
                    const SizedBox(height: 30),
                    _buildGradientText(
                      'Resepsi',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 20),
                    _buildScheduleItem(
                      date: schedule,
                      time: 'Pukul : 11:00 WIB - Selesai',
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTextMerriweather(
                          'Bertempat di,',
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
                    _buildButton('Lihat Lokasi', Icons.location_pin, () async {
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
                        _buildImageCarousel(
                          context,
                          ['assets/a.jpeg', 'assets/g.jpeg', 'assets/e.jpeg'],
                          isMobile ? 0.47 : 0.14,
                          0.5,
                          const Duration(seconds: 2),
                          Axis.horizontal,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageCarousel(
                              context,
                              [
                                'assets/b.jpeg',
                                'assets/berdua.jpeg',
                                'assets/c.jpeg'
                              ],
                              isMobile ? 0.38 : 0.14,
                              0.24,
                              const Duration(seconds: 3),
                              Axis.vertical,
                            ),
                            const SizedBox(height: 12),
                            _buildImageCarousel(
                              context,
                              [
                                'assets/berdua.jpeg',
                                'assets/b.jpeg',
                                'assets/g.jpeg'
                              ],
                              isMobile ? 0.38 : 0.14,
                              0.24,
                              const Duration(seconds: 4),
                              Axis.horizontal,
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
                            _buildImageCarousel(
                              context,
                              [
                                'assets/a.jpeg',
                                'assets/berdua.jpeg',
                                'assets/c.jpeg'
                              ],
                              isMobile ? 0.38 : 0.14,
                              0.24,
                              const Duration(seconds: 2),
                              Axis.horizontal,
                            ),
                            const SizedBox(height: 12),
                            _buildImageCarousel(
                              context,
                              [
                                'assets/d.jpeg',
                                'assets/b.jpeg',
                                'assets/g.jpeg'
                              ],
                              isMobile ? 0.38 : 0.14,
                              0.24,
                              const Duration(seconds: 3),
                              Axis.vertical,
                            ),
                          ],
                        ),
                        _buildImageCarousel(
                          context,
                          ['assets/a.jpeg', 'assets/e.jpeg', 'assets/c.jpeg'],
                          isMobile ? 0.47 : 0.14,
                          0.5,
                          const Duration(seconds: 4),
                          Axis.horizontal,
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 20 : 10),
                    _buildImageCarousel(
                      context,
                      ['assets/a.jpeg', 'assets/b.jpeg', 'assets/c.jpeg'],
                      0.9,
                      0.3,
                      const Duration(seconds: 2),
                      Axis.vertical,
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
                      'Kado Pernikahan',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 15),
                    _buildTextMerriweather(
                      "Doa Restu Anda merupakan karunia yang sangat berarti bagi kami.\nDan jika memberi adalah ungkapan tanda kasih Anda, Anda dapat memberi kado secara cashless.",
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
                      'Ucapan dan Doa',
                      fontSize: isMobile
                          ? MediaQuery.of(context).size.width * 0.08
                          : 30,
                    ),
                    const SizedBox(height: 20),
                    _buildTextMerriweather(
                      "Kirimkan ucapan dan doa untuk kedua mempelai",
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 20),
                    TextFieldCustom(
                      controller: nama,
                      obscureText: false,
                      height: MediaQuery.of(context).size.height * 0.1,
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                      hintText: 'Nama',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    TextFieldCustom(
                      controller: ucapan,
                      obscureText: false,
                      height: MediaQuery.of(context).size.height * 0.1,
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2.0),
                      hintText: 'Ucapan',
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
                      'Merupakan suatu kebahagiaan dan kehormatan bagi kami, apabila Bapak/Ibu/Saudara/i/teman-teman, berkenan hadir dan memberikan do’a restu kepada Kami.\n\nKami yang berhagia',
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
                'Dibuat Oleh Pendekar Gendut',
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
        ? DateFormat('dd MMM yyyy || HH:mm').format(
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
        child: _buildTextMerriweather('Kirim', color: Colors.white),
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
        hint:
            _buildTextMerriweather("Konfirmasi kehadiran", color: Colors.grey),
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
              6, context, 'Salin No. Rekening'),
          _buildAccountInfo("Akhdan Habibie", phoneNumber, 'assets/dana.png',
              40, context, 'Salin No. Telepon'),
          _buildAccountInfo("Fitri Yulianingsih", accountNumberF,
              'assets/bca.png', 6, context, 'Salin No. Rekening'),
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
        _buildTextNoto("Anda Juga Bisa Mengirim Kado Fisik Ke Alamat Berikut :",
            fontSize: 13),
        const SizedBox(height: 10),
        _buildTextNoto(alamat, fontSize: 13),
        const SizedBox(height: 20),
        _buildCopy('Salin Alamat', () => _copyToClipboard(context, alamat)),
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
            _buildTextMerriweather("Konfirmasi via WhatsApp", fontSize: 10),
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

  Widget _buildImageCarousel(
      BuildContext context,
      List<String> imagePaths,
      double widthFactor,
      double heightFactor,
      Duration autoPlayInterval,
      Axis scrollDirection) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      child: CarouselSlider(
        options: CarouselOptions(
          height: screenHeight * heightFactor,
          autoPlay: true,
          autoPlayInterval: autoPlayInterval,
          viewportFraction: 1.0,
          scrollDirection: scrollDirection,
          // scrollPhysics: NeverScrollableScrollPhysics(),
        ),
        items: imagePaths.map((imagePath) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: screenWidth * widthFactor,
              height: screenHeight * heightFactor,
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
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
          height: 100,
          width: 70,
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
        width: 150,
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
    double imageScale = isMobile ? 4.5 : 4;

    return Stack(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: 'BD7D1C'.toColor(),
            borderRadius: BorderRadius.circular(10),
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
        ),
        Positioned(
          right: 5,
          top: 0,
          child: Image.asset(
            'assets/Vector.png',
            scale: imageScale,
            color: 'EBB23E'.toColor().withOpacity(0.2),
          ),
        ),
        Positioned(
          left: 5,
          bottom: 0,
          child: Image.asset(
            'assets/Vector-2.png',
            scale: imageScale,
            color: 'EBB23E'.toColor().withOpacity(0.2),
          ),
        ),
      ],
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
        style: Desk(),
        textCapitalization: widget.textCapitalization,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.emailAddress,
        obscureText: _obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          filled: widget.filled,
          fillColor: widget.fillColor,
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