import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'bluetooth_screen.dart';

class PressureDisplay extends StatefulWidget {
  @override
  _PressureDisplayState createState() => _PressureDisplayState();
}

class _PressureDisplayState extends State<PressureDisplay> {
  List<FlSpot> pressureData = []; // Define variável para armazenar dados de pressão e utilizar no gráfico
  Timer? timer; // Define timer para receber dados de pressão periodicamente

  final String pressureUuid = '0972EF8C-7613-4075-AD52-756F33D4DA91'; // Define variável com Uuid dos dados de pressão

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchPressureData());
  } // Inicializa funções do sistema 

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  } // Encerra funções do sistema

  void fetchPressureData() async { // Função para receber dados de pressão
  if (BluetoothScreen.targetCharacteristic != null) {
    try {
      List<int> value = await BluetoothScreen.targetCharacteristic!.read();
      String data = String.fromCharCodes(value);
      List<String> dataLines = data.split("\n");

      bool hasPressureData = false;

      for (String line in dataLines) {
        if (line.contains(pressureUuid)) {
          hasPressureData = true;
          double pressureValue = double.tryParse(line.split(pressureUuid)[1].trim()) ?? 0.0;
          setState(() {
            pressureData.add(FlSpot(pressureData.length.toDouble(), pressureValue));
            if (pressureData.length > 50) {
              pressureData.removeAt(0); // Mantém apenas os últimos 50 valores
            }
          });
        }
      }

      if (!hasPressureData) { // Criar dados aleatórios se não identificar dados do ESP32
        addRandomDataPoints();
      }
    } catch (e) {
      print("Erro ao ler os dados do Bluetooth: $e");
      addRandomDataPoints();
    }
  } else {
    addRandomDataPoints();
  }
}

  void addRandomDataPoints() { // Função para criar dados aleatórios
    setState(() {
      for (int i = 0; i < 5; i++) {
        double randomValue = Random().nextDouble() * 500;
        pressureData.add(FlSpot(pressureData.length.toDouble(), randomValue));
        if (pressureData.length > 20) {
          pressureData.removeAt(0); // Mantém apenas os últimos 20 valores
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) { // Constrói tela de pressão
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text(
              '${pressureData.isNotEmpty ? pressureData.last.y.toStringAsFixed(2) : "Indisponível"} psi', // Define texto variável a partir dos dados de pressão
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
                      isCurved: false, // Formato do gráfico
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
