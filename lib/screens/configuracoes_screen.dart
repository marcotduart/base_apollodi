import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConfiguracoesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ConnectionSection(),
            ParametersSection(),
          ],
        ),
      ),
    );
  }
}

class ConnectionSection extends StatefulWidget {
  @override
  _ConnectionSectionState createState() => _ConnectionSectionState();
}

class _ConnectionSectionState extends State<ConnectionSection> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('${result.device.name} encontrado! rssi: ${result.rssi}');
        if (result.device.name == 'ESP32') {
          connectToDevice(result.device);
          flutterBlue.stopScan();
          break;
        }
      }
    });

    Future.delayed(Duration(seconds: 4), () {
      flutterBlue.stopScan();
      subscription.cancel();
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    discoverServices();
  }

  void discoverServices() async {
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      setState(() {
        this.services = services;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text('Conexão com Base de Lançamento'),
            subtitle:
                Text(connectedDevice != null ? 'Conectado' : 'Desconectado'),
          ),
          ListTile(
            title: Text(
                'Tempo de conexão: ${connectedDevice != null ? 'Ativo' : 'Desativado'}'),
            subtitle: Text(connectedDevice != null
                ? 'Conectado com sucesso!'
                : 'Escanenado dispositivos...'),
          ),
        ],
      ),
    );
  }
}

class ParametersSection extends StatelessWidget {
  final TextEditingController inclinacaoController = TextEditingController();
  final TextEditingController pressaoController = TextEditingController();
  final ValueNotifier<bool> isButtonActive = ValueNotifier(false);

  ParametersSection() {
    inclinacaoController.addListener(updateButtonState);
    pressaoController.addListener(updateButtonState);
  }

  void updateButtonState() {
    final isAnyFieldNotEmpty = inclinacaoController.text.isNotEmpty &&
        pressaoController.text.isNotEmpty;
    isButtonActive.value = isAnyFieldNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: inclinacaoController,
              decoration:
                  InputDecoration(labelText: 'Ângulo de Inclinação (º)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 10),
            TextField(
              controller: pressaoController,
              decoration: InputDecoration(labelText: 'Pressão Máxima (psi)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: isButtonActive,
              builder: (context, isButtonActive, child) {
                return IconButton(
                  icon: Icon(Icons.check),
                  onPressed: isButtonActive
                      ? () {
                          // Logic to apply settings
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
