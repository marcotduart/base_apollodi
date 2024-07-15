import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'bluetooth_screen.dart';

class PressureDisplay extends StatefulWidget {
  @override
  _PressureDisplayState createState() => _PressureDisplayState();
}

class _PressureDisplayState extends State<PressureDisplay> {
  List<FlSpot> pressureData = [];
  Timer? timer;


  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchPressureData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void fetchPressureData() async {
    if (BluetoothScreen.targetCharacteristic != null) {
      List<int> value = await BluetoothScreen.targetCharacteristic!.read();
      double pressureValue = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
      setState(() {
        pressureData.add(FlSpot(pressureData.length.toDouble(), pressureValue));
        if (pressureData.length > 20) {
          pressureData.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Pressão: $pressureData psi',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 500,
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(show: true),
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: pressureData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [Colors.blue.withOpacity(0.3), Colors.lightBlue.withOpacity(0.3)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Exibição de Pressão')),
      body: PressureDisplay(),
    ),
  ));
}
