part of '../pages.dart';

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