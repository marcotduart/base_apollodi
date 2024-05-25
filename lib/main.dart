import 'package:flutter/material.dart';
import 'screens/lancamento_manual_screen.dart';
import 'screens/lancamento_automatico_screen.dart';
import 'screens/bluetooth_screen.dart';

void main() => runApp(MeuApp());

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Lançamento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    BluetoothScreen(),
    LancamentoManualScreen(),
    LancamentoAutomaticoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), 
            label: 'Configurações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.back_hand),
            label: 'Manual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch),
            label: 'Automático',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
