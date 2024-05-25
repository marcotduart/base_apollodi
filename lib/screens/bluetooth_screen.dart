import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;
  bool isScanning = false;
  final Duration scanInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    scanForDevicesPeriodically();
  }

  void scanForDevices() async {
    if (isScanning) return;
    
    setState(() {
      isScanning = true;
      devicesList.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    });

    await Future.delayed(Duration(seconds: 4));
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
        targetCharacteristic = null;
      });
    }
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write && characteristic.properties.read) {
          setState(() {
            targetCharacteristic = characteristic;
          });
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            // Process received data from ESP32
            print('Received data: $value');
          });
        }
      }
    }
  }

  void sendDataToCharacteristic(String data) async {
    if (targetCharacteristic != null) {
      await targetCharacteristic!.write(data.codeUnits);
    }
  }

  Widget buildBluetoothDeviceList() {
    if (isScanning) {
      return Center(child: CircularProgressIndicator());
    } else if (devicesList.isEmpty) {
      return Center(child: Text('No devices found'));
    } else {
      return ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () => connectToDevice(device),
              child: Text('Connect'),
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
        title: Text('Bluetooth'),
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
            Expanded(child: buildBluetoothDeviceList()),
          ],
        ),
      ),
      floatingActionButton: connectedDevice != null
          ? FloatingActionButton(
              onPressed: disconnectFromDevice,
              child: Icon(Icons.bluetooth_disabled),
              tooltip: 'Disconnect',
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
