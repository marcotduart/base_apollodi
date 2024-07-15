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
  String stageText = ' ';
  Timer? _timer;
  Map<String, bool> switchStates = {
    'IGNITAR': false,
    'AGITAR': false,
    'INCLINAR': false,
    'ALERTAR': false,
    'DISPARAR': false,
    'ABORTAR': false,
  };

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

  void handleSwitchToggle(String title, bool isActive, String commandOn, String commandOff) {
    String command = isActive ? commandOn : commandOff;
    sendCommand(command);

    setState(() {
      switchStates[title] = isActive;
    });

    updateStageText(title);
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PressureDisplay(),
            SizedBox(height: 20),
            ...switchStates.entries.map((entry) {
              String title = entry.key;
              bool isActive = entry.value;
              IconData icon;
              Color color;
              String commandOn;
              String commandOff;

              switch (title) {
                case 'IGNITAR':
                  icon = Icons.whatshot;
                  color = Colors.green;
                  commandOn = 'L11';
                  commandOff = 'L10';
                  break;
                case 'AGITAR':
                  icon = Icons.waves;
                  color = Colors.green;
                  commandOn = 'L21';
                  commandOff = 'L20';
                  break;
                case 'INCLINAR':
                  icon = Icons.trending_up;
                  color = Colors.green;
                  commandOn = 'L31';
                  commandOff = 'L30';
                  break;
                case 'ALERTAR':
                  icon = Icons.warning;
                  color = Colors.green;
                  commandOn = 'L41';
                  commandOff = 'L40';
                  break;
                case 'DISPARAR':
                  icon = Icons.rocket_launch;
                  color = Colors.green;
                  commandOn = 'L51';
                  commandOff = 'L50';
                  break;
                case 'ABORTAR':
                  icon = Icons.cancel;
                  color = Colors.red;
                  commandOn = 'L61';
                  commandOff = 'L60';
                  break;
                default:
                  icon = Icons.help;
                  color = Colors.grey;
                  commandOn = '';
                  commandOff = '';
              }

              return buildSwitch(
                context,
                title,
                icon,
                color,
                commandOn,
                commandOff,
                isActive,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildSwitch(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String commandOn,
    String commandOff,
    bool isActive,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Icon(icon, color: isActive ? color : Colors.grey, size: 24),
          title: Text(
            title,
            style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 16),
          ),
          trailing: Switch(
            value: isActive,
            onChanged: (value) {
              handleSwitchToggle(title, value, commandOn, commandOff);
            },
            activeColor: color,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
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
