import 'package:flutter/material.dart';
import 'dart:async';
import 'bluetooth_screen.dart';

void sendCommand(String data) async {
  if (BluetoothScreen.targetCharacteristic != null) {
    await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
  }
}

class LancamentoManualScreen extends StatefulWidget {
  @override
  _LancamentoManualScreenState createState() => _LancamentoManualScreenState();
}

class _LancamentoManualScreenState extends State<LancamentoManualScreen> {
  String stageText = ' ';
  Timer? _timer;

  void updateStageText(String newStage) {
    setState(() {
      stageText = '$newStage ativado com sucesso';
    });
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        stageText = ' ';
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lançamento Manual'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            PressureDisplay(),
            RelayControlSection(
              onUpdateStageText: updateStageText,
              stageText: stageText,
            ),
          ],
        ),
      ),
    );
  }
}

class PressureDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Pressão (psi)',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '353',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text('Gráfico de Pressão')),
            ),
          ],
        ),
      ),
    );
  }
}

class RelayControlSection extends StatelessWidget {
  final Function(String) onUpdateStageText;
  final String stageText;

  RelayControlSection({
    required this.onUpdateStageText,
    required this.stageText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              stageText,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                double buttonWidth = constraints.maxWidth / 3 - 10;

                if (constraints.maxWidth < 500) {
                  buttonWidth = constraints.maxWidth / 2 - 10;
                }
                if (constraints.maxWidth < 300) {
                  buttonWidth = constraints.maxWidth - 10;
                }

                return Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    buildSquareButton(
                      context,
                      'IGNITAR',
                      Colors.green,
                      onUpdateStageText,
                      Icons.whatshot,
                      buttonWidth,
                    ),
                    buildSquareButton(
                      context,
                      'AGITAR',
                      Colors.green,
                      onUpdateStageText,
                      Icons.waves,
                      buttonWidth,
                    ),
                    buildSquareButton(
                      context,
                      'INCLINAR',
                      Colors.green,
                      onUpdateStageText,
                      Icons.trending_up,
                      buttonWidth,
                    ),
                    buildSquareButton(
                      context,
                      'ALERTAR',
                      Colors.green,
                      onUpdateStageText,
                      Icons.warning,
                      buttonWidth,
                    ),
                    buildSquareButton(
                      context,
                      'DISPARAR',
                      Colors.green,
                      onUpdateStageText,
                      Icons.rocket_launch,
                      buttonWidth,
                    ),
                    buildSquareButton(
                      context,
                      'ABORTAR',
                      Colors.red,
                      onUpdateStageText,
                      Icons.cancel,
                      buttonWidth,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSquareButton(
    BuildContext context,
    String title,
    Color color,
    Function(String) onUpdateStageText,
    IconData icon,
    double width,
  ) {
    return InkWell(
      onTap: () {
        onUpdateStageText(title);
        sendCommand(title);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$title ativado'),
          duration: Duration(seconds: 1),
        ));
      },
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 40),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LancamentoManualScreen(),
  ));
}
