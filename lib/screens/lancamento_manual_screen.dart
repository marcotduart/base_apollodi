import 'package:flutter/material.dart';
import 'dart:async';
import 'bluetooth_screen.dart';
import 'pressure_screen.dart';

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
  String inclinationLevel = 'N/A';
  Timer? _timer;

  Map<String, bool> buttonStates = {
    'Ignitar': false,
    'Agitar': false,
    'Inclinar': false,
    'Alertar': false,
    'Disparar': false,
    'Abortar': false,
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchInclinationData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void fetchInclinationData() async {
    if (BluetoothScreen.targetAngleCharacteristic != null) {
      try {
        List<int> value = await BluetoothScreen.targetAngleCharacteristic!.read();
        String data = String.fromCharCodes(value);
        setState(() {
          inclinationLevel = data;
        });
      } catch (e) {
        print("Erro ao ler os dados de inclinação: $e");
      }
    }
  }

  void _resetAllButtons() {
    setState(() {
      buttonStates.keys.forEach((title) {
        buttonStates[title] = false;
      });
    });
  }

  void handleButtonPress(String title, String commandOn) {
    sendCommand(commandOn);
    setState(() {
      buttonStates[title] = true;
    });
  }

  void handleButtonRelease(String title, String commandOff) {
    sendCommand(commandOff);
    setState(() {
      buttonStates[title] = false;
    });
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
              children: buttonStates.entries.map((entry) {
                String title = entry.key;
                bool isActive = entry.value;
                IconData icon;
                Color color;
                String commandOn;
                String commandOff;

                switch (title) {
                  case 'Ignitar':
                    icon = Icons.whatshot;
                    color = Colors.green;
                    commandOn = 'L11';
                    commandOff = 'L10';
                    break;
                  case 'Agitar':
                    icon = Icons.waves;
                    color = Colors.green;
                    commandOn = 'L21';
                    commandOff = 'L20';
                    break;
                  case 'Inclinar':
                    icon = Icons.trending_up;
                    color = Colors.green;
                    commandOn = 'L31';
                    commandOff = 'L30';
                    break;
                  case 'Alertar':
                    icon = Icons.warning;
                    color = Colors.green;
                    commandOn = 'L41';
                    commandOff = 'L40';
                    break;
                  case 'Disparar':
                    icon = Icons.rocket_launch;
                    color = Colors.green;
                    commandOn = 'L51';
                    commandOff = 'L50';
                    break;
                  case 'Abortar':
                    icon = Icons.cancel;
                    color = Colors.deepOrange;
                    commandOn = 'L61';
                    commandOff = 'L60';
                    break;
                  default:
                    icon = Icons.help;
                    color = Colors.grey;
                    commandOn = '';
                    commandOff = '';
                }

                return title == 'Inclinar'
                    ? buildInclinationButton(
                        context,
                        title,
                        icon,
                        color,
                        commandOn,
                        commandOff,
                        isActive,
                      )
                    : buildButton(
                        context,
                        title,
                        icon,
                        color,
                        commandOn,
                        commandOff,
                        isActive,
                      );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String commandOn,
    String commandOff,
    bool isActive,
  ) {
    return GestureDetector(
      onTapDown: (_) => handleButtonPress(title, commandOn),
      onTapUp: (_) => handleButtonRelease(title, commandOff),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: isActive ? color : Colors.grey, size: 50),
              Text(
                title,
                style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 16),
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
    bool isActive,
  ) {
    return GestureDetector(
      onTapDown: (_) => handleButtonPress(title, commandOn),
      onTapUp: (_) => handleButtonRelease(title, commandOff),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: isActive ? color : Colors.grey, size: 50),
              Text(
                title,
                style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 16),
              ),
              Text(
                'Inclinação: $inclinationLevel',
                style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 12),
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
