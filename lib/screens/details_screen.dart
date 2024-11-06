import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _beatController;
  late AnimationController _ekgController;
  late AnimationController _ekgOpacityController;
  late AnimationController _slideController;
  late AnimationController _heartRateSlideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _beatAnimation;
  late Animation<double> _ekgOpacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _heartRateSlideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    _beatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _beatAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _beatController, curve: Curves.easeInOut),
    );

    _ekgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _ekgOpacityController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);

    _ekgOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ekgOpacityController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideController.forward();

    _heartRateSlideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _heartRateSlideAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, 1)).animate(
      CurvedAnimation(parent: _heartRateSlideController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _beatController.dispose();
    _ekgController.dispose();
    _ekgOpacityController.dispose();
    _slideController.dispose();
    _heartRateSlideController.dispose();
    super.dispose();
  }

  void _onClosePressed() {
    _heartRateSlideController.forward().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              'Heart \nConditions',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 26,
                fontFamily: 'Poppins',
                color: Color(0xff0d7875),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: _onClosePressed,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _beatAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scaleY: _beatAnimation.value,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/jantung.png',
                    height: 370,
                  ),
                );
              },
            ),
            SizedBox(height: 5),
            SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SlideTransition(
                  position: _heartRateSlideAnimation,
                  child: Container(
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
                    child: Column(
                      children: [
                        Row(
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
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard('Blood Status', '102/70'),
                            _buildInfoCard('Blood Count', '64/80'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontFamily: 'Gilroy', fontWeight: FontWeight.bold),
          ),
        ],
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
