import 'package:flutter/material.dart';
import 'pressure_screen.dart';
import 'bluetooth_screen.dart';

void sendCommand(String data) async {
  if (BluetoothScreen.targetCharacteristic != null) {
    await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
  }
}

class LancamentoAutomaticoScreen extends StatefulWidget {
  @override
  _LancamentoAutomaticoScreenState createState() => _LancamentoAutomaticoScreenState();
}

class _LancamentoAutomaticoScreenState extends State<LancamentoAutomaticoScreen> {
  bool canStartLaunch = false;
  bool canAbortLaunch = false;
  Map<String, bool> switchStates = {
    'NOVO LANÇAMENTO': false,
    'INICIAR LANÇAMENTO': false,
    'ABORTAR': false,
  };

  void handleSwitchToggle(String title, bool isActive, String commandOn, String commandOff) {
    String command = isActive ? commandOn : commandOff;
    sendCommand(command);

    setState(() {
      switchStates[title] = isActive;
      if (title == 'NOVO LANÇAMENTO') {
        canStartLaunch = isActive;
        canAbortLaunch = false;
      } else if (title == 'INICIAR LANÇAMENTO') {
        canStartLaunch = false;
        canAbortLaunch = isActive;
      } else if (title == 'ABORTAR') {
        canStartLaunch = false;
        canAbortLaunch = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$title ${isActive ? "ativado" : "desativado"}'),
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
                case 'NOVO LANÇAMENTO':
                  icon = Icons.add;
                  color = Colors.green;
                  commandOn = 'L10';
                  commandOff = 'L00';
                  break;
                case 'INICIAR LANÇAMENTO':
                  icon = Icons.play_arrow;
                  color = Colors.green;
                  commandOn = 'L50';
                  commandOff = 'L40';
                  break;
                case 'ABORTAR':
                  icon = Icons.cancel;
                  color = Colors.red;
                  commandOn = 'L60';
                  commandOff = 'L50';
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
    home: LancamentoAutomaticoScreen(),
  ));
}
