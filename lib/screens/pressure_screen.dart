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
    timer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => fetchPressureData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void fetchPressureData() async {
    if (BluetoothScreen.targetPressureCharacteristic != null) {
      try {
        List<int> value =
            await BluetoothScreen.targetPressureCharacteristic!.read();
        String data = String.fromCharCodes(value);
        double pressureValue = double.tryParse(data) ?? 0.0;
        setState(() {
          pressureData
              .add(FlSpot(pressureData.length.toDouble(), pressureValue));
          if (pressureData.length > 50) {
            // Limita a quantidade de pontos no gráfico
            pressureData.removeAt(0);
            print(pressureValue);
          }
        });
      } catch (e) {
        print("Erro ao ler os dados do Bluetooth: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text(
              '${pressureData.isNotEmpty ? pressureData.last.y.toStringAsFixed(2) : "Indisponível"} psi',
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
                      isCurved: false,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.lightBlue.withOpacity(0.3)
                          ],
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
