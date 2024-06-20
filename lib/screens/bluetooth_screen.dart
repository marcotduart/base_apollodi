import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  static BluetoothCharacteristic? targetCharacteristic; // Static for global access

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
    if (isScanning) return;

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

  void scanForDevicesPeriodically() {
    scanForDevices();
    Future.delayed(scanInterval, scanForDevicesPeriodically);
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    discoverServices(device);
  }

  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
        BluetoothScreen.targetCharacteristic = null;
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
          break;
        }
      }
    }
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
                device.name.isNotEmpty ? device.name : 'Dispositivo sem nome'),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () => connectToDevice(device),
              child: Text('Conectar'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bluetooth, size: 40),
                SizedBox(width: 10),
                Text('Bluetooth', style: TextStyle(fontSize: 24)),
              ],
            ),
            SizedBox(height: 20),
            connectedDevice != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conectado a ${connectedDevice!.name}',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                      TextField(
                        controller: angleController,
                        decoration:
                            InputDecoration(labelText: 'Ângulo de Inclinação'),
                      ),
                      TextField(
                        controller: pressureController,
                        decoration:
                            InputDecoration(labelText: 'Pressão Máxima'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          String angle = angleController.text;
                          String pressure = pressureController.text;
                         sendCommand('$angle');
                          sendCommand('$pressure');
                        },
                        child: Text('Aplicar'),
                      ),
                    ],
                  )
                : Expanded(child: buildBluetoothDeviceList()),
          ],
        ),
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

  void sendCommand(String data) async {
    if (BluetoothScreen.targetCharacteristic != null) {
      await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
    }
  }
}
