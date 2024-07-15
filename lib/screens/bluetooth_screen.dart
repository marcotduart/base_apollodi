import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  static BluetoothCharacteristic? targetCharacteristic;

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool isScanning = false;
  final Duration scanInterval = Duration(seconds: 15);
  final TextEditingController angleController = TextEditingController();
  final TextEditingController pressureController = TextEditingController();
  String receivedData = '';

  @override
  void initState() {
    super.initState();
    requestPermissions();
    scanForDevicesPeriodically();
  }

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.location.request();
  }

  void scanForDevices() async {
    if (isScanning || connectedDevice != null) return;

    setState(() {
      isScanning = true;
      devicesList.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    });

    await Future.delayed(Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  void scanForDevicesPeriodically() async {
    if (connectedDevice == null) {
      scanForDevices();
      await Future.delayed(scanInterval);
      scanForDevicesPeriodically();
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
      isScanning = false; 
    });
    FlutterBluePlus.stopScan(); 
    discoverServices(device);
  }

  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
        BluetoothScreen.targetCharacteristic = null;
        receivedData = ''; 
      });
    }
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            BluetoothScreen.targetCharacteristic = characteristic;
          });
        }
        if (characteristic.properties.notify) {
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              receivedData = String.fromCharCodes(value);
            });
          });
        }
      }
    }
  }

  void sendCommand(String data) async {
    if (BluetoothScreen.targetCharacteristic != null) {
      await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
    }
  }

  void applySettings() {
    String angle = angleController.text;
    String pressure = pressureController.text;
    sendCommand('ANGLE: $angle');
    sendCommand('PRESSURE: $pressure');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('CONFIGURAÇÕES APLICADAS'),
      duration: Duration(seconds: 2),
    ));
  }

  Widget buildBluetoothDeviceList() {
    if (isScanning) {
      return Center(child: CircularProgressIndicator());
    } else if (devicesList.isEmpty) {
      return Center(child: Text('Nenhum dispositivo encontrado'));
    } else {
      return ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(
                device.name.isNotEmpty ? device.name : 'Dispositivo desconhecido'),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () => connectToDevice(device),
              child: Text('Conectar', style: TextStyle(color: Colors.black)),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: connectedDevice != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              
                children: [
                  Row(
                    children: [Icon(Icons.bluetooth, size:40),
                  SizedBox(height: 20,),
                  Text("Bluetooth", style: TextStyle(fontSize: 24))]),
                  Text('Conectado a ${connectedDevice!.name}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  TextField(
                    controller: angleController,
                    decoration: InputDecoration(labelText: 'Ângulo de Inclinação'),
                  ),
                  TextField(
                    controller: pressureController,
                    decoration: InputDecoration(labelText: 'Pressão Máxima'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: applySettings,
                    child: Text('Aplicar'),
                  ),
                  SizedBox(height: 20),
                  Text('Dados Recebidos: $receivedData', style: TextStyle(fontSize: 16)),
                ],
              )
            : Expanded(child: buildBluetoothDeviceList()),
      ),
      floatingActionButton: connectedDevice != null
          ? FloatingActionButton(
              onPressed: disconnectFromDevice,
              child: Icon(Icons.bluetooth_disabled),
              tooltip: 'Desconectar',
            )
          : null,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BluetoothScreen(),
  ));
}
