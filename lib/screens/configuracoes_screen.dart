import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  List<String> messages = [];

  Stream<List<BluetoothDevice>> connectedDevicesStream =
      Stream.fromIterable([FlutterBluePlus.connectedDevices]);

  @override
  void initState() {
    super.initState();
    connectedDevicesStream.listen((connectedDevices) {
      if (connectedDevices.isNotEmpty) {
        setState(() {
          connectedDevice = connectedDevices.first;
        });
      }
    });
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  void startScan() {
    print("Starting Bluetooth scan...");
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
  }

  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bluetooth, color: Colors.white),
            ),
            title: Text('Bluetooth'),
            trailing: IconButton(
              icon: Icon(Icons.restart_alt),
              onPressed: startScan,
            ),
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
              decoration: InputDecoration(
                labelText: 'Ângulo de Inclinação (º)',
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up, color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 10),
            TextField(
              controller: pressaoController,
              decoration: InputDecoration(
                labelText: 'Pressão Máxima (psi)',
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.speed, color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: isButtonActive,
              builder: (context, isButtonActive, child) {
                return IconButton(
                  icon: Icon(Icons.check),
                  onPressed: isButtonActive ? () {} : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
