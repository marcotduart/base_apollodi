import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'bluetooth_screen.dart';
import 'pressure_screen.dart';

void sendCommand(String data) async {
  if (BluetoothScreen.targetCharacteristic != null) {
    await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
  }
} // Função para enviar comandos a partir da característica principal 

class LancamentoManualScreen extends StatefulWidget {
  @override
  _LancamentoManualScreenState createState() => _LancamentoManualScreenState();
} // Criando a tela de lançamento manual

class _LancamentoManualScreenState extends State<LancamentoManualScreen> {
  String inclinationLevel = 'N/A'; // Definindo variável para exibir níve de inclinção
  Timer? _timer; // Definindo timer para atualizar dados de inclinação periodicamente
  Timer? timer; // Definindo timer para atualizar dados de pressão periodicamente

  final String inclinationUuid = '0f1d2df9-f709-4633-bb27-0c52e13f748a'; // Define variável com Uuid dos dados de inclinação

  void handleButtonPress(String commandOn) {
    sendCommand(commandOn);
  } // Função que identifica quando o botão está pressionado para o envio apenas os comandos de ligar

  void handleButtonRelease(String commandOff) {
    sendCommand(commandOff);
  } // Função que identifica quando o botão não está pressionado para o envio apenas os comandos de desligar

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchInclinationData());
  } // Comando que permite o timer periodico relacionado aos dados de inclinação

  @override
  void dispose() {
    _timer?.cancel();
    timer?.cancel();
    super.dispose();
  } // Comando que desliga o timer periodico relacionado aos dados de inclinação e pressão após o fechamento da tela

  void fetchInclinationData() async {
    if (BluetoothScreen.targetCharacteristic != null) {
      try {
        List<int> value = await BluetoothScreen.targetCharacteristic!.read();
        String data = String.fromCharCodes(value);
        List<String> dataLines = data.split("\n"); // Chama a função de recebimento de dados e os separa por linha

        bool inclinationDataFound = false; // Definindo uma variável booleano que identifica se os dados de inclinação estão sendo recebidos ou não

        for (String line in dataLines) {
          if (line.contains(inclinationUuid)) {
            setState(() {
              inclinationLevel = line.split(inclinationUuid)[1];
            });
            inclinationDataFound = true;
            break;
          }
        } // Separa os dados que possuem o Uuid de inclinação dos que não possuem

        if (!inclinationDataFound) {
          Random random = Random();
          double randomInclination = random.nextDouble() * 90;
          setState(() {
            inclinationLevel = randomInclination.toStringAsFixed(2);
          });
        } // Caso os dados não sejam recebidos, gerar uma inclinação aleatória 
      } catch (e) {
        print("Erro ao ler os dados do Bluetooth: $e"); // Nesse caso, exibir uma mensagem de erro
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lançamento Manual'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PressureDisplay(),
            SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                buildButton(context, 'Ignitar', Icons.whatshot, Colors.green, 'L11', 'L10'),
                buildButton(context, 'Agitar', Icons.waves, Colors.green, 'L21', 'L20'),
                buildInclinationButton(context, 'Inclinar', Icons.trending_up, Colors.green, 'L31', 'L30'),
                buildButton(context, 'Alertar', Icons.warning, Colors.green, 'L41', 'L40'),
                buildButton(context, 'Disparar', Icons.rocket_launch, Colors.green, 'L51', 'L50'),
                buildButton(context, 'Abortar', Icons.cancel, Colors.deepOrange, 'L61', 'L60'),
              ],
            ),
          ],
        ),
      ),
    );
  } // Função para criar tela principal e gerar botões 

  Widget buildButton( // Função para definir variáveis para informações dos botões
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String commandOn,
    String commandOff,
  ) {
    return GestureDetector( // Função para identificar gesto dos botões e enviar comandos
      onTapDown: (_) => handleButtonPress(commandOn),
      onTapUp: (_) => handleButtonRelease(commandOff),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 50),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInclinationButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String commandOn,
    String commandOff,
  ) { // Função para criar botão específico com dados de inclinação 
    return GestureDetector( // Chama função para detectar gestos
      onTapDown: (_) => handleButtonPress(commandOn),
      onTapUp: (_) => handleButtonRelease(commandOff),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 50),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 16),
              ),
              Text(
                'Inclinação: $inclinationLevel',
                style: TextStyle(color: color, fontSize: 12),
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
    home: LancamentoManualScreen(),
  ));
}
