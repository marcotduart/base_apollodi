import 'package:flutter/material.dart';
import 'package:base_apollodi/widgets/pressure_display.dart';

class LancamentoAutomaticoScreen extends StatefulWidget {
  @override
  _LancamentoAutomaticoScreenState createState() => _LancamentoAutomaticoScreenState();
}

class _LancamentoAutomaticoScreenState extends State<LancamentoAutomaticoScreen> {
  bool canStartLaunch = false;
  bool canAbortLaunch = false;

  void handleButtonPress(String title) {
    if (title == 'NOVO LANÇAMENTO') {
      setState(() {
        canStartLaunch = true;
        canAbortLaunch = false;
      });
    } else if (title == 'INICIAR LANÇAMENTO') {
      setState(() {
        canStartLaunch = false;
        canAbortLaunch = true;
      });
    } else if (title == 'ABORTAR') {
      setState(() {
        canStartLaunch = false;
        canAbortLaunch = false;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$title ATIVADO'),
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lançamento Automático'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            PressureDisplay(),
            AutomaticControlSection(
              canStartLaunch: canStartLaunch,
              canAbortLaunch: canAbortLaunch,
              onButtonPress: handleButtonPress,
            ),
          ],
        ),
      ),
    );
  }
}

class AutomaticControlSection extends StatelessWidget {
  final bool canStartLaunch;
  final bool canAbortLaunch;
  final Function(String) onButtonPress;

  const AutomaticControlSection({
    required this.canStartLaunch,
    required this.canAbortLaunch,
    required this.onButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double buttonWidth = (constraints.maxWidth - 48) / 3; // Espaço para 3 botões com margem de 16 cada lado e 8 entre eles

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espalha os botões uniformemente
              children: <Widget>[
                buildSquareButton(
                    context, 'NOVO LANÇAMENTO', Colors.green, Icons.add, true, buttonWidth),
                buildSquareButton(
                    context, 'INICIAR LANÇAMENTO', Colors.green, Icons.start, canStartLaunch, buttonWidth),
                buildSquareButton(
                    context, 'ABORTAR', Colors.red, Icons.cancel, canAbortLaunch, buttonWidth),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSquareButton(BuildContext context, String title, Color color, IconData icon,
      bool isEnabled, double width) {
    return InkWell(
      onTap: isEnabled
          ? () {
              onButtonPress(title);
            }
          : null,
      child: Container(
        width: width, // Ajusta a largura baseada no espaço disponível
        height: 100, // Mantém a altura de 100
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey, // Muda a cor se desabilitado
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10), // Adiciona padding para o layout interno
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha o texto à esquerda
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 50),
              Expanded(
                // Utiliza o widget Expanded para permitir que o texto ocupe o espaço restante
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold, // Torna o texto negrito para melhor visibilidade
                  ),
                  overflow: TextOverflow.ellipsis, // Adiciona elipse se o texto for muito longo
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LancamentoAutomaticoScreen(),
  ));
}
