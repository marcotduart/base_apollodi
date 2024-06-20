import 'package:flutter/material.dart';
import 'package:base_apollodi/widgets/pressure_display.dart';
import 'bluetooth_screen.dart';

// Função para enviar comandos via Bluetooth
void sendCommand(String data) async {
  if (BluetoothScreen.targetCharacteristic != null) {
    await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
  }
}

class LancamentoAutomaticoScreen extends StatefulWidget {
  @override
  _LancamentoAutomaticoScreenState createState() =>
      _LancamentoAutomaticoScreenState();
}

class _LancamentoAutomaticoScreenState
    extends State<LancamentoAutomaticoScreen> {
  bool canStartLaunch = false;
  bool canAbortLaunch = false;

  // Função chamada ao pressionar um botão
  void handleButtonPress(String title) {
    String command = ""; // Inicializa a string de comando
    if (title == 'NOVO LANÇAMENTO') {
      setState(() {
        canStartLaunch = true;
        canAbortLaunch = false;
      });
      command = "L1ON"; // Comando para ligar o LED
    } else if (title == 'INICIAR LANÇAMENTO') {
      setState(() {
        canStartLaunch = false;
        canAbortLaunch = true;
      });
      command = "START"; // Exemplo de outro comando
    } else if (title == 'ABORTAR') {
      setState(() {
        canStartLaunch = false;
        canAbortLaunch = false;
      });
      command = "L1OFF"; // Comando para desligar o LED
    }
    sendCommand(command); // Envia o comando mapeado via Bluetooth
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
            double buttonWidth = (constraints.maxWidth - 48) / 3; // Espaço para botões 

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espalha os botões 
              children: <Widget>[
                buildSquareButton(context, 'NOVO LANÇAMENTO', Colors.green, Icons.add, true, buttonWidth),
                buildSquareButton(context, 'INICIAR LANÇAMENTO', Colors.green, Icons.start, canStartLaunch, buttonWidth),
                buildSquareButton(context, 'ABORTAR', Colors.red, Icons.cancel, canAbortLaunch, buttonWidth),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSquareButton(BuildContext context, String title, Color color, IconData icon, bool isEnabled, double width) {
    return InkWell(
      onTap: isEnabled
          ? () {
              onButtonPress(title); // Chama a função ao pressionar o botão
            }
          : null,
      child: Container(
        width: width, 
        height: 100, 
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey, 
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha o texto 
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 50),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold, 
                  ),
                  overflow: TextOverflow.ellipsis, 
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
