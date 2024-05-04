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
            ConnectionSection(), // Connection section for Bluetooth
            ParametersSection(), // Parameters section for user inputs
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
  final ConnectionManager connectionManager = ConnectionManager();

  @override
  void initState() {
    super.initState();
    connectionManager.onDeviceConnected = () => setState(() {});
    connectionManager.onDeviceDisconnected = () => setState(() {});
    connectionManager.onScanResults = (devices) => setState(() {});
    connectionManager.startScan();
  }

  @override
  void dispose() {
    connectionManager.disconnectFromDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          if (connectionManager.connectedDevice != null) ...[
            ListTile(
              leading: Icon(Icons.bluetooth_connected),
              title: Text(connectionManager.connectedDevice!.name),
              subtitle: Text('Conectado'),
              trailing: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () => connectionManager.disconnectFromDevice(),
              ),
            ),
          ] else ...[
            ListTile(
              title: Text('Conexão Bluetooth'),
              subtitle: Text(
                  'Não foi possível conectar a nenhum dispositivo, recarregue a página'),
            ),
            for (BluetoothDevice device in connectionManager.availableDevices)
              ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text(
                    device.name.isEmpty ? 'Dispositivo sem nome' : device.name),
                trailing: IconButton(
                  icon: Icon(Icons.login),
                  onPressed: () => connectionManager.connectToDevice(device),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class ConnectionManager {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothDevice> availableDevices = [];
  List<BluetoothService> services =
      []; // Stores the services of the connected device
  bool isScanning = false;

  Function()? onDeviceConnected;
  Function()? onDeviceDisconnected;
  Function(List<BluetoothDevice>)? onScanResults;

  void startScan() async {
    isScanning = true;
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    var subscription = flutterBlue.scanResults.listen((results) {
      availableDevices = results.map((r) => r.device).toList();
      onScanResults?.call(availableDevices);
    });

    await Future.delayed(Duration(seconds: 4), () {
      if (isScanning) {
        flutterBlue.stopScan();
        subscription.cancel();
        isScanning = false;
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    connectedDevice = device;
    onDeviceConnected?.call();
    await discoverServices();
  }

  Future<void> discoverServices() async {
    if (connectedDevice != null) {
      services = await connectedDevice!.discoverServices();
    }
  }

  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      onDeviceDisconnected?.call();
    }
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
