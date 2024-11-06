import 'package:flutter/material.dart';
import 'dart:math';

import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, RouteAware {
  late AnimationController _imageController;
  late AnimationController _dotController;
  late AnimationController _fadeController;
  late AnimationController _ekgController;
  late AnimationController _ekgOpacityController;
  late AnimationController _imageFadeOutController;

  late Animation<double> _imageHeightAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _dotOpacityAnimation;
  late Animation<double> _imagePositionAnimation;
  late Animation<double> _ekgOpacityAnimation;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _imageOpacityAnimation;

  bool _showRedDots = false;

  @override
  void initState() {
    super.initState();

    // Animasi fade-in untuk teks
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Memulai animasi fade-in untuk teks
    _fadeController.forward();

    // Animasi untuk gambar orang, dari kecil hingga besar dengan efek pudar
    _imageController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _imageScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOut),
    );

    _imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeIn),
    );

    _imageHeightAnimation = Tween<double>(begin: 400, end: 650).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );

    // Memulai animasi fade-in untuk gambar orang
    _imageController.forward();

    // Animasi untuk posisi gambar naik dari bawah ke atas
    _imagePositionAnimation = Tween<double>(begin: 200, end: -60).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );

    // Animasi untuk kedap-kedip titik merah
    _dotController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _dotOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeInOut),
    );

    _imageController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showRedDots = true;
        });
        _dotController.repeat(reverse: true);
      }
    });

    // Animasi untuk spektrum EKG (gerakan horizontal)
    _ekgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();

    _ekgOpacityController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);

    _ekgOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ekgOpacityController, curve: Curves.easeInOut),
    );

    // Animasi fade out dan scale up untuk gambar orang saat titik merah diklik
    _imageFadeOutController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _imageFadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsScreen()),
        ).then((_) {
          // Reset animasi setelah kembali dari DetailsScreen
          _imageFadeOutController.reset();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver<ModalRoute<void>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    RouteObserver<ModalRoute<void>>().unsubscribe(this);
    _imageController.dispose();
    _dotController.dispose();
    _fadeController.dispose();
    _ekgController.dispose();
    _ekgOpacityController.dispose();
    _imageFadeOutController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Reset animasi setelah kembali dari detail screen
    _imageFadeOutController.reset();
  }

  void _onRedDotTap() {
    _imageFadeOutController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Overview',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
              ),
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.grey),
                  onPressed: () {},
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.apps, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedBuilder(
            animation: _imageController,
            builder: (context, child) {
              return Transform.scale(
                scale: _imageScaleAnimation.value,
                child: FadeTransition(
                  opacity: _imageOpacityAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _imagePositionAnimation.value),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/orang.png',
                        height: _imageHeightAnimation.value,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Titik Merah di Dada
          if (_showRedDots)
            Positioned(
              top: 130,
              right: 190,
              child: FadeTransition(
                opacity: _dotOpacityAnimation,
                child: _buildRedDot(context),
              ),
            ),
          // Titik Merah di Lengan
          if (_showRedDots)
            Positioned(
              left: 110,
              top: 228,
              child: FadeTransition(
                opacity: _dotOpacityAnimation,
                child: _buildRedDot(context),
              ),
            ),
          // Titik Merah di Kaki
          if (_showRedDots)
            Positioned(
              bottom: 135,
              right: 161,
              child: FadeTransition(
                opacity: _dotOpacityAnimation,
                child: _buildRedDot(context),
              ),
            ),
          // Keterangan Heart Rate dengan efek fade-in, animasi EKG, dan blur di dalam Container
          Positioned(
            bottom: -90,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                height: 200,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heart Rate',
                            style: TextStyle(
                              fontSize: 23,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 7),
                          Row(
                            children: [
                              Text(
                                '124 bpm',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.favorite, color: Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    FadeTransition(
                      opacity: _ekgOpacityAnimation,
                      child: AnimatedBuilder(
                        animation: _ekgController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(140, 50),
                            painter: EKGPainter(progress: _ekgController.value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedDot(BuildContext context) {
    return GestureDetector(
      onTap: _onRedDotTap,
      child: CircleAvatar(
        radius: 10,
        backgroundColor: Colors.red,
        child: Icon(Icons.circle, color: Colors.white, size: 8),
      ),
    );
  }
}

class EKGPainter extends CustomPainter {
  final double progress;
  EKGPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;

    path.moveTo(0, midY);

    for (double x = 0; x <= size.width; x += 10) {
      double y;
      if ((x / 10) % 4 == 1) {
        y = midY - 15;
      } else if ((x / 10) % 4 == 2) {
        y = midY + 20;
      } else {
        y = midY;
      }
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}