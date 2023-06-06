import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ArrowPainter extends CustomPainter {
  final Vector2 position;
  final Vector2 direction;
  final double length;
  final double width;

  ArrowPainter(this.position, this.direction, this.length, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();

    final tip = position + direction * length;
    final base1 = tip - direction * width / 2;
    final base2 = tip + direction * width / 2;

    path.moveTo(tip.x, tip.y);
    path.lineTo(base1.x, base1.y);
    path.lineTo(base2.x, base2.y);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.direction != direction ||
        oldDelegate.length != length ||
        oldDelegate.width != width;
  }
}