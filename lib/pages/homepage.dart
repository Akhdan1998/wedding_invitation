part of '../pages.dart';

List<String> list = <String>[
  'Saya akan datang',
  'Maaf, Saya tidak bisa datang'
];

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double screenWidth = 0.0, screenHeight = 0.0;
  List<Star> _stars = [];
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  String dropdownValue = list.first;
  String guestName = "Tamu Undangan";
  bool isPlaying = false;
  bool isLoading = false;
  final PageController _pageController = PageController();
  late AnimationController _controller;
  static final eventDate = DateTime(2025, 11, 8, 9, 0);
  final String accountNumberA = '0710314349';
  final String accountNumberF = '5910115342';
  final String phoneNumber = '081290763984';
  final String phoneNumberWA = "6281290763984";
  final String message = "Halo, Pendekar Gendut!";
  final String alamat =
      'Jalan Curug Agung, Gang Mushola, Rt.02/10, Tanah Baru, Beji, Depok, Jawa Barat\n(Gerbang Warna Biru)';
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController nama = TextEditingController();
  final TextEditingController ucapan = TextEditingController();
  final List<Color> colors = [
    Colors.redAccent, Colors.greenAccent, Colors.blueAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent, Colors.pinkAccent, Colors.indigoAccent,
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
        "&dates=${_formatDateTime(eventDate)}/${_formatDateTime(eventDate.add(Duration(hours: 3)))}");

    if (await canLaunchUrl(googleCalendarUrl)) {
      await launchUrl(googleCalendarUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka Google Kalender';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime
            .toUtc()
            .toIso8601String()
            .replaceAll("-", "")
            .replaceAll(":", "")
            .split(".")[0] +
        "Z";
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      // Pastikan ukuran valid
      _stars = List.generate(100, (_) => Star(screenWidth, screenHeight));
    }
  }

  void _playMusic() async {
    String audioPath = 'assets/audio/music.mp3';

    if (kIsWeb) {
      String audioUrl = Uri.base.resolve(audioPath).toString();
      await _audioPlayer.play(UrlSource(audioUrl));
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

  void _copyToClipboard(BuildContext context, String text) {
    FlutterClipboard.copy(text).then((_) {
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        animationDuration: Duration(seconds: 3),
        builder: (context) => ToastCard(
          leading: Icon(
            Icons.copy,
            size: 28,
          ),
          title: Text(
            "Disalin ke clipboard!",
            style: Noto(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ).show(context);
    });
  }

  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 5),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _getGuestNameFromUrl();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
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
    _rotationController.dispose();
    _timer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (screenWidth == 0.0 || screenHeight == 0.0) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()), // Tampilkan loading
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(
            PageView(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              children: [
                _buildHomePage(),
                _buildUIPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isPlaying ? _stopMusic : _playMusic,
        mini: true,
        child: Icon(isPlaying ? Icons.volume_off : Icons.volume_up_sharp),
      ),
    );
  }

  Widget _buildHomePage() {
    final String guestName = Uri.base.queryParameters["name"] ?? "";
    return Stack(
      children: [
        // _buildRotatingImage(),
        _buildTopImage(),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Undangan Pernikahan Kami',
                  style: Noto(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Akhdan\n&\nFitri', textAlign: TextAlign.center,
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Tanpa Mengurangi Rasa Hormat, Kami Mengundang Anda Untuk Berhadir Di Acara Pernikahan Kami.',
                  textAlign: TextAlign.center,
                  style: BonaNova(color: Colors.white, fontSize: 13),
                ),
                SizedBox(height: 30),
                Text(
                  guestName.isNotEmpty ? guestName + ' & Partner' : 'Tamu Undangan',
                  style: BonaNova(fontSize: 20, color: Colors.white,),
                ),
                SizedBox(height: 30),
                _buildButton('Buka Undangan', Icons.drafts, () {
                  _playMusic();
                  _pageController.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }),
              ],
            ),
          ),
        ),
        _buildBottomImage(),
      ],
    );
  }

  Widget _buildUIPage() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        children: [
          //_buildCountdownPage
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: AssetImage('assets/wkwkwk.jpeg'),
                              fit: BoxFit.cover)),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'The Wedding Of',
                      style: Noto(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 30),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            'BD7D1C'.toColor(),
                            'EBB23E'.toColor(),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Akhdan & Fitri',
                        style: CinzelDecorative(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Sabtu, 8 November 2025',
                      textAlign: TextAlign.center,
                      style: Noto(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBox(_remainingTime.inDays, 'Hari'),
                        _buildTimeBox(_remainingTime.inHours % 24, 'Jam'),
                        _buildTimeBox(_remainingTime.inMinutes % 60, 'Menit'),
                        _buildTimeBox(_remainingTime.inSeconds % 60, 'Detik'),
                      ],
                    ),
                    SizedBox(height: 30),
                    _buildButton('Save the Date', Icons.calendar_month,
                        _saveToGoogleCalendar),
                  ],
                ),
              ),
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 30),
                  child: Text(
                    '"Dan di antara tanda-tanda (kebesaran)-Nya ialah Dia menciptakan pasangan-pasangan untukmu dari jenismu sendiri, agar kamu cenderung merasa tenteram kepadanya. Dan Dia menjadikan di antaramu rasa kasih dan sayang."\n{Q.S : Ar-Rum (30) : 21}',
                    style: Desk(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
          SizedBox(height: 50),
          //_buildIdentityPage
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dengan memohon rahmat dan ridho Allah Subhanahu Wa Ta’ala, dengan penuh syukur kami bermaksud menyelenggarakan pernikahan kami',
                  style: Desk(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _buildIdentityItem(
                  name: 'Akhdan Habibie, S.Kom',
                  imagePath: 'assets/man.png',
                  instagramUsername: 'akhddan',
                  parents:
                      'Anak kedua dari\nBapak Drs. Muhammad Syakur & Ibu Dra. Hasanah',
                ),
                SizedBox(height: 30),
                Text(
                  '&',
                  style: CinzelDecorative(
                    color: 'BD7D1C'.toColor(),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                _buildIdentityItem(
                  name: 'Fitri Yulianingsih, S.Ak',
                  imagePath: 'assets/girl.png',
                  instagramUsername: 'yliafithri',
                  parents: 'Anak kedua dari\nBapak Sudiarjo & Ibu Nuraeni S',
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          //_buildDateTimePage
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dengan segala kerendahan hati kami berharap kehadiran kehadiran Bapak/Ibu/Saudara/i dalam acara pernikahan kami yang akan diselenggarakan pada :',
                  style: Desk(color: Colors.white, fontSize: 13,),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Image.asset(
                  'assets/datetime.png',
                  color: Colors.white,
                  width: 115,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Akad Nikah',
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sabtu, 8 November 2025',
                          style: Desk(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Pukul : 09:00 WIB - 10:00',
                          style: Desk(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Resepsi',
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sabtu, 8 November 2025',
                          style: Desk(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Pukul : 11:00 WIB - Selesai',
                          style: Desk(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Bertempat di,',
                      style: Desk(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Villa 3A Ciganjur\nJl. Moh. Kahfi 1 No.3A 8, RT.8/RW.1, Ciganjur, Kec. Jagakarsa, Kota Jakarta Selatan, Daerah Khusus Ibukota Jakarta 12630',
                      style: Desk(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 30),
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
          SizedBox(height: 50),
          //_buildGalleryPage
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Our Gallery',
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.08, // Responsif
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageContainer(context, 'assets/a.jpeg', 0.38, 0.5),
                    Column(
                      children: [
                        _buildImageContainer(context, 'assets/b.jpeg', 0.48, 0.24),
                        SizedBox(height: 12),
                        _buildImageContainer(context, 'assets/berdua.jpeg', 0.48, 0.24),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        _buildImageContainer(context, 'assets/c.jpeg', 0.48, 0.24),
                        SizedBox(height: 12),
                        _buildImageContainer(context, 'assets/d.jpeg', 0.48, 0.24),
                      ],
                    ),
                    _buildImageContainer(context, 'assets/e.jpeg', 0.38, 0.5),
                  ],
                ),
                SizedBox(height: 20),
                _buildImageContainer(context, 'assets/g.jpeg', 0.9, 0.3),
              ],
            ),
          ),
          SizedBox(height: 50),
          //_buildGiftPage
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Kado Pernikahan', textAlign: TextAlign.center,
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Doa Restu Anda merupakan karunia yang sangat berarti bagi kami.\nDan jika memberi adalah ungkapan tanda kasih Anda, Anda dapat memberi kado secara cashless.',
                  style: Desk(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Akhdan Habibie',
                                      style: Noto(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      accountNumberA,
                                      style: Noto(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  'assets/bca.png',
                                  scale: 6,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            _buildCopy(
                              'Salin No. Rekening',
                              () => _copyToClipboard(context, accountNumberA),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Akhdan Habibie',
                                      style: Noto(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      phoneNumber,
                                      style: Noto(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  'assets/dana.png',
                                  scale: 40,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            _buildCopy(
                              'Salin No. Telepon',
                              () => _copyToClipboard(context, phoneNumber),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fitri Yulianingsih',
                                      style: Noto(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      accountNumberF,
                                      style: Noto(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  'assets/bca.png',
                                  scale: 6,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            _buildCopy(
                              'Salin No. Rekening',
                              () => _copyToClipboard(context, accountNumberF),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Column(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: Colors.black,
                              size: 40,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Anda Juga Bisa Mengirim Kado Fisik Ke Alamat Berikut :',
                              style: Noto(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              alamat,
                              style: Noto(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            _buildCopy(
                              'Salin Alamat',
                              () => _copyToClipboard(context, alamat),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: openWhatsApp,
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.sizeOf(context).width,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/wa.png',
                                      scale: 85,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Konfirmasi via WhatsApp",
                                        style: Desk(fontSize: 10)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          //_buildSayingPage
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Ucapan dan Doa',
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Kirimkan ucapan dan doa untuk kedua mempelai',
                  style: Desk(color: Colors.white), textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFieldCustom(
                  controller: nama,
                  obscureText: false,
                  height: MediaQuery.of(context).size.height * 0.1,
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                  hintText: 'Nama',
                  textCapitalization: TextCapitalization.words, // Huruf pertama setiap kata menjadi kapital
                ),
                SizedBox(height: 20),
                TextFieldCustom(
                  controller: ucapan,
                  obscureText: false,
                  height: MediaQuery.of(context).size.height * 0.1,
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                  hintText: 'Ucapan',
                  textCapitalization: TextCapitalization.sentences, // Hanya huruf pertama dari kalimat yang kapital
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: DropdownButton(
                    value: dropdownValue.isEmpty ? null : dropdownValue,
                    icon: Icon(Icons.keyboard_arrow_down_sharp),
                    hint: Text(
                      "Konfirmasi kehadiran",
                      style: Desk(color: Colors.grey), // Styling hint
                    ),
                    isExpanded: true,
                    elevation: 0,
                    underline: Container(),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Desk(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                (isLoading == true)
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Bounce(
                        onPressed: () async {
                          if (nama.text.isEmpty ||
                              ucapan.text.isEmpty ||
                              dropdownValue.isEmpty) {
                            DelightToastBar(
                              position: DelightSnackbarPosition.top,
                              animationDuration: Duration(seconds: 3),
                              builder: (context) => ToastCard(
                                title: Text(
                                  "Harap isi semua kolom!",
                                  style: Desk(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ).show(context);
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            var user = FirebaseAuth.instance.currentUser;
                            String uid = user?.uid ?? "anonymous";

                            CollectionReference ucapanCollection =
                                FirebaseFirestore.instance
                                    .collection('ucapan_kehadiran');

                            await ucapanCollection.add({
                              'nama': nama.text,
                              'ucapan': ucapan.text,
                              'kehadiran': dropdownValue,
                              'uid': uid,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            if (!mounted) return;
                            setState(() {
                              nama.clear();
                              ucapan.clear();
                              dropdownValue = list.first;
                            });
                          } catch (e) {
                            print('ERROR: $e');
                          }

                          if (!mounted) return;
                          setState(() {
                            isLoading = false;
                          });
                        },
                        duration: Duration(milliseconds: 100),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                          ),
                          child: Text(
                            'Kirim',
                            style: Desk(color: Colors.white),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                Divider(height: 1),
                SizedBox(height: 10),
                //
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('ucapan_kehadiran')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container();
                    }

                    var docs = snapshot.data!.docs;
                    int itemCount = docs.length > 5 ? 5 : docs.length;

                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: false,
                        physics: ClampingScrollPhysics(),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;

                          Timestamp? timestamp = data['timestamp'];
                          String date = timestamp != null
                              ? DateFormat('dd MMM yyyy || HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000).toLocal())
                              : '-';

                          return Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: getColorFromName(data['nama'] ?? ''),
                                      ),
                                      child: Text(
                                        (data['nama'] != null && data['nama'].isNotEmpty)
                                            ? data['nama'][0].toUpperCase()
                                            : '?',
                                        style: Desk(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          toTitleCase(data['nama'] ?? '-'),
                                          style: Desk(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width - 110,
                                          child: Text(
                                            data['ucapan'],
                                            style: Desk(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width - 110,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                date,
                                                style: Desk(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                              ),
                                              Text(
                                                data['kehadiran'],
                                                style: Desk(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                //
                Divider(height: 1),
                SizedBox(height: 20),
                Text(
                  textAlign: TextAlign.center,
                  'Merupakan suatu kebahagiaan dan kehormatan bagi kami, apabila Bapak/Ibu/Saudara/i/teman-teman, berkenan hadir dan memberikan do’a restu kepada Kami.\n\nKami yang berhagia',
                  style: Desk(color: Colors.white),
                ),
                SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        'BD7D1C'.toColor(),
                        'EBB23E'.toColor(),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Akhdan & Fitri',
                    style: CinzelDecorative(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          //_build
          Text(
            'Created by Pendekar Gendut',
            style: Desk(color: Colors.white, fontSize: 8),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context, String imagePath, double widthFactor, double heightFactor) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
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
        SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: ['BD7D1C'.toColor(), 'EBB23E'.toColor()],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Text(
            name,
            style: CinzelDecorative(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: 10),
        _buildButtonSosMed(
            instagramUsername, () => launchInstagramProfile(instagramUsername)),
        SizedBox(height: 10),
        Text(
          parents,
          textAlign: TextAlign.center,
          style: Desk(color: Colors.white, fontSize: 13),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRotatingImage() {
    return Positioned(
      top: -215,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (_, child) => Transform.rotate(
          angle: _rotationController.value * 2 * pi,
          child: child,
        ),
        child: Image.asset('assets/role.png'),
      ),
    );
  }

  Widget _buildBottomImage() {
    return Positioned(
      bottom: 10,
      left: 10,
      // right: 0,
      child: Image.asset('assets/bot.png', scale: 20,),
    );
  }

  Widget _buildTopImage() {
    return Positioned(
      top: 10,
      right: 10,
      child: Image.asset('assets/tot.png', scale: 20,),
    );
  }

  Widget _buildBackground(Widget child) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter:
              ColorFilter.mode('000000'.toColor().withOpacity(0.5), BlendMode.xor,),
          child: Container(
            decoration: BoxDecoration(
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            SizedBox(width: 5),
            Text(text, style: Desk(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSosMed(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/instagram.png', scale: 140),
            SizedBox(width: 5),
            Text(text, style: Desk(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCopy(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: Desk(fontSize: 10)),
      ),
    );
  }

  Widget _buildTimeBox(int value, String label) {
  double screenWidth = MediaQuery.of(context).size.width;
  double boxSize = screenWidth * 0.2;
    return Stack(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: 'BD7D1C'.toColor(),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  spreadRadius: 1,
                  color: Colors.grey,
                  offset: Offset(0.0, 0.0),
                ),
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: Desk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Desk(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 5,
          top: 0,
          child: Image.asset(
            'assets/Vector.png',
            scale: 4,
            color: 'EBB23E'.toColor().withOpacity(0.2),
          ),
        ),
        Positioned(
          left: 5,
          bottom: 0,
          child: Image.asset(
            'assets/Vector-2.png',
            scale: 4,
            color: 'EBB23E'.toColor().withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}