import 'package:flutter/material.dart';
import 'dart:async';

class LancamentoManualScreen extends StatefulWidget {
  @override
  _LancamentoManualScreenState createState() => _LancamentoManualScreenState();
}

class _LancamentoManualScreenState extends State<LancamentoManualScreen> {
  String stageText = ' ';
  Timer? _timer; // Adicionando uma variável para o Timer

  void updateStageText(String newStage) {
    setState(() {
      stageText = '$newStage ativado com sucesso';
    });
    // Cancela qualquer timer existente para evitar sobreposições
    _timer?.cancel();
    // Define um novo timer para limpar o texto após 3 segundos
    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        stageText = ' '; // Limpa o texto
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer quando o widget é desmontado
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

  RelayControlSection(
      {required this.onUpdateStageText, required this.stageText});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Wrap(
              spacing: 10,
              children: <Widget>[
                buildSquareButton(context, 'IGNITAR', Colors.green,
                    onUpdateStageText, Icons.whatshot),
                buildSquareButton(context, 'AGITAR', Colors.green,
                    onUpdateStageText, Icons.waves),
                buildSquareButton(context, 'INCLINAR', Colors.green,
                    onUpdateStageText, Icons.compare_arrows),
                buildSquareButton(context, 'ALERTAR', Colors.green,
                    onUpdateStageText, Icons.warning),
                buildSquareButton(context, 'DISPARAR', Colors.green,
                    onUpdateStageText, Icons.rocket_launch),
                buildSquareButton(context, 'ABORTAR', Colors.red,
                    onUpdateStageText, Icons.cancel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSquareButton(BuildContext context, String title, Color color,
      Function(String) onUpdateStageText, IconData icon) {
    return InkWell(
      onTap: () {
        onUpdateStageText(title); // Atualiza o texto do palco
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$title ATIVADO'),
            duration: Duration(seconds: 1))); // Exibe a SnackBar
      },
      child: Container(
        width: 80,
        height: 80,
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
