import 'package:flutter/material.dart';

/*Others*/
import 'package:fl_chart/fl_chart.dart';

class DataPoint {
  final double value;
  final String title;
  final Color color;

  DataPoint({required this.value, required this.title, required this.color});
}

class PieChartWidget extends StatefulWidget {
  final List<DataPoint> data;

  PieChartWidget(this.data);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  @override
  Widget build(BuildContext context) {
    final sections = widget.data.map((point) {
      return PieChartSectionData(
        value: point.value,
        title: point.title,
        color: point.color,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
      ),
    );
  }
}
