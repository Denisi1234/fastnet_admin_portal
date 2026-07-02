import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';

class CustomLineChart extends StatefulWidget {
  final List<double> dataPoints;
  final double maxVal;
  final String valuePrefix;
  final String valueSuffix;

  const CustomLineChart({
    super.key,
    required this.dataPoints,
    required this.maxVal,
    this.valuePrefix = '',
    this.valueSuffix = '',
  });

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  int? _hoveredIndex;
  Offset? _hoverPosition;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return MouseRegion(
          onHover: (event) {
            final double chartWidth = width - 60; // Subtract padding for labels
            final double stepX = chartWidth / (widget.dataPoints.length - 1);
            final double localX = event.localPosition.dx - 40; // X offset

            int index = (localX / stepX).round().clamp(0, widget.dataPoints.length - 1);
            setState(() {
              _hoveredIndex = index;
              _hoverPosition = event.localPosition;
            });
          },
          onExit: (_) {
            setState(() {
              _hoveredIndex = null;
              _hoverPosition = null;
            });
          },
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _ChartPainter(
                  dataPoints: widget.dataPoints,
                  maxVal: widget.maxVal,
                  months: _months,
                  hoveredIndex: _hoveredIndex,
                  valuePrefix: widget.valuePrefix,
                  valueSuffix: widget.valueSuffix,
                ),
              ),
              if (_hoveredIndex != null && _hoverPosition != null && _hoveredIndex! < widget.dataPoints.length)
                Positioned(
                  left: _hoverPosition!.dx - 50,
                  top: _hoverPosition!.dy - 65,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.textPrimary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _months[_hoveredIndex!],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.valuePrefix}${widget.dataPoints[_hoveredIndex!].toStringAsFixed(0)}${widget.valueSuffix}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double maxVal;
  final List<String> months;
  final int? hoveredIndex;
  final String valuePrefix;
  final String valueSuffix;

  _ChartPainter({
    required this.dataPoints,
    required this.maxVal,
    required this.months,
    this.hoveredIndex,
    required this.valuePrefix,
    required this.valueSuffix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingLeft = 40.0;
    const double paddingRight = 20.0;
    const double paddingTop = 20.0;
    const double paddingBottom = 30.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final double minVal = 0.0;

    // Draw Grid Lines (Y-axis grid)
    final Paint gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1.0;

    const int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final double y = paddingTop + chartHeight - (i * (chartHeight / gridLines));
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      // Y-axis label text
      final double val = minVal + (i * ((maxVal - minVal) / gridLines));
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$valuePrefix${val.toStringAsFixed(0)}$valueSuffix',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2));
    }

    // Coordinates calculations
    final List<Offset> points = [];
    final double stepX = chartWidth / (dataPoints.length - 1);
    for (int i = 0; i < dataPoints.length; i++) {
      final double x = paddingLeft + (i * stepX);
      final double normY = (dataPoints[i] - minVal) / (maxVal - minVal);
      final double y = paddingTop + chartHeight - (normY * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw Gradient Area below the curve
    if (points.isNotEmpty) {
      final Path areaPath = Path()..moveTo(points.first.dx, paddingTop + chartHeight);
      for (var point in points) {
        areaPath.lineTo(point.dx, point.dy);
      }
      areaPath.lineTo(points.last.dx, paddingTop + chartHeight);
      areaPath.close();

      final Paint areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withValues(alpha: 0.25),
            AppTheme.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight));

      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw Line Curve
    if (points.isNotEmpty) {
      final Path linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final double x1 = points[i].dx;
        final double y1 = points[i].dy;
        final double x2 = points[i + 1].dx;
        final double y2 = points[i + 1].dy;

        // Bezier control points for smooth line curve
        final double controlX1 = x1 + (x2 - x1) / 2;
        final double controlY1 = y1;
        final double controlX2 = x1 + (x2 - x1) / 2;
        final double controlY2 = y2;

        linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
      }

      final Paint linePaint = Paint()
        ..color = AppTheme.primary
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(linePath, linePaint);
    }

    // Draw X-axis month labels
    for (int i = 0; i < months.length; i++) {
      if (i % 2 == 0) { // Render every second label to avoid crowding
        final double x = paddingLeft + (i * stepX);
        final textPainter = TextPainter(
          text: TextSpan(
            text: months[i],
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - paddingBottom + 8));
      }
    }

    // Draw Hover Point Indicator
    if (hoveredIndex != null && hoveredIndex! < points.length) {
      final Offset hoveredPoint = points[hoveredIndex!];

      // Draw dashed or solid vertical line at hovered coordinate
      final Paint vertLinePaint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.3)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(hoveredPoint.dx, paddingTop),
        Offset(hoveredPoint.dx, paddingTop + chartHeight),
        vertLinePaint,
      );

      // Draw outer indicator circle
      final Paint outerCirclePaint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hoveredPoint, 10.0, outerCirclePaint);

      // Draw inner indicator circle
      final Paint innerCirclePaint = Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hoveredPoint, 5.0, innerCirclePaint);

      // Draw white outline
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(hoveredPoint, 5.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex;
  }
}
